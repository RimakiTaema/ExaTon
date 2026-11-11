package net.rimaki.exatonext

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/** Home-screen widget: one server's status and credits, with Start or Stop. Data comes from the app. */
class ServerWidgetProvider : HomeWidgetProvider() {
  override fun onUpdate(
      context: Context,
      appWidgetManager: AppWidgetManager,
      appWidgetIds: IntArray,
      widgetData: SharedPreferences,
  ) {
    val name = widgetData.getString("name", null) ?: "ExaTon"
    val status = widgetData.getString("status", null) ?: "Open ExaTon to set up"
    val credits = widgetData.getString("credits", null) ?: ""
    val action = widgetData.getString("action", null) ?: ""
    val server = widgetData.getString("serverId", null) ?: ""
    val account = widgetData.getString("accountId", null) ?: ""
    val group = widgetData.getString("statusGroup", null) ?: ""

    appWidgetIds.forEach { id ->
      val views = RemoteViews(context.packageName, R.layout.server_widget).apply {
        setOnClickPendingIntent(
            R.id.widget_root, HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java))
        setTextViewText(R.id.widget_name, name)
        setTextViewText(R.id.widget_status, status)
        setTextColor(
            R.id.widget_status,
            when (group) {
              "online" -> 0xFF4ADE80.toInt()
              "crashed" -> 0xFFF87171.toInt()
              "busy" -> 0xFFFBBF24.toInt()
              else -> 0xFFB4B4BE.toInt()
            })
        setTextViewText(R.id.widget_credits, credits)
        setViewVisibility(R.id.widget_credits, if (credits.isEmpty()) View.GONE else View.VISIBLE)
        if (action.isEmpty() || server.isEmpty() || account.isEmpty()) {
          setViewVisibility(R.id.widget_action, View.GONE)
        } else {
          setViewVisibility(R.id.widget_action, View.VISIBLE)
          setTextViewText(R.id.widget_action, if (action == "start") "Start" else "Stop")
          val uri = Uri.parse("exaton://$action?server=${Uri.encode(server)}&account=${Uri.encode(account)}")
          setOnClickPendingIntent(R.id.widget_action, HomeWidgetBackgroundIntent.getBroadcast(context, uri))
        }
      }
      appWidgetManager.updateAppWidget(id, views)
    }
  }
}
