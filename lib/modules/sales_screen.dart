import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inventory_sales_manager/modules/add_sale.dart';
import 'package:inventory_sales_manager/modules/sale_details_screen.dart';
import 'package:inventory_sales_manager/shared/compenents/compenents.dart';
import 'package:inventory_sales_manager/shared/cubits/appCubit/app_cubit.dart';
import 'package:inventory_sales_manager/shared/cubits/appCubit/app_states.dart';
import 'package:inventory_sales_manager/shared/cubits/productsCubit/products_cubit.dart';
import 'package:inventory_sales_manager/shared/localization/app_localizations.dart';
import 'package:inventory_sales_manager/shared/styles/colors.dart';

import '../shared/constants.dart';
import '../shared/cubits/salesCubit/sales_cubit.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final TextEditingController searchController = TextEditingController();

  String selectedFilter = 'All';

  List<Map<String, dynamic>> get salesList => context.read<SalesCubit>().sales;

  final List<String> filters = [
    'All',
    'Completed',
    'Pending',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get filteredSales {
    return salesList.where((sale) {
      final search = searchController.text.toLowerCase();

      final matchesSearch =
          sale['id'].toString().toLowerCase().contains(search) ||
              sale['customer'].toString().toLowerCase().contains(search);

      final matchesFilter =
          selectedFilter == 'All' || sale['status'] == selectedFilter;

      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppStates>(
      builder: (context, state) {
        context.watch<SalesCubit>();
        AppCubit appCubit = AppCubit.get(context);
        bool isDark = appCubit.isDark;

        Color cardBackground = isDark ? lightDarkColor : Colors.white;
        Color primaryTextColor = isDark ? Colors.white : Colors.black;
        Color secondaryTextColor = isDark ? Colors.white60 : Colors.grey;

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr(context, 'Track & manage transactions'),
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: secondaryTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  tr(context, 'Sales Transactions'),
                  style: TextStyle(
                    color: primaryTextColor,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: ()=>move(context, AddSaleScreen()),
            backgroundColor: mainColor,
            elevation: 5,
            icon: const Icon(
              Icons.add_rounded,
              color: Colors.white,
            ),
            label: Text(
              tr(context, 'Add Sale'),
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: 15.w,
              vertical: 5.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsetsDirectional.all(20.r),
                  decoration: BoxDecoration(
                    color: cardBackground,
                    borderRadius: BorderRadius.circular(22.r),
                    boxShadow: [
                      BoxShadow(
                        color: mainColor.withOpacity(isDark ? 0.0 : 0.04),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: buildSummaryItem(
                          title: tr(context, 'Total Sales'),
                          value: '${salesList.length}',
                          icon: Icons.receipt_long_rounded,
                          color: mainColor,
                          background: isDark
                              ? mainColor.withOpacity(0.15)
                              : const Color(0xFFF0E9FF),
                          primaryTextColor: primaryTextColor,
                          secondaryTextColor: secondaryTextColor,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 48.h,
                        color: isDark ? Colors.white10 : Colors.grey.shade200,
                      ),
                      Expanded(
                        child: buildSummaryItem(
                          title: tr(context, 'Completed'),
                          value:
                          '${salesList.where((s) => s['status'] == 'Completed').length}',
                          icon: Icons.check_circle_outline_rounded,
                          color: const Color(0xFF059669),
                          background: isDark
                              ? const Color(0xFF059669).withOpacity(0.15)
                              : const Color(0xFFDCFCE7),
                          primaryTextColor: primaryTextColor,
                          secondaryTextColor: secondaryTextColor,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 48.h,
                        color: isDark ? Colors.white10 : Colors.grey.shade200,
                      ),
                      Expanded(
                        child: buildSummaryItem(
                          title: tr(context, 'Pending'),
                          value:
                          '${salesList.where((s) => s['status'] == 'Pending').length}',
                          icon: Icons.pending_actions_rounded,
                          color: const Color(0xFFEA580C),
                          background: isDark
                              ? const Color(0xFFEA580C).withOpacity(0.15)
                              : const Color(0xFFFFEDD5),
                          primaryTextColor: primaryTextColor,
                          secondaryTextColor: secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 22.h),
                Text(
                  tr(context, 'Search Orders'),
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w800,
                    color: primaryTextColor,
                  ),
                ),
                SizedBox(height: 12.h),
                defaultTextFormField(
                  text: tr(context, 'Search invoice or customer'),
                  prefixIcon: 'assets/icons/search.svg',
                  errorMes: '',
                  controller: searchController,
                  type: TextInputType.text,
                  cubit: appCubit,
                  onChanged: (p0) {
                    setState(() {});
                  },
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tr(context, 'Transactions'),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: primaryTextColor,
                      ),
                    ),
                    Theme(
                      data: ThemeData(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          fontFamily: 'Tajawal'
                      ),
                      child: PopupMenuButton<String>(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.r),
                        ),
                        color: cardBackground,
                        onSelected: (value) {
                          setState(() {
                            selectedFilter = value;
                          });
                        },
                        itemBuilder: (context) {
                          return filters.map((filter) {
                            return PopupMenuItem<String>(
                              value: filter,
                              child: Text(
                                tr(context, filter),
                                style: TextStyle(
                                  color: primaryTextColor,
                                  fontSize: 12.sp,
                                ),
                              ),
                            );
                          }).toList();
                        },
                        child: Container(
                          padding: EdgeInsetsDirectional.symmetric(
                            horizontal: 11.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: cardBackground,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.filter_list_rounded,
                                color: mainColor,
                                size: 17.r,
                              ),
                              SizedBox(width: 5.w),
                              Text(
                                tr(context, selectedFilter),
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: primaryTextColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 3.w),
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: secondaryTextColor,
                                size: 16.r,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                if (filteredSales.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsetsDirectional.all(30.r),
                    decoration: BoxDecoration(
                      color: cardBackground,
                      borderRadius: BorderRadius.circular(22.r),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 45.r,
                          color: secondaryTextColor,
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          tr(context, 'No Sales Found'),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: primaryTextColor,
                          ),
                        ),
                        SizedBox(height: 5.h),
                        Text(
                          tr(context, 'Try changing your search or filter options'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...filteredSales.map((sale) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 11.h),
                      child: buildSaleCard(
                        sale: sale,
                        isDark: isDark,
                        cardBackground: cardBackground,
                        primaryTextColor: primaryTextColor,
                        secondaryTextColor: secondaryTextColor,
                      ),
                    );
                  }),
                SizedBox(height: 75.h),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildSummaryItem({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color background,
    required Color primaryTextColor,
    required Color secondaryTextColor,
  }) {
    return Column(
      children: [
        Container(
          width: 35.r,
          height: 35.r,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(11.r),
          ),
          child: Icon(
            icon,
            color: color,
            size: 18.r,
          ),
        ),
        SizedBox(height: 9.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 19.sp,
            fontWeight: FontWeight.w800,
            color: primaryTextColor,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          title,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 8.5.sp,
            color: secondaryTextColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget buildSaleCard({
    required Map<String, dynamic> sale,
    required bool isDark,
    required Color cardBackground,
    required Color primaryTextColor,
    required Color secondaryTextColor,
  }) {
    final String status = sale['status'];

    final Color statusColor = status == 'Completed'
        ? const Color(0xFF059669)
        : status == 'Pending'
        ? const Color(0xFFEA580C)
        : const Color(0xFFEF4444);

    return GestureDetector(
      onTap: () => move(context, SaleDetailsScreen(sale: sale)),
      child: Container(
        padding: EdgeInsetsDirectional.all(14.r),
        decoration: BoxDecoration(
          color: cardBackground,
          borderRadius: BorderRadius.circular(21.r),
          boxShadow: [
            BoxShadow(
              color: mainColor.withOpacity(isDark ? 0.0 : 0.035),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42.r,
                      height: 42.r,
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(13.r),
                      ),
                      child: Icon(
                        Icons.shopping_bag_outlined,
                        color: statusColor,
                        size: 20.r,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sale['id'],
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w800,
                            color: primaryTextColor,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          formatSaleDate(sale['date'], AppCubit.get(context).language),
                          style: TextStyle(
                            fontSize: 9.5.sp,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsetsDirectional.symmetric(
                    horizontal: 9.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(9.r),
                  ),
                  child: Text(
                    tr(context, status),
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Divider(
              height: 1,
              color: isDark ? Colors.white10 : const Color(0xFFF1EFF6),
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr(context, 'Customer'),
                      style: TextStyle(
                        fontSize: 9.sp,
                        color: secondaryTextColor,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      tr(context, sale['customer'].toString()),
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: primaryTextColor,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      tr(context, 'Items'),
                      style: TextStyle(
                        fontSize: 9.sp,
                        color: secondaryTextColor,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      trp(context, '{n} Items', {'n': '${sale['itemsCount']}'}),
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: primaryTextColor,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      tr(context, 'Total Amount'),
                      style: TextStyle(
                        fontSize: 9.sp,
                        color: secondaryTextColor,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '\$${(sale['total'] as double).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF059669),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}