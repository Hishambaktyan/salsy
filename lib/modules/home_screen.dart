import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inventory_sales_manager/modules/scan_screen.dart';
import 'package:inventory_sales_manager/shared/cubits/appCubit/app_cubit.dart';
import 'package:inventory_sales_manager/shared/cubits/appCubit/app_states.dart';
import 'package:inventory_sales_manager/shared/styles/colors.dart';

import '../shared/compenents/compenents.dart';
import '../shared/constants.dart';
import '../shared/cubits/statsCubit/stats_cubit.dart';
import '../shared/localization/app_localizations.dart';
import 'add_product_screen.dart';
import 'add_sale.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppStates>(
      builder: (context, state) {
        final stats = context.watch<StatsCubit>();
        final hour = DateTime.now().hour;
        final greeting = hour < 12 ? 'Good Morning' : hour < 18 ? 'Good Afternoon' : 'Good Evening';
        AppCubit appCubit = AppCubit.get(context);
        bool isDark = appCubit.isDark;

        Color cardBackground = isDark ? lightDarkColor : Colors.white;
        Color primaryTextColor = isDark ? Colors.white : Colors.black;
        Color secondaryTextColor = isDark ? Colors.white60 : Colors.grey;
        Color subCardBackground = isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFBF5);

        Map<String, String> periodLabels = {
          'This Week': tr(context, 'This Week'),
          'This Month': tr(context, 'This Month'),
          'This Year': tr(context, 'This Year'),
        };

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr(context, greeting),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: secondaryTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  tr(context, 'Dashboard'),
                  style: TextStyle(
                    color: primaryTextColor,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsetsDirectional.symmetric(horizontal: 15.w, vertical: 5.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.r),
                    gradient: const LinearGradient(
                      colors: [
                        mainColor,
                        Color(0xFF042F2C),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: mainColor.withOpacity(0.28),
                        blurRadius: 28,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30.r),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -20.w,
                          top: -20.h,
                          child: Container(
                            width: 150.r,
                            height: 150.r,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.05),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 40.w,
                          bottom: -40.h,
                          child: Container(
                            width: 100.r,
                            height: 100.r,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.03),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.all(20.r),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(8.r),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(12.r),
                                        ),
                                        child: Icon(
                                          Icons.account_balance_wallet_outlined,
                                          color: Colors.white,
                                          size: 18.r,
                                        ),
                                      ),
                                      SizedBox(width: 10.w),
                                      Text(
                                        tr(context, 'Total Revenue'),
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(20.r),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 6.r,
                                          height: 6.r,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF10B981),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        SizedBox(width: 6.w),
                                        Text(
                                          tr(context, 'Live'),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 18.h),
                              Text(
                                money(stats.month.revenue),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32.sp,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -1.0,
                                ),
                              ),
                              SizedBox(height: 18.h),
                              Container(
                                padding: EdgeInsets.all(12.r),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(16.r),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.08),
                                  ),
                                ),
                                child: IntrinsicHeight(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(7.r),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(10.r),
                                              ),
                                              child: Icon(
                                                Icons.receipt_long_rounded,
                                                color: Colors.white.withOpacity(0.9),
                                                size: 16.r,
                                              ),
                                            ),
                                            SizedBox(width: 10.w),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  tr(context, 'Orders'),
                                                  style: TextStyle(
                                                    color: Colors.white.withOpacity(0.6),
                                                    fontSize: 10.sp,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                SizedBox(height: 2.h),
                                                Text(
                                                  stats.month.orders.toString(),
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 13.sp,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      VerticalDivider(
                                        color: Colors.white.withOpacity(0.12),
                                        thickness: 1,
                                        width: 16.w,
                                      ),
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(7.r),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(10.r),
                                              ),
                                              child: Icon(
                                                Icons.payments_outlined,
                                                color: Colors.white.withOpacity(0.9),
                                                size: 16.r,
                                              ),
                                            ),
                                            SizedBox(width: 10.w),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  tr(context, 'Avg. Order'),
                                                  style: TextStyle(
                                                    color: Colors.white.withOpacity(0.6),
                                                    fontSize: 10.sp,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                SizedBox(height: 2.h),
                                                Text(
                                                  money(stats.month.avg),
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 13.sp,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tr(context, 'Overview'),
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
                        onSelected: (String value) {
                          stats.loadHome(context,period: value);
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.r),
                        ),
                        color: cardBackground,
                        itemBuilder: (BuildContext context) => [
                          PopupMenuItem<String>(
                            value: 'This Week',
                            child: Text(
                              tr(context, 'This Week'),
                              style: TextStyle(color: primaryTextColor, fontSize: 12.sp),
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'This Month',
                            child: Text(
                              tr(context, 'This Month'),
                              style: TextStyle(color: primaryTextColor, fontSize: 12.sp),
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'This Year',
                            child: Text(
                              tr(context, 'This Year'),
                              style: TextStyle(color: primaryTextColor, fontSize: 12.sp),
                            ),
                          ),
                        ],
                        child: Container(
                          padding: EdgeInsetsDirectional.symmetric(
                            horizontal: 11.w,
                            vertical: 7.h,
                          ),
                          decoration: BoxDecoration(
                            color: cardBackground,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                periodLabels[stats.selectedHomePeriod] ?? tr(context, 'This Month'),
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: secondaryTextColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 5.w),
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 17.r,
                                color: secondaryTextColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15.h),
                Row(
                  children: [
                    Expanded(
                      child: buildStatCard(
                        title: tr(context, 'Total Products'),
                        value: stats.totalProducts.toString(),
                        subtitle: tr(context, 'Items in stock'),
                        icon: Icons.inventory_2_outlined,
                        color: mainColor,
                        isDark: isDark,
                        iconBackground: isDark ? mainColor.withOpacity(0.15) : const Color(0xFFF0E9FF),
                        primaryTextColor: primaryTextColor,
                        secondaryTextColor: secondaryTextColor,
                        cardBackground: cardBackground,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: buildStatCard(
                        title: tr(context, 'Total Sales'),
                        value: stats.month.orders.toString(),
                        subtitle: stats.getPeriodOrdersSubtitle(context),
                        icon: Icons.shopping_bag_outlined,
                        color: const Color(0xFF0891B2),
                        isDark: isDark,
                        iconBackground: isDark ? const Color(0xFF0891B2).withOpacity(0.15) : const Color(0xFFE0F7FA),
                        primaryTextColor: primaryTextColor,
                        secondaryTextColor: secondaryTextColor,
                        cardBackground: cardBackground,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Expanded(
                      child: buildStatCard(
                        title: tr(context, 'Net Profit'),
                        value: money(stats.month.net),
                        subtitle: stats.growthText(stats.month.net, stats.prevMonth.net,context ,suffix: stats.getPeriodSuffix(context)),
                        icon: Icons.trending_up_rounded,
                        color: const Color(0xFF059669),
                        isDark: isDark,
                        iconBackground: isDark ? const Color(0xFF059669).withOpacity(0.15) : const Color(0xFFDCFCE7),
                        primaryTextColor: primaryTextColor,
                        secondaryTextColor: secondaryTextColor,
                        cardBackground: cardBackground,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: buildStatCard(
                        title: tr(context, 'Low Stock'),
                        value: stats.lowStockCount.toString(),
                        subtitle: tr(context, 'Need restocking'),
                        icon: Icons.warning_amber_rounded,
                        color: const Color(0xFFEA580C),
                        isDark: isDark,
                        iconBackground: isDark ? const Color(0xFFEA580C).withOpacity(0.15) : const Color(0xFFFFEDD5),
                        primaryTextColor: primaryTextColor,
                        secondaryTextColor: secondaryTextColor,
                        cardBackground: cardBackground,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 25.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tr(context, 'Quick Actions'),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: primaryTextColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15.h),
                Row(
                  children: [
                    Expanded(
                      child: buildQuickAction(
                        icon: Icons.add_box_outlined,
                        title: tr(context, 'Add Product'),
                        color: mainColor,
                        background: isDark ? mainColor.withOpacity(0.15) : const Color(0xFFF0E9FF),
                        cardBackground: cardBackground,
                        primaryTextColor: primaryTextColor,
                        onTap: () => move(context, const AddProductScreen()),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: buildQuickAction(
                        icon: Icons.point_of_sale_rounded,
                        title: tr(context, 'New Sale'),
                        color: const Color(0xFF059669),
                        background: isDark ? const Color(0xFF059669).withOpacity(0.15) : const Color(0xFFDCFCE7),
                        cardBackground: cardBackground,
                        primaryTextColor: primaryTextColor,
                        onTap: () => move(context, const AddSaleScreen()),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: buildQuickAction(
                        icon: Icons.barcode_reader,
                        title: tr(context, 'Scan Item'),
                        color: const Color(0xFF0284C7),
                        background: isDark ? const Color(0xFF0284C7).withOpacity(0.15) : const Color(0xFFE0F2FE),
                        cardBackground: cardBackground,
                        primaryTextColor: primaryTextColor,
                        onTap: () => move(context, const ScanScreen()),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 25.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tr(context, 'Recent Sales'),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: primaryTextColor,
                      ),
                    ),
                    Text(
                      tr(context, 'See All'),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: mainColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 15.w,
                    vertical: 5.h,
                  ),
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
                  child: Column(
                    children: [
                      if (stats.recentItems.isEmpty)
                        Padding(
                          padding: EdgeInsetsDirectional.all(20.r),
                          child: Text(tr(context, 'No sales yet'),
                              style: TextStyle(color: secondaryTextColor)),
                        ),
                      for (int i = 0; i < stats.recentItems.length; i++) ...[
                        if (i > 0)
                          Divider(height: 1, color: isDark ? Colors.white10 : const Color(0xFFF1EFF6)),
                        buildSaleItem(
                          name: stats.recentItems[i]['name'],
                          category: tr(context, stats.recentItems[i]['category']),
                          date: formatSaleDate(stats.recentItems[i]['date'], appCubit.language),
                          amount: money(stats.recentItems[i]['total'] as num),
                          icon: categoryIcon(stats.recentItems[i]['category']),
                          color: categoryColor(stats.recentItems[i]['category']),
                          primaryTextColor: primaryTextColor,
                          secondaryTextColor: secondaryTextColor,
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 25.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tr(context, 'Low Stock Alert'),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: primaryTextColor,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: secondaryTextColor,
                      size: 14.r,
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                if (stats.lowStockItems.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: Text(
                      tr(context, 'All products are well stocked'),
                      style: TextStyle(fontSize: 12.sp, color: secondaryTextColor),
                    ),
                  ),
                ...stats.lowStockItems.map((item) {
                  final int qty = item['quantity'] as int;
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Container(
                      padding: EdgeInsetsDirectional.all(15.r),
                      decoration: BoxDecoration(
                        color: subCardBackground,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 43.r,
                            height: 43.r,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEA580C).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(13.r),
                            ),
                            child: Icon(Icons.inventory_2_outlined,
                                color: const Color(0xFFEA580C), size: 21.r),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['name'],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w700,
                                    color: primaryTextColor,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  qty == 0
                                      ? tr(context, 'Out of stock')
                                      : trp(context, 'Only {n} items remaining', {'n': '$qty'}),
                                  style: TextStyle(fontSize: 11.sp, color: secondaryTextColor),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsetsDirectional.symmetric(horizontal: 9.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEA580C).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(9.r),
                            ),
                            child: Text(
                              qty == 0 ? tr(context, 'Out') : tr(context, 'Low'),
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFEA580C),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isDark,
    required Color iconBackground,
    required Color primaryTextColor,
    required Color secondaryTextColor,
    required Color cardBackground,
  }) {
    return Container(
      padding: EdgeInsetsDirectional.all(15.r),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 39.r,
            height: 39.r,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20.r,
            ),
          ),
          SizedBox(height: 15.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              color: primaryTextColor,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: primaryTextColor,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9.5.sp,
              color: secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildQuickAction({
    required IconData icon,
    required String title,
    required Color color,
    required Color background,
    required Color cardBackground,
    required Color primaryTextColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsetsDirectional.symmetric(vertical: 15.h, horizontal: 5.w),
        decoration: BoxDecoration(
          color: cardBackground,
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: Column(
          children: [
            Container(
              width: 43.r,
              height: 43.r,
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(
                icon,
                color: color,
                size: 21.r,
              ),
            ),
            SizedBox(height: 9.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
                color: primaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSaleItem({
    required String name,
    required String category,
    required String date,
    required String amount,
    required IconData icon,
    required Color color,
    required Color primaryTextColor,
    required Color secondaryTextColor,
  }) {
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(vertical: 13.h),
      child: Row(
        children: [
          Container(
            width: 43.r,
            height: 43.r,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              icon,
              color: color,
              size: 21.r,
            ),
          ),
          SizedBox(width: 11.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: primaryTextColor,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  '$category • $date',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9.5.sp,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 7.w),
          Text(
            amount,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF059669),
            ),
          ),
        ],
      ),
    );
  }
}