package com.asasain.poll.engine

import android.app.*
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.os.*
import androidx.core.app.NotificationCompat

class DaemonService : Service() {

    private val CHANNEL_ID = "asasain_daemon"
    private var innerConnection: ServiceConnection? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        // Start sebagai foreground agar tidak di-kill Android sistem
        startForeground(101, buildNotification())
        // Bind ke inner service — dua-duanya saling restart saat salah satu mati
        bindInnerService()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // START_STICKY: service restart otomatis jika mati
        return START_STICKY
    }

    override fun onDestroy() {
        super.onDestroy()
        // Saat DaemonService mati, restart via inner service
        val innerIntent = Intent(this, DaemonInnerService::class.java)
        startService(innerIntent)
    }

    private fun bindInnerService() {
        innerConnection = object : ServiceConnection {
            override fun onServiceConnected(name: ComponentName?, service: IBinder?) {}
            override fun onServiceDisconnected(name: ComponentName?) {
                // Inner service mati → restart daemon
                val intent = Intent(this@DaemonService, DaemonService::class.java)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    startForegroundService(intent)
                } else {
                    startService(intent)
                }
            }
        }
        bindService(
            Intent(this, DaemonInnerService::class.java),
            innerConnection!!,
            Context.BIND_ABOVE_CLIENT
        )
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "AsasainPoll Engine",
                NotificationManager.IMPORTANCE_MIN // IMPORTANCE_MIN = tidak muncul di notif bar
            )
            channel.setShowBadge(false)
            getSystemService(NotificationManager::class.java)?.createNotificationChannel(channel)
        }
    }

    private fun buildNotification(): Notification {
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("AsasainPoll")
            .setContentText("Engine running")
            .setSmallIcon(android.R.drawable.sym_def_app_icon)
            .setPriority(NotificationCompat.PRIORITY_MIN)
            .setSilent(true)
            .build()
    }

    // Inner service: berjalan di proses terpisah (:daemon)
    // Tugasnya restart DaemonService jika mati
    class DaemonInnerService : Service() {
        override fun onBind(intent: Intent?): IBinder? = null

        override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
            return START_STICKY
        }

        override fun onDestroy() {
            super.onDestroy()
            // Restart outer DaemonService jika inner mati
            val outerIntent = Intent(this, DaemonService::class.java)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                startForegroundService(outerIntent)
            } else {
                startService(outerIntent)
            }
        }
    }
}
