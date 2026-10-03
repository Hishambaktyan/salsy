import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  DbHelper._();
  static late Database db;

  static Future<void> init() async {
    final path = join(await getDatabasesPath(), 'inventory_sales.db');
    db = await openDatabase(
      path,
      version: 1,
      onConfigure: (d) async => await d.execute('PRAGMA foreign_keys = ON'),
      onCreate: (d, version) async {
        await d.execute('''
          CREATE TABLE products(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            sku TEXT NOT NULL UNIQUE,
            category TEXT NOT NULL,
            price REAL NOT NULL,
            cost REAL NOT NULL DEFAULT 0,
            quantity INTEGER NOT NULL DEFAULT 0,
            description TEXT,
            imagePath TEXT,
            createdAt TEXT NOT NULL
          )''');
        await d.execute('''
          CREATE TABLE sales(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            invoiceNo TEXT,
            customer TEXT NOT NULL,
            paymentMethod TEXT NOT NULL,
            status TEXT NOT NULL,
            subtotal REAL NOT NULL,
            discount REAL NOT NULL DEFAULT 0,
            total REAL NOT NULL,
            itemsCount INTEGER NOT NULL,
            notes TEXT,
            date TEXT NOT NULL
          )''');
        await d.execute('''
          CREATE TABLE sale_items(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            saleId INTEGER NOT NULL,
            productId INTEGER,
            name TEXT NOT NULL,
            price REAL NOT NULL,
            cost REAL NOT NULL DEFAULT 0,
            quantity INTEGER NOT NULL,
            total REAL NOT NULL,
            FOREIGN KEY(saleId) REFERENCES sales(id) ON DELETE CASCADE,
            FOREIGN KEY(productId) REFERENCES products(id) ON DELETE SET NULL
          )''');
        await d.execute('CREATE INDEX idx_sales_date ON sales(date)');
      },
    );
  }

  static Future<List<Map<String, dynamic>>> getProducts() => db.query('products', orderBy: 'id DESC');

  static Future<int> insertProduct(Map<String, dynamic> p) => db.insert('products', p);

  static Future<int> updateProduct(int id, Map<String, dynamic> p) => db.update('products', p, where: 'id = ?', whereArgs: [id]);

  static Future<int> deleteProduct(int id) => db.delete('products', where: 'id = ?', whereArgs: [id]);

  static Future<bool> skuExists(String sku, {int? exceptId}) async {
    final r = await db.query('products',
        columns: ['id'],
        where: exceptId == null ? 'sku = ?' : 'sku = ? AND id != ?',
        whereArgs: exceptId == null ? [sku] : [sku, exceptId]);
    return r.isNotEmpty;
  }

  static Future<List<Map<String, dynamic>>> getSales() => db.query('sales', orderBy: 'date DESC');

  static Future<List<Map<String, dynamic>>> getSaleItems(int saleId) => db.query('sale_items', where: 'saleId = ?', whereArgs: [saleId]);

  static Future<int> insertSale(
      Map<String, dynamic> sale, List<Map<String, dynamic>> items) {
    return db.transaction((txn) async {
      for (final it in items) {
        final r = await txn.query('products',
            columns: ['name', 'quantity'],
            where: 'id = ?',
            whereArgs: [it['productId']]);
        if (r.isEmpty) throw Exception('Product not found');
        if ((r.first['quantity'] as int) < (it['quantity'] as int)) {
          throw Exception('Not enough stock for ${r.first['name']}');
        }
      }
      final saleId = await txn.insert('sales', sale);
      final year = DateTime.parse(sale['date']).year;
      await txn.update(
        'sales',
        {'invoiceNo': 'INV-$year-${saleId.toString().padLeft(3, '0')}'},
        where: 'id = ?',
        whereArgs: [saleId],
      );
      for (final it in items) {
        await txn.insert('sale_items', {...it, 'saleId': saleId});
        await txn.rawUpdate(
          'UPDATE products SET quantity = quantity - ? WHERE id = ?',
          [it['quantity'], it['productId']],
        );
      }
      return saleId;
    });
  }

  static Future<void> updateSaleStatus(int id, String newStatus) {
    return db.transaction((txn) async {
      final s = await txn.query('sales', where: 'id = ?', whereArgs: [id]);
      final old = s.first['status'] as String;
      if (old == newStatus) return;
      final items =
      await txn.query('sale_items', where: 'saleId = ?', whereArgs: [id]);

      if (newStatus == 'Cancelled') {
        for (final it in items) {
          if (it['productId'] == null) continue;
          await txn.rawUpdate(
              'UPDATE products SET quantity = quantity + ? WHERE id = ?',
              [it['quantity'], it['productId']]);
        }
      } else if (old == 'Cancelled') {
        for (final it in items) {
          if (it['productId'] == null) continue;
          final r = await txn.query('products',
              columns: ['quantity'],
              where: 'id = ?',
              whereArgs: [it['productId']]);
          if (r.isEmpty || (r.first['quantity'] as int) < (it['quantity'] as int)) {
            throw Exception('Not enough stock for ${it['name']}');
          }
          await txn.rawUpdate(
              'UPDATE products SET quantity = quantity - ? WHERE id = ?',
              [it['quantity'], it['productId']]);
        }
      }
      await txn.update('sales', {'status': newStatus},
          where: 'id = ?', whereArgs: [id]);
    });
  }

  static Future<void> deleteSale(int id) {
    return db.transaction((txn) async {
      final s = await txn.query('sales', where: 'id = ?', whereArgs: [id]);
      if (s.isEmpty) return;
      if (s.first['status'] != 'Cancelled') {
        final items =
        await txn.query('sale_items', where: 'saleId = ?', whereArgs: [id]);
        for (final it in items) {
          if (it['productId'] == null) continue;
          await txn.rawUpdate(
              'UPDATE products SET quantity = quantity + ? WHERE id = ?',
              [it['quantity'], it['productId']]);
        }
      }
      await txn.delete('sales', where: 'id = ?', whereArgs: [id]);
    });
  }
}