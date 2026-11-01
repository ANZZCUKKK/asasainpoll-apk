package com.asasain.poll.engine

import android.content.Context
import android.content.Intent
import android.os.Build
import com.asasain.poll.proxy.VirtualAppManager

object NinjaEngine {

    // Target package yang akan dijalankan di dalam sandbox
    const val TARGET_PACKAGE = "com.miniclip.eightballpool"

    // Status engine
    var isEngineReady = false
        private set

    var isCheatActive = false

    // Fitur toggle — clone dari assets/images yang ditemukan di APK original
    var isESPEnabled = false
    var isAutoPlayEnabled = false
    var isAutoQueueEnabled = false
    var accuracyLevel = 0.85f

    fun init(context: Context) {
        // 1. Init VirtualApp sandbox layer
        VirtualAppManager.init(context)

        // 2. Start daemon service untuk keep-alive
        startDaemon(context)

        // 3. Native engine init via JNI (hanya jika lib berhasil dimuat)
        if (App.isNativeLoaded) {
            nativeInit()
        }

        isEngineReady = true
    }

    // Mulai 8 Ball Pool di dalam VirtualApp sandbox
    fun launchTargetInSandbox(context: Context): Boolean {
        return VirtualAppManager.launchApp(context, TARGET_PACKAGE)
    }

    // Aktifkan semua cheat via native hook
    fun activateCheat(): Boolean {
        if (!App.isNativeLoaded) return false
        isCheatActive = true
        return nativeActivateCheat(isESPEnabled, isAutoPlayEnabled, isAutoQueueEnabled, accuracyLevel)
    }

    // Matikan semua cheat
    fun deactivateCheat() {
        isCheatActive = false
        if (App.isNativeLoaded) nativeDeactivateCheat()
    }

    private fun startDaemon(context: Context) {
        val intent = Intent(context, DaemonService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            context.startForegroundService(intent)
        } else {
            context.startService(intent)
        }
    }

    // ─── JNI Declarations ────────────────────────────────────────
    // Semua fungsi ini diimplementasikan di libninja.so

    // Init native engine — setup hook table dan memory scanner
    @JvmStatic
    external fun nativeInit()

    // Aktifkan cheat dengan konfigurasi fitur
    @JvmStatic
    external fun nativeActivateCheat(
        esp: Boolean,
        autoPlay: Boolean,
        autoQueue: Boolean,
        accuracy: Float
    ): Boolean

    // Deaktifkan semua cheat dan bersihkan hook
    @JvmStatic
    external fun nativeDeactivateCheat()

    // Cek apakah target proses sedang berjalan di sandbox
    @JvmStatic
    external fun nativeIsTargetRunning(): Boolean

    // Inject hook ke render thread target (dipanggil setelah sandbox launch)
    @JvmStatic
    external fun nativeInjectHook(targetPid: Int): Boolean
}
