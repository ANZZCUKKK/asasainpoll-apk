package com.asasain.poll.view.main

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.asasain.poll.engine.NinjaEngine

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.asasain.poll/engine"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {

                // Cek permission overlay
                "checkOverlayPermission" -> {
                    val has = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        Settings.canDrawOverlays(this)
                    } else true
                    result.success(has)
                }

                // Buka settings overlay permission
                "requestOverlayPermission" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        startActivity(Intent(
                            Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                            Uri.parse("package:$packageName")
                        ))
                    }
                    result.success(null)
                }

                // Launch 8BP di sandbox + aktifkan cheat
                "startEngine" -> {
                    val esp = call.argument<Boolean>("esp") ?: false
                    val autoPlay = call.argument<Boolean>("autoPlay") ?: false
                    val autoQueue = call.argument<Boolean>("autoQueue") ?: false
                    val accuracy = call.argument<Double>("accuracy")?.toFloat() ?: 0.85f

                    NinjaEngine.isESPEnabled = esp
                    NinjaEngine.isAutoPlayEnabled = autoPlay
                    NinjaEngine.isAutoQueueEnabled = autoQueue
                    NinjaEngine.accuracyLevel = accuracy

                    val launched = NinjaEngine.launchTargetInSandbox(this)
                    if (launched) NinjaEngine.activateCheat()
                    result.success(launched)
                }

                // Stop cheat
                "stopEngine" -> {
                    NinjaEngine.deactivateCheat()
                    result.success(true)
                }

                // Cek status engine
                "getEngineStatus" -> {
                    result.success(mapOf(
                        "ready" to NinjaEngine.isEngineReady,
                        "active" to NinjaEngine.isCheatActive,
                        "nativeLoaded" to com.asasain.poll.engine.App.isNativeLoaded
                    ))
                }

                else -> result.notImplemented()
            }
        }
    }
}
