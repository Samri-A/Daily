package com.example.myhabit

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.widget.RemoteViews

class DailyWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    companion object {
        fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
            val views = RemoteViews(context.packageName, R.layout.daily_wiget)

            try {
                val dbPath = context.getDatabasePath("tasks.db").path
                val db = SQLiteDatabase.openDatabase(dbPath, null, SQLiteDatabase.OPEN_READONLY)

                
                // calculate weighted completion percentage across all tasks using priority values
                val percentCursor = db.rawQuery(
                    "SELECT SUM(priority) as total, SUM(CASE WHEN completed=1 THEN priority ELSE 0 END) as completedSum, COUNT(*) as totalCount, SUM(CASE WHEN completed=1 THEN 1 ELSE 0 END) as completedCount FROM tasks",
                    null
                )

                var pct = 0
                var percentText = "0%"
                var completedCount = 0
                var totalCount = 0
                if (percentCursor.moveToFirst()) {
                    val total = percentCursor.getDouble(0)
                    val completedSum = percentCursor.getDouble(1)
                    completedCount = percentCursor.getInt(3)
                    totalCount = percentCursor.getInt(2)
                    pct = if (total > 0.0) ((completedSum / total) * 100.0).toInt() else 0
                    percentText = "$pct%"
                }
                percentCursor.close()

                db.close()

                // Update views: big percent and progress bar and subtitle (e.g., X/Y tasks completed)
                views.setTextViewText(R.id.widget_percent, percentText)
                views.setProgressBar(R.id.widget_progress, 100, pct, false)
                views.setTextViewText(R.id.widget_subtitle, "$completedCount/$totalCount completed")
            } catch (e: Exception) {
                e.printStackTrace()
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

        fun updateAllWidgets(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val component = ComponentName(context, DailyWidgetProvider::class.java)
            val ids = manager.getAppWidgetIds(component)
            for (id in ids) {
                updateAppWidget(context, manager, id)
            }
        }

        fun resetDailyTasks(context: Context) {
            try {
                val dbPath = context.getDatabasePath("tasks.db").path
                val db = SQLiteDatabase.openDatabase(dbPath, null, SQLiteDatabase.OPEN_READWRITE)

                // Remove all non-daily tasks
                db.execSQL("DELETE FROM tasks WHERE habit = 0")

                // Reset daily tasks to incomplete
                db.execSQL("UPDATE tasks SET completed = 0 WHERE habit = 1")

                db.close()
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }
}
