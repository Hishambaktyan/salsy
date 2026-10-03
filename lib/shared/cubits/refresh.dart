import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'productsCubit/products_cubit.dart';
import 'salesCubit/sales_cubit.dart';
import 'statsCubit/stats_cubit.dart';

Future<void> refreshAll(BuildContext context) async {
  await context.read<ProductsCubit>().getProducts();
  await context.read<SalesCubit>().getSales();
  await context.read<StatsCubit>().loadAll(context);
}