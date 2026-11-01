package com.asasain.poll.view.update

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity

// Activity yang tampil saat versi app sudah outdated dan harus update
class UpdateRequiredActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Tampilkan dialog update → redirect ke Telegram
        val updateUrl = intent?.getStringExtra("update_url") ?: "https://t.me/anzzseturr"
        startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(updateUrl)))
    }
}
