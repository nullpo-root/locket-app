package com.example.locket_app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.graphics.BitmapFactory
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import java.io.File

class LocketAppWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            // Retrieve shared widget data saved by Flutter HomeWidget plugin
            val widgetData = HomeWidgetPlugin.getData(context)
            val senderName = widgetData.getString("sender_name", "Friend")
            val timeAgo = widgetData.getString("time_ago", "Recently")
            val imagePath = widgetData.getString("image_path", null)

            val views = RemoteViews(context.packageName, R.layout.locket_widget)
            views.setTextViewText(R.id.widget_sender, senderName)
            views.setTextViewText(R.id.widget_time, timeAgo)

            // Load and display bitmap image if file exists
            if (imagePath != null && File(imagePath).exists()) {
                val bitmap = BitmapFactory.decodeFile(imagePath)
                if (bitmap != null) {
                    views.setImageViewBitmap(R.id.widget_image, bitmap)
                    views.setViewVisibility(R.id.widget_placeholder, View.GONE)
                    views.setViewVisibility(R.id.widget_image, View.VISIBLE)
                }
            } else {
                views.setViewVisibility(R.id.widget_placeholder, View.VISIBLE)
            }

            // Launch app when tapping on the widget
            val launchIntent = Intent(context, MainActivity::class.java).apply {
                action = Intent.ACTION_VIEW
                data = Uri.parse("locket://open")
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }

            val pendingIntent = PendingIntent.getActivity(
                context,
                0,
                launchIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_container, pendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
