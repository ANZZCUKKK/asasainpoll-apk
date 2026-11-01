package com.asasain.poll.engine

import android.app.Application
import android.content.Context
import android.util.Log

class App : Application() {

    companion object {
        // Instance global untuk akses context di seluruh app
        lateinit var instance: App
            private set

        // Flag apakah native library berhasil dimuat
        var isNativeLoaded = false
            private set
    }

    override fun attachBaseContext(base: Context) {
        super.attachBaseContext(base)
        // Inisialisasi VirtualApp engine sebelum Application onCreate
        // Ini clone behaviour com.ninja.engine.app.App yang load native lib di sini
        tryLoadNative()
    }

    override fun onCreate() {
        super.onCreate()
        instance = this

        // Inisialisasi engine utama
        NinjaEngine.init(this)
    }

    private fun tryLoadNative() {
        try {
            // Load native library utama — berisi hook physics engine 8BP
            System.loadLibrary("ninja")
            isNativeLoaded = true
        } catch (e: UnsatisfiedLinkError) {
            // Fallback jika native lib tidak ada (mode debug)
            isNativeLoaded = false
            Log.d("AsasainPoll", "Native lib not found, running in debug mode")
        }
    }
}
