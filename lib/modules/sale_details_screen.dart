import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inventory_sales_manager/shared/constants.dart';
import 'package:inventory_sales_manager/shared/cubits/appCubit/app_cubit.dart';
import 'package:inventory_sales_manager/shared/cubits/refresh.dart';
import 'package:inventory_sales_manager/shared/cubits/salesCubit/sales_cubit.dart';
import 'package:inventory_sales_manager/shared/localization/app_localizations.dart';
import 'package:inventory_sales_manager/shared/styles/colors.dart';

class SaleDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> sale;
  const SaleDetailsScreen({super.key, required this.sale});

  Future<void> _change(BuildContext context, String status) async {
    final err =
    await context.read<SalesCubit>().changeStatus(context,sale['dbId'], status);
    if (!context.mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err), backgroundColor: Colors.red));
      return;
    }
    await refreshAll(context);
    if (context.mounted) Navigator.pop(context);
  }

  Future<void> _delete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text(tr(d, 'Delete Sale')),
        content: Text(sale['id'].toString()),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(d, false),
              child: Text(tr(d, 'Cancel'))),
          TextButton(
              onPressed: () => Navigator.pop(d, true),
              child: Text(tr(d, 'Delete'),
                  style: const TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await context.read<SalesCubit>().deleteSale(sale['dbId']);
    if (!context.mounted) return;
    await refreshAll(context);
    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final app = AppCubit.get(context);
    final isDark = app.isDark;
    final card = isDark ? lightDarkColor : Colors.white;
    final txt = isDark ? Colors.white : Colors.black;
    final sub = isDark ? Colors.white60 : Colors.grey;
    final status = sale['status'] as String;

    Widget row(String k, String v, {bool bold = false}) => Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k, style: TextStyle(color: sub, fontSize: 12.sp)),
          Text(v,
              style: TextStyle(
                  color: txt,
                  fontSize: 13.sp,
                  fontWeight: bold ? FontWeight.w800 : FontWeight.w600)),
        ],
      ),
    );

    BoxDecoration box() => BoxDecoration(
        color: card, borderRadius: BorderRadius.circular(18.r));

    return Scaffold(
      appBar: AppBar(title: Text(sale['id'].toString())),
      body: ListView(
        padding: EdgeInsets.all(16.r),
        children: [
          Container(
            padding: EdgeInsets.all(14.r),
            decoration: box(),
            child: Column(children: [
              row(tr(context, 'Customer'), tr(context, sale['customer'])),
              row(tr(context, 'Date'),
                  formatSaleDate(sale['date'], app.language)),
              row(tr(context, 'Payment'), tr(context, sale['paymentMethod'])),
              row(tr(context, 'Status'), tr(context, status)),
              if ((sale['notes'] ?? '').toString().isNotEmpty)
                row(tr(context, 'Notes'), sale['notes']),
            ]),
          ),
          SizedBox(height: 14.h),
          Container(
            padding: EdgeInsets.all(14.r),
            decoration: box(),
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: SalesCubit.get(context).getItems(sale['dbId']),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Column(
                  children: snap.data!
                      .map((it) => row(
                      '${tr(context, it['name'].toString())}  ×${it['quantity']}',
                      money(it['total'] as num)))
                      .toList(),
                );
              },
            ),
          ),
          SizedBox(height: 14.h),
          Container(
            padding: EdgeInsets.all(14.r),
            decoration: box(),
            child: Column(children: [
              row(tr(context, 'Subtotal'), money(sale['subtotal'])),
              row(tr(context, 'Discount'), '- ${money(sale['discount'])}'),
              Divider(color: sub.withOpacity(0.3)),
              row(tr(context, 'Total'), money(sale['total']), bold: true),
            ]),
          ),
          SizedBox(height: 20.h),
          if (status == 'Pending')
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                  minimumSize: Size.fromHeight(48.h)),
              onPressed: () => _change(context, 'Completed'),
              child: Text(tr(context, 'Mark as Completed'),
                  style: const TextStyle(color: Colors.white)),
            ),
          if (status == 'Cancelled')
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                  minimumSize: Size.fromHeight(48.h)),
              onPressed: () => _change(context, 'Completed'),
              child: Text(tr(context, 'Restore Sale'),
                  style: const TextStyle(color: Colors.white)),
            ),
          if (status != 'Cancelled') ...[
            SizedBox(height: 10.h),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                  minimumSize: Size.fromHeight(48.h),
                  side: const BorderSide(color: Color(0xFFEA580C))),
              onPressed: () => _change(context, 'Cancelled'),
              child: Text(tr(context, 'Cancel Sale'),
                  style: const TextStyle(color: Color(0xFFEA580C))),
            ),
          ],
          SizedBox(height: 10.h),
          TextButton(
            onPressed: () => _delete(context),
            child: Text(tr(context, 'Delete Sale'),
                style: const TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );
  }
}