import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:inventory_sales_manager/shared/localization/app_localizations.dart';

const int lowStockLimit = 5;

const List<String> productCategories = [
  'Electronics', 'Fashion', 'Accessories', 'Food', 'Home & Living', 'Other',
];

Color categoryColor(String? c) {
  switch (c) {
    case 'Electronics': return const Color(0xFF8B5CF6);
    case 'Accessories': return const Color(0xFF0891B2);
    case 'Fashion':     return const Color(0xFFEA580C);
    case 'Food':        return const Color(0xFF059669);
    case 'Home & Living': return const Color(0xFFDB2777);
    default:            return const Color(0xFF0284C7);
  }
}

IconData categoryIcon(String? c) {
  switch (c) {
    case 'Electronics': return Icons.headphones_rounded;
    case 'Accessories': return Icons.watch_outlined;
    case 'Fashion':     return Icons.checkroom_rounded;
    case 'Food':        return Icons.restaurant_rounded;
    case 'Home & Living': return Icons.chair_outlined;
    default:            return Icons.inventory_2_outlined;
  }
}

String money(num v) => '\$${NumberFormat('#,##0.00', 'en').format(v)}';

String formatSaleDate(String iso, String lang) {
  final d = DateTime.parse(iso);
  final now = DateTime.now();
  final diff = DateTime(now.year, now.month, now.day)
      .difference(DateTime(d.year, d.month, d.day))
      .inDays;
  final time = DateFormat('hh:mm a', 'en').format(d);
  if (diff == 0) return '${AppLocalizations.translate('Today', lang)}, $time';
  if (diff == 1) return '${AppLocalizations.translate('Yesterday', lang)}, $time';
  return DateFormat('dd MMM, yyyy', 'en').format(d);
}