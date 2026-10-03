import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_sales_manager/shared/networks/local/db_helper.dart';
import '../../constants.dart';
import '../../localization/app_localizations.dart';
import '../../services/notification_service.dart';
import 'sales_states.dart';

class SalesCubit extends Cubit<SalesStates> {
  SalesCubit() : super(SalesInitial());

  static SalesCubit get(context) => BlocProvider.of(context);

  List<Map<String, dynamic>> sales = [];

  Future<void> getSales() async {
    try {
      final rows = await DbHelper.getSales();
      sales = rows
          .map((r) => {
        ...r,
        'dbId': r['id'],
        'id': r['invoiceNo'] ?? '#${r['id']}',
      })
          .toList();
      emit(SalesLoaded());
    } catch (e) {
      emit(SalesError(e.toString()));
    }
  }

  Future<List<Map<String, dynamic>>> getItems(int saleDbId) =>
      DbHelper.getSaleItems(saleDbId);

  String _msg(Object e) => e.toString().replaceFirst('Exception: ', '');

  Future<String?> addSale(
      BuildContext context,
      Map<String, dynamic> sale,
      List<Map<String, dynamic>> items,
      ) async
  {
    try {
      await DbHelper.insertSale(sale, items);
      await getSales();

      final invoiceNo = sale['invoiceNo']?.toString() ?? 'N/A';
      final total = sale['total']?.toString() ?? '0';

      NotificationService().showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: tr(context, 'notif_new_sale_title'),
        body: trp(context, 'notif_new_sale_body', {
          'invoiceNo': invoiceNo,
          'total': total,
        }),
      );

      for (final item in items) {
        final productId = item['productId'] ?? item['id'];
        final name = item['name'] as String? ?? '';

        if (productId != null) {
          final productList = await DbHelper.getProducts();
          final updatedProduct = productList.firstWhere(
                (p) => p['id'] == productId,
            orElse: () => {},
          );

          if (updatedProduct.isNotEmpty) {
            final remainingQty = updatedProduct['quantity'] as int;

            if (remainingQty == 0) {
              NotificationService().showNotification(
                id: name.hashCode,
                title: tr(context, 'notif_out_of_stock_title'),
                body: trp(context, 'notif_out_of_stock_body', {'name': name}),
              );
            } else if (remainingQty <= lowStockLimit) {
              NotificationService().showNotification(
                id: name.hashCode,
                title: tr(context, 'notif_low_stock_title'),
                body: trp(context, 'notif_low_stock_body', {
                  'name': name,
                  'n': remainingQty.toString(),
                }),
              );
            }
          }
        }
      }

      return null;
    } catch (e) {
      return _msg(e);
    }
  }
  Future<String?> changeStatus(BuildContext context, int dbId, String status) async {
    try {
      await DbHelper.updateSaleStatus(dbId, status);
      await getSales();

      NotificationService().showNotification(
        id: dbId,
        title: tr(context, 'notif_status_title'),
        body: trp(context, 'notif_status_body', {
          'id': dbId.toString(),
          'status': tr(context, status),
        }),
      );

      return null;
    } catch (e) {
      return _msg(e);
    }
  }

  Future<String?> deleteSale(int dbId) async {
    try {
      await DbHelper.deleteSale(dbId);
      await getSales();
      return null;
    } catch (e) {
      return _msg(e);
    }
  }
}