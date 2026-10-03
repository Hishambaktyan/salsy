import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_sales_manager/shared/constants.dart';
import 'package:inventory_sales_manager/shared/localization/app_localizations.dart';
import 'package:inventory_sales_manager/shared/networks/local/db_helper.dart';
import '../../services/notification_service.dart';
import 'stats_states.dart';

class Summary {
  final double revenue, gross, discounts;
  final int orders;
  const Summary({this.revenue = 0, this.gross = 0, this.discounts = 0, this.orders = 0});
  double get net => gross - discounts;
  double get avg => orders == 0 ? 0 : revenue / orders;
}

class StatsCubit extends Cubit<StatsStates> {
  StatsCubit() : super(StatsInitial());

  static StatsCubit get(context) => BlocProvider.of(context);

  Summary month = const Summary();
  Summary prevMonth = const Summary();
  int totalProducts = 0, stockItems = 0, lowStockCount = 0;
  List<Map<String, dynamic>> recentItems = [], lowStockItems = [];

  String selectedHomePeriod = 'This Month';

  String period = 'This Month';
  Summary cur = const Summary();
  Summary prev = const Summary();
  List<double> chartValues = [];
  List<String> chartLabels = [];
  List<Map<String, dynamic>> topProducts = [], categoryStats = [];

  String growthText(
      double c,
      double p,
      BuildContext context, {
        String? suffix,
      }) {
    final label = suffix ?? tr(context, 'from last period');
    final g = p == 0 ? (c == 0 ? 0.0 : 100.0) : (c - p) / p * 100;
    return '${g >= 0 ? '+' : ''}${g.toStringAsFixed(1)}% $label';
  }
  String getPeriodSuffix(BuildContext context) {
    switch (selectedHomePeriod) {
      case 'This Week':
        return tr(context, 'this week');
      case 'This Year':
        return tr(context, 'this year');
      default:
        return tr(context, 'this month');
    }
  }

  String getPeriodOrdersSubtitle(BuildContext context) {
    switch (selectedHomePeriod) {
      case 'This Week':
        return tr(context, 'Orders this week');
      case 'This Year':
        return tr(context, 'Orders this year');
      default:
        return tr(context, 'Orders this month');
    }
  }

  Future<void> loadAll(BuildContext context) async {
    try {
      await loadHome(context);
      await loadStats(period);
    } catch (e) {
      emit(StatsError(e.toString()));
    }
  }

  (DateTime, DateTime) _range(String period, {bool previous = false}) {
    final now = DateTime.now();
    switch (period) {
      case 'This Week':
        final base = DateTime(now.year, now.month,
            now.day - (now.weekday - 1) - (previous ? 7 : 0));
        return (base, DateTime(base.year, base.month, base.day + 7));
      case 'This Year':
        final y = previous ? now.year - 1 : now.year;
        return (DateTime(y), DateTime(y + 1));
      default:
        final m = previous ? now.month - 1 : now.month;
        return (DateTime(now.year, m, 1), DateTime(now.year, m + 1, 1));
    }
  }

  double _d(Object? v) => (v as num?)?.toDouble() ?? 0;

  Future<Summary> _summary(DateTime from, DateTime to) async {
    final args = [from.toIso8601String(), to.toIso8601String()];
    final s = await DbHelper.db.rawQuery('''
      SELECT COALESCE(SUM(total),0) AS revenue,
             COALESCE(SUM(discount),0) AS discounts,
             COUNT(*) AS orders
      FROM sales WHERE status = 'Completed' AND date >= ? AND date < ?''', args);
    final g = await DbHelper.db.rawQuery('''
      SELECT COALESCE(SUM((si.price - si.cost) * si.quantity),0) AS gross
      FROM sale_items si JOIN sales s ON s.id = si.saleId
      WHERE s.status = 'Completed' AND s.date >= ? AND s.date < ?''', args);
    return Summary(
      revenue: _d(s.first['revenue']),
      discounts: _d(s.first['discounts']),
      orders: (s.first['orders'] as int?) ?? 0,
      gross: _d(g.first['gross']),
    );
  }

  Future<void> loadHome(BuildContext context,{String? period}) async {
    if (period != null) {
      selectedHomePeriod = period;
    }
    final r = _range(selectedHomePeriod);
    final p = _range(selectedHomePeriod, previous: true);
    month = await _summary(r.$1, r.$2);
    prevMonth = await _summary(p.$1, p.$2);

    final pr = await DbHelper.db.rawQuery('''
      SELECT COUNT(*) AS c, COALESCE(SUM(quantity),0) AS q,
             COALESCE(SUM(CASE WHEN quantity <= ? THEN 1 ELSE 0 END),0) AS low
      FROM products''', [lowStockLimit]);
    totalProducts = pr.first['c'] as int;
    stockItems = (pr.first['q'] as num).toInt();
    lowStockCount = (pr.first['low'] as num).toInt();

    lowStockItems = await DbHelper.db.query('products',
        columns: ['name', 'quantity'],
        where: 'quantity <= ?',
        whereArgs: [lowStockLimit],
        orderBy: 'quantity ASC',
        limit: 3);

    recentItems = await DbHelper.db.rawQuery('''
      SELECT si.name AS name, COALESCE(p.category,'Other') AS category,
             si.total AS total, s.date AS date
      FROM sale_items si
      JOIN sales s ON s.id = si.saleId
      LEFT JOIN products p ON p.id = si.productId
      WHERE s.status != 'Cancelled'
      ORDER BY s.date DESC, si.id DESC LIMIT 3''');
    emit(StatsLoaded());

    NotificationService().scheduleDailyEodSummary(
      hour: 21,
      minute: 0,
      title: tr(context, 'notif_eod_title'),
      body: trp(context, 'notif_eod_body', {
        'orders': month.orders.toString(),
        'revenue': month.revenue.toStringAsFixed(2),
      }),
    );
  }

  Future<void> loadStats(String newPeriod) async {
    period = newPeriod;
    final r = _range(period);
    final p = _range(period, previous: true);
    cur = await _summary(r.$1, r.$2);
    prev = await _summary(p.$1, p.$2);
    final args = [r.$1.toIso8601String(), r.$2.toIso8601String()];

    final rows = await DbHelper.db.query('sales',
        columns: ['date', 'total'],
        where: "status = 'Completed' AND date >= ? AND date < ?",
        whereArgs: args);
    late List<String> labels;
    late int Function(DateTime) idx;
    switch (period) {
      case 'This Week':
        labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        idx = (d) => d.weekday - 1;
        break;
      case 'This Year':
        labels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        idx = (d) => d.month - 1;
        break;
      default:
        labels = ['W1', 'W2', 'W3', 'W4'];
        idx = (d) => math.min(3, (d.day - 1) ~/ 7);
    }
    final values = List<double>.filled(labels.length, 0);
    for (final row in rows) {
      values[idx(DateTime.parse(row['date'] as String))] += _d(row['total']);
    }
    chartLabels = labels;
    chartValues = values;

    final top = await DbHelper.db.rawQuery('''
      SELECT si.name AS name, COALESCE(p.category,'Other') AS category,
             SUM(si.quantity) AS sales, SUM(si.total) AS revenue
      FROM sale_items si
      JOIN sales s ON s.id = si.saleId
      LEFT JOIN products p ON p.id = si.productId
      WHERE s.status = 'Completed' AND s.date >= ? AND s.date < ?
      GROUP BY si.productId, si.name
      ORDER BY sales DESC LIMIT 4''', args);
    topProducts = top
        .map((e) => {
      'name': e['name'],
      'category': e['category'],
      'sales': e['sales'],
      'revenue': _d(e['revenue']),
      'icon': categoryIcon(e['category'] as String?),
      'color': categoryColor(e['category'] as String?),
    })
        .toList();

    final cats = await DbHelper.db.rawQuery('''
      SELECT COALESCE(p.category,'Other') AS category, SUM(si.total) AS amount
      FROM sale_items si
      JOIN sales s ON s.id = si.saleId
      LEFT JOIN products p ON p.id = si.productId
      WHERE s.status = 'Completed' AND s.date >= ? AND s.date < ?
      GROUP BY category ORDER BY amount DESC''', args);
    final total = cats.fold<double>(0, (a, e) => a + _d(e['amount']));
    categoryStats = cats
        .map((e) => {
      'category': e['category'],
      'percentage': total == 0 ? 0.0 : _d(e['amount']) / total * 100,
      'amount': money(_d(e['amount'])),
      'color': categoryColor(e['category'] as String?),
    })
        .toList();
    emit(StatsLoaded());
  }
}