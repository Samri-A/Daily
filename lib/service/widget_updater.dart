import 'dart:io';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'package:myhabit/service/task_db.dart';

class WidgetUpdater {
  static const _channel = MethodChannel('com.example.myhabit/widget');
  static const _appGroupId = 'group.com.example.myhabit';

  static Future<void> refresh() async {
    if (Platform.isAndroid) {
      try {
        await _channel.invokeMethod('refreshWidget');
      } catch (_) {}
    } else if (Platform.isIOS) {
      await _pushIOSData();
    }
  }

  static Future<void> _pushIOSData() async {
    try {
      final db = await TaskDatabase.instance.database;
      final rows = await db.rawQuery(
        "SELECT SUM(priority) as total, "
        "SUM(CASE WHEN completed=1 THEN priority ELSE 0 END) as completedSum, "
        "COUNT(*) as cnt, "
        "SUM(CASE WHEN completed=1 THEN 1 ELSE 0 END) as completedCnt "
        "FROM tasks",
      );

      int completed = 0, total = 0, pct = 0;
      if (rows.isNotEmpty) {
        final r = rows.first;
        total = (r['cnt'] as int?) ?? 0;
        completed = (r['completedCnt'] as int?) ?? 0;
        final totalPri = (r['total'] as num?)?.toDouble() ?? 0.0;
        final completedPri = (r['completedSum'] as num?)?.toDouble() ?? 0.0;
        pct = totalPri > 0 ? ((completedPri / totalPri) * 100).round() : 0;
      }

      HomeWidget.setAppGroupId(_appGroupId);
      await HomeWidget.saveWidgetData<int>('completedCount', completed);
      await HomeWidget.saveWidgetData<int>('totalCount', total);
      await HomeWidget.saveWidgetData<int>('percentage', pct);
      await HomeWidget.updateWidget(iOSName: 'DailyWidget');
    } catch (_) {}
  }
}
