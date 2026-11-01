package com.asasain.poll.engine

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

// Stub receiver untuk intercept dynamic broadcast dari VirtualApp sandbox
// Clone dari com.ninja.engine.stub_receiver
class StubReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context?, intent: Intent?) {
        // Forward semua broadcast yang diterima ke VirtualApp manager
        // agar target app di dalam sandbox bisa menerimanya
        intent?.let {
            // Strip component agar VirtualApp bisa route ulang
            it.component = null
            // VirtualAppManager handle routing ke proses yang tepat
        }
    }
}
