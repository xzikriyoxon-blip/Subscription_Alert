package com.example.subscription_alert

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class SubscriptionWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.subscription_widget)
            
            // Get data from SharedPreferences (set by Flutter via home_widget)
            val nextRenewalName = widgetData.getString("nextRenewalName", "No subscriptions") ?: "No subscriptions"
            val nextRenewalDate = widgetData.getString("nextRenewalDate", "") ?: ""
            val monthlyTotal = widgetData.getString("monthlyTotal", "\$0.00") ?: "\$0.00"
            val subscriptionsCount = widgetData.getInt("subscriptionsCount", 0)
            
            // Update widget views
            views.setTextViewText(R.id.next_renewal_name, nextRenewalName)
            views.setTextViewText(R.id.next_renewal_date, nextRenewalDate)
            views.setTextViewText(R.id.monthly_total_amount, monthlyTotal)
            views.setTextViewText(
                R.id.subscriptions_count, 
                "$subscriptionsCount active subscription${if (subscriptionsCount != 1) "s" else ""}"
            )
            
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
