import 'dart:math' as math show max;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inventory_sales_manager/shared/cubits/appCubit/app_cubit.dart';
import 'package:inventory_sales_manager/shared/cubits/appCubit/app_states.dart';
import 'package:inventory_sales_manager/shared/styles/colors.dart';

import '../shared/constants.dart';
import '../shared/cubits/statsCubit/stats_cubit.dart';
import '../shared/localization/app_localizations.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int touchedPieIndex = -1;

  final List<String> periods = [
    'This Week',
    'This Month',
    'This Year',
  ];

  late String selectedPeriod;

  @override
  void initState() {
    super.initState();
    selectedPeriod = context.read<StatsCubit>().period;
  }

  StatsCubit get stats => context.read<StatsCubit>();
  List<Map<String, dynamic>> get topProducts => stats.topProducts;
  List<Map<String, dynamic>> get categoryStats => stats.categoryStats;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppStates>(
      builder: (context, state) {
        final s = context.watch<StatsCubit>();
        AppCubit appCubit = AppCubit.get(context);
        bool isDark = appCubit.isDark;

        Color cardBackground = isDark ? lightDarkColor : Colors.white;
        Color primaryTextColor = isDark ? Colors.white : Colors.black;
        Color secondaryTextColor = isDark ? Colors.white60 : Colors.grey;

        final values = s.chartValues;
        final labels = s.chartLabels;
        final maxV = values.isEmpty ? 0.0 : values.reduce(math.max);
        final maxY = maxV == 0 ? 1.0 : maxV * 1.25;
        final maxX = labels.isEmpty ? 1.0 : (labels.length - 1).toDouble();

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr(context, 'Reports & analytics'),
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: secondaryTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  tr(context, 'Statistics'),
                  style: TextStyle(
                    color: primaryTextColor,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            actions: [
              PopupMenuButton<String>(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.r),
                ),
                color: cardBackground,
                onSelected: (value) {
                  setState(() {
                    selectedPeriod = value;
                    StatsCubit.get(context).loadStats(selectedPeriod);
                  });
                },
                itemBuilder: (context) {
                  return periods.map((period) {
                    return PopupMenuItem<String>(
                      value: period,
                      child: Text(
                        tr(context, period),
                        style: TextStyle(
                          color: primaryTextColor,
                          fontSize: 12.sp,
                        ),
                      ),
                    );
                  }).toList();
                },
                child: Container(
                  margin: EdgeInsetsDirectional.only(end: 15.w),
                  padding: EdgeInsetsDirectional.symmetric(
                    horizontal: 11.w,
                    vertical: 7.h,
                  ),
                  decoration: BoxDecoration(
                    color: cardBackground,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: mainColor.withOpacity(isDark ? 0.0 : 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Text(
                        tr(context, selectedPeriod),
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: primaryTextColor,
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
            ],
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
                        Padding(
                          padding: EdgeInsetsDirectional.all(20.r),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                      Icons.show_chart_rounded,
                                      color: Colors.white,
                                      size: 18.r,
                                    ),
                                  ),
                                  SizedBox(width: 10.w),
                                  Text(
                                    tr(context, 'Net Growth'),
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 18.h),
                              Text(
                                money(s.cur.revenue),
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
                                        child: buildGradientSummaryItem(
                                          title: tr(context, 'Gross Profit'),
                                          value: money(s.cur.gross),
                                          icon: Icons.attach_money_rounded,
                                        ),
                                      ),
                                      VerticalDivider(
                                        color: Colors.white.withOpacity(0.12),
                                        thickness: 1,
                                        width: 16.w,
                                      ),
                                      Expanded(
                                        child: buildGradientSummaryItem(
                                          title: tr(context, 'Discounts'),
                                          value: money(s.cur.discounts),
                                          icon: Icons.money_off_rounded,
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
                Text(
                  tr(context, 'Revenue Overview'),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: primaryTextColor,
                  ),
                ),
                SizedBox(height: 12.h),
                Container(
                  height: 220.h,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
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
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: isDark ? Colors.white10 : Colors.grey.shade200,
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 42.w,
                            getTitlesWidget: (value, meta) {
                              final t = value >= 1000
                                  ? '\$${(value / 1000).toStringAsFixed(1)}k'
                                  : '\$${value.toInt()}';
                              return Text(t, style: TextStyle(color: secondaryTextColor, fontSize: 9.sp));
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              final i = value.toInt();
                              if (i >= 0 && i < labels.length) {
                                return Padding(
                                  padding: EdgeInsets.only(top: 8.h),
                                  child: Text(
                                    tr(context, labels[i]),
                                    style: TextStyle(color: secondaryTextColor, fontSize: 8.sp),
                                  ),
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      minX: 0,
                      maxX: maxX,
                      minY: 0,
                      maxY: maxY,
                      lineBarsData: [
                        LineChartBarData(
                          spots: values.isEmpty
                              ? [const FlSpot(0, 0)]
                              : List.generate(values.length, (i) => FlSpot(i.toDouble(), values[i])),
                          isCurved: true,
                          color: mainColor,
                          barWidth: 3.5,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: mainColor.withOpacity(0.15),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    Expanded(
                      child: buildStatCard(
                        title: tr(context, 'Total Revenue'),
                        value: money(s.cur.revenue),
                        subtitle: s.growthText(s.cur.revenue, s.prev.revenue,context),
                        icon: Icons.account_balance_wallet_outlined,
                        color: mainColor,
                        isDark: isDark,
                        iconBackground: isDark
                            ? mainColor.withOpacity(0.15)
                            : const Color(0xFFF0E9FF),
                        primaryTextColor: primaryTextColor,
                        secondaryTextColor: secondaryTextColor,
                        cardBackground: cardBackground,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: buildStatCard(
                        title: tr(context, 'Total Sales'),
                        value: s.cur.orders.toString(),
                        subtitle: s.growthText(s.cur.orders.toDouble(), s.prev.orders.toDouble(),context),
                        icon: Icons.shopping_bag_outlined,
                        color: const Color(0xFF0891B2),
                        isDark: isDark,
                        iconBackground: isDark
                            ? const Color(0xFF0891B2).withOpacity(0.15)
                            : const Color(0xFFE0F7FA),
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
                        value: money(s.cur.net),
                        subtitle: s.growthText(s.cur.net, s.prev.net,context),
                        icon: Icons.trending_up_rounded,
                        color: const Color(0xFF059669),
                        isDark: isDark,
                        iconBackground: isDark
                            ? const Color(0xFF059669).withOpacity(0.15)
                            : const Color(0xFFDCFCE7),
                        primaryTextColor: primaryTextColor,
                        secondaryTextColor: secondaryTextColor,
                        cardBackground: cardBackground,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: buildStatCard(
                        title: tr(context, 'Avg. Order Value'),
                        value: money(s.cur.avg),
                        subtitle: s.growthText(s.cur.avg, s.prev.avg,context),
                        icon: Icons.analytics_outlined,
                        color: const Color(0xFFEA580C),
                        isDark: isDark,
                        iconBackground: isDark
                            ? const Color(0xFFEA580C).withOpacity(0.15)
                            : const Color(0xFFFFEDD5),
                        primaryTextColor: primaryTextColor,
                        secondaryTextColor: secondaryTextColor,
                        cardBackground: cardBackground,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 25.h),
                Text(
                  tr(context, 'Sales by Category'),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: primaryTextColor,
                  ),
                ),
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsetsDirectional.all(16.r),
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
                  child: categoryStats.isEmpty
                      ? Center(child: Text(tr(context, 'No data yet')))
                      : Row(
                    children: [
                      SizedBox(
                        height: 150.r,
                        width: 150.r,
                        child: PieChart(
                          PieChartData(
                            pieTouchData: PieTouchData(
                              touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                setState(() {
                                  if (!event.isInterestedForInteractions ||
                                      pieTouchResponse == null ||
                                      pieTouchResponse.touchedSection == null) {
                                    touchedPieIndex = -1;
                                    return;
                                  }
                                  touchedPieIndex = pieTouchResponse
                                      .touchedSection!.touchedSectionIndex;
                                });
                              },
                            ),
                            sectionsSpace: 3,
                            centerSpaceRadius: 35.r,
                            sections: List.generate(categoryStats.length, (i) {
                              final isTouched = i == touchedPieIndex;
                              final radius = isTouched ? 40.r : 32.r;
                              final item = categoryStats[i];
                              return PieChartSectionData(
                                color: item['color'],
                                value: item['percentage'],
                                title: '${item['percentage'].toInt()}%',
                                radius: radius,
                                titleStyle: TextStyle(
                                  fontSize: isTouched ? 12.sp : 10.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          children: categoryStats.map((item) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 4.h),
                              child: Row(
                                children: [
                                  Container(
                                    width: 10.r,
                                    height: 10.r,
                                    decoration: BoxDecoration(
                                      color: item['color'],
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text(
                                      tr(context, item['category']),
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w600,
                                        color: primaryTextColor,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    item['amount'],
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w700,
                                      color: secondaryTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 25.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tr(context, 'Top Selling Products'),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: primaryTextColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Container(
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
                  child: topProducts.isEmpty
                      ? Padding(
                    padding: EdgeInsets.symmetric(vertical: 15.h),
                    child: Center(child: Text(tr(context, 'No data yet'))),
                  )
                      : Column(
                    children: List.generate(topProducts.length, (index) {
                      final product = topProducts[index];
                      final isLast = index == topProducts.length - 1;

                      return Column(
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.symmetric(
                              vertical: 13.h,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 43.r,
                                  height: 43.r,
                                  decoration: BoxDecoration(
                                    color: (product['color'] as Color)
                                        .withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(14.r),
                                  ),
                                  child: Icon(
                                    product['icon'],
                                    color: product['color'],
                                    size: 21.r,
                                  ),
                                ),
                                SizedBox(width: 11.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product['name'],
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
                                        '${tr(context, product['category'])} • ${trp(context, '{n} Sold', {'n': product['sales'].toString()})}',
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
                                  '\$${(product['revenue'] as double).toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF059669),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!isLast)
                            Divider(
                              height: 1,
                              color: isDark
                                  ? Colors.white10
                                  : const Color(0xFFF1EFF6),
                            ),
                        ],
                      );
                    }),
                  ),
                ),
                SizedBox(height: 25.h),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildGradientSummaryItem({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(7.r),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(
            icon,
            color: Colors.white.withOpacity(0.9),
            size: 16.r,
          ),
        ),
        SizedBox(width: 10.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
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
}