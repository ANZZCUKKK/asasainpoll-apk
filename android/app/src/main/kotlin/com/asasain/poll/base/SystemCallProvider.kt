package com.asasain.poll.base

import android.content.ContentProvider
import android.content.ContentValues
import android.database.Cursor
import android.net.Uri
import android.os.Bundle

// SystemCallProvider: IPC bridge antara proses sandbox dan engine utama
// Clone dari com.ninja.engine.base.SystemCallProvider
class SystemCallProvider : ContentProvider() {

    override fun onCreate(): Boolean = true

    // call() method digunakan sebagai IPC: proses sandbox memanggil engine via provider
    override fun call(method: String, arg: String?, extras: Bundle?): Bundle? {
        return when (method) {
            // Sandbox minta status cheat saat ini
            "getCheatStatus" -> Bundle().apply {
                putBoolean("esp", false)
                putBoolean("autoplay", false)
                putBoolean("autoqueue", false)
            }
            // Sandbox report bahwa game sudah loaded, siap di-hook
            "onGameReady" -> {
                val pid = extras?.getInt("pid") ?: 0
                // Trigger native hook injection ke PID game
                Bundle().apply { putBoolean("success", true) }
            }
            else -> null
        }
    }

    override fun query(uri: Uri, p: Array<String>?, s: String?, a: Array<String>?, o: String?): Cursor? = null
    override fun getType(uri: Uri): String? = null
    override fun insert(uri: Uri, values: ContentValues?): Uri? = null
    override fun delete(uri: Uri, s: String?, a: Array<String>?): Int = 0
    override fun update(uri: Uri, v: ContentValues?, s: String?, a: Array<String>?): Int = 0
}
