import 'dart:async';
import 'task_db.dart';
import 'widget_updater.dart';

class DailyResetService {
  static final DailyResetService instance = DailyResetService._();
  DailyResetService._();

  Timer? _timer;

  Future<void> init() async {
    await _checkAndReset();
    _scheduleMidnightTimer();
  }

  Future<void> _checkAndReset() async {
    final today = _todayString();
    final lastReset = await TaskDatabase.instance.getMetadata('last_reset');
    if (lastReset != today) {
      await TaskDatabase.instance.resetDailyTasks();
      await TaskDatabase.instance.setMetadata('last_reset', today);
      await WidgetUpdater.refresh();
    }
  }

  void _scheduleMidnightTimer() {
    _timer?.cancel();
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    _timer = Timer(nextMidnight.difference(now), _onMidnight);
  }

  Future<void> _onMidnight() async {
    await TaskDatabase.instance.resetDailyTasks();
    await TaskDatabase.instance.setMetadata('last_reset', _todayString());
    await WidgetUpdater.refresh();
    _scheduleMidnightTimer();
  }

  String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  void dispose() {
    _timer?.cancel();
  }
}
