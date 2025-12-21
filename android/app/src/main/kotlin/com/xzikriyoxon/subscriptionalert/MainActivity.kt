package com.xzikriyoxon.subscriptionalert

import android.app.AppOpsManager
import android.app.usage.UsageStats
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
	private val channelName = "subscription_alert/usage_stats"

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)

		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
			.setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
				when (call.method) {
					"hasUsagePermission" -> {
						result.success(hasUsagePermission())
					}
					"requestUsagePermission" -> {
						openUsageAccessSettings()
						// We can't know immediately if user granted access; caller should re-check later.
						result.success(true)
					}
					"getAppUsage" -> {
						val args = call.arguments as? Map<*, *>
						val startTime = (args?.get("startTime") as? Number)?.toLong() ?: 0L
						val endTime = (args?.get("endTime") as? Number)?.toLong() ?: System.currentTimeMillis()
						result.success(getAppUsage(startTime, endTime))
					}
					else -> result.notImplemented()
				}
			}
	}

	private fun openUsageAccessSettings() {
		try {
			val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
			intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
			startActivity(intent)
		} catch (_: Exception) {
			// Ignore: if settings page can't be opened on this device.
		}
	}

	private fun hasUsagePermission(): Boolean {
		return try {
			val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
			val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
				appOps.unsafeCheckOpNoThrow(
					AppOpsManager.OPSTR_GET_USAGE_STATS,
					android.os.Process.myUid(),
					packageName
				)
			} else {
				@Suppress("DEPRECATION")
				appOps.checkOpNoThrow(
					AppOpsManager.OPSTR_GET_USAGE_STATS,
					android.os.Process.myUid(),
					packageName
				)
			}
			mode == AppOpsManager.MODE_ALLOWED
		} catch (_: Exception) {
			false
		}
	}

	private fun getAppUsage(startTime: Long, endTime: Long): List<Map<String, Any>> {
		if (!hasUsagePermission()) return emptyList()

		val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as? UsageStatsManager
			?: return emptyList()

		val stats: List<UsageStats> = try {
			usageStatsManager.queryUsageStats(UsageStatsManager.INTERVAL_DAILY, startTime, endTime)
				?: emptyList()
		} catch (_: Exception) {
			emptyList()
		}

		if (stats.isEmpty()) return emptyList()

		val pm = applicationContext.packageManager

		return stats
			.asSequence()
			.filter { it.totalTimeInForeground > 0 }
			.map { usage ->
				val pkg = usage.packageName ?: ""
				val appName = resolveAppName(pm, pkg)
				val launchCount = resolveLaunchCount(usage)

				mapOf(
					"packageName" to pkg,
					"appName" to appName,
					"totalTimeInForeground" to usage.totalTimeInForeground,
					"launchCount" to launchCount,
					"firstTimestamp" to usage.firstTimeStamp,
					"lastTimestamp" to usage.lastTimeStamp,
				)
			}
			.toList()
	}

	private fun resolveAppName(pm: PackageManager, packageName: String): String {
		return try {
			val appInfo = pm.getApplicationInfo(packageName, 0)
			pm.getApplicationLabel(appInfo).toString()
		} catch (_: Exception) {
			packageName
		}
	}

	private fun resolveLaunchCount(usage: UsageStats): Int {
		// Launch count is not consistently available across Android versions.
		// Try reflection for best-effort; otherwise, return 0.
		return try {
			val field = UsageStats::class.java.getDeclaredField("mLaunchCount")
			field.isAccessible = true
			(field.get(usage) as? Int) ?: 0
		} catch (_: Exception) {
			0
		}
	}
}
