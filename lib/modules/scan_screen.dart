import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:inventory_sales_manager/modules/add_product_screen.dart';
import 'package:inventory_sales_manager/shared/cubits/productsCubit/products_cubit.dart';
import 'package:inventory_sales_manager/shared/localization/app_localizations.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});
  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool handled = false;

  void onDetect(BarcodeCapture capture) {
    if (handled || capture.barcodes.isEmpty) return;
    final code = capture.barcodes.first.rawValue;
    if (code == null) return;
    handled = true;
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final notFound = tr(context, 'Product not found');
    final found = context
        .read<ProductsCubit>()
        .products
        .where((p) => p['sku'] == code)
        .toList();

    if (found.isNotEmpty) {
      nav.pushReplacement(MaterialPageRoute(
        builder: (_) => AddProductScreen(product: found.first),
      ));
    } else {
      nav.pop();
      messenger.showSnackBar(SnackBar(content: Text('$notFound: $code')));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(tr(context, 'Scan Item'))),
    body: MobileScanner(onDetect: onDetect),
  );
}