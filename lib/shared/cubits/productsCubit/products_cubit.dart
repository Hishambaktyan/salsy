import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_sales_manager/shared/constants.dart';
import 'package:inventory_sales_manager/shared/networks/local/db_helper.dart';
import '../../localization/app_localizations.dart';
import '../../services/notification_service.dart';
import 'products_states.dart';

class ProductsCubit extends Cubit<ProductsStates> {
  ProductsCubit() : super(ProductsInitial());

  static ProductsCubit get(context) => BlocProvider.of(context);

  List<Map<String, dynamic>> products = [];

  Future<void> getProducts() async {
    try {
      final rows = await DbHelper.getProducts();
      products = rows
          .map((r) => {
        ...r,
        'icon': categoryIcon(r['category'] as String?),
        'color': categoryColor(r['category'] as String?),
      })
          .toList();
      emit(ProductsLoaded());
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }

  Future<String?> saveProduct(BuildContext context, Map<String, dynamic> data, {int? id}) async {
    try {
      if (await DbHelper.skuExists(data['sku'], exceptId: id)) {
        return 'sku_exists';
      }
      if (id == null) {
        data['createdAt'] = DateTime.now().toIso8601String();
        await DbHelper.insertProduct(data);
      } else {
        await DbHelper.updateProduct(id, data);
      }
      await getProducts();

      _checkStockNotification(
        context,
        data['name'] as String,
        data['quantity'] as int,
      );

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  void _checkStockNotification(BuildContext context, String name, int quantity) {
    if (quantity == 0) {
      NotificationService().showNotification(
        id: name.hashCode,
        title: tr(context, 'notif_out_of_stock_title'),
        body: trp(context, 'notif_out_of_stock_body', {'name': name}),
      );
    } else if (quantity <= lowStockLimit) {
      NotificationService().showNotification(
        id: name.hashCode,
        title: tr(context, 'notif_low_stock_title'),
        body: trp(context, 'notif_low_stock_body', {
          'name': name,
          'n': quantity.toString(),
        }),
      );
    }
  }

  Future<void> deleteProduct(Map<String, dynamic> p) async {
    await DbHelper.deleteProduct(p['id'] as int);
    final path = p['imagePath'] as String?;
    if (path != null) {
      final f = File(path);
      if (await f.exists()) await f.delete();
    }
    await getProducts();
  }

}