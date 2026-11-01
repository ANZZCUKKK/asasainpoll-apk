package com.asasain.poll.proxy

import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.util.Log

// VirtualApp Manager: mengelola sandbox environment untuk menjalankan
// 8 Ball Pool di dalam proses kita sendiri tanpa instalasi terpisah
object VirtualAppManager {

    private const val TAG = "VAManager"
    private var isInitialized = false
    private lateinit var appContext: Context

    // Daftar proxy slot yang sedang dipakai (package → slot index)
    private val usedSlots = mutableMapOf<String, Int>()
    private var nextSlot = 0

    fun init(context: Context) {
        appContext = context.applicationContext
        setupVirtualEnvironment()
        isInitialized = true
        Log.d(TAG, "VirtualApp environment initialized")
    }

    // Setup environment virtual: copy library, setup data dir, patch classpath
    private fun setupVirtualEnvironment() {
        val vaDataDir = appContext.getDir("va_data", Context.MODE_PRIVATE)
        val vaLibDir = appContext.getDir("va_lib", Context.MODE_PRIVATE)

        // Buat struktur direktori untuk tiap virtual app instance
        listOf("data", "lib", "cache", "dex").forEach { dir ->
            java.io.File(vaDataDir, dir).mkdirs()
        }
    }

    // Install APK target ke dalam sandbox (tanpa system installer)
    fun installApp(context: Context, apkPath: String): Boolean {
        return try {
            val vaDataDir = context.getDir("va_data", Context.MODE_PRIVATE)
            val targetDir = java.io.File(vaDataDir, "data/com.miniclip.eightballpool")
            targetDir.mkdirs()

            // Copy APK ke direktori virtual
            val apkFile = java.io.File(apkPath)
            val destApk = java.io.File(targetDir, "base.apk")
            apkFile.copyTo(destApk, overwrite = true)

            // Extract native libs dari APK
            extractNativeLibs(destApk, targetDir)
            Log.d(TAG, "App installed to virtual environment: $apkPath")
            true
        } catch (e: Exception) {
            Log.e(TAG, "Install failed: ${e.message}")
            false
        }
    }

    // Launch target app di dalam sandbox menggunakan proxy slot
    fun launchApp(context: Context, packageName: String): Boolean {
        if (!isInitialized) return false

        return try {
            // Alokasi proxy slot untuk package ini
            val slot = allocateSlot(packageName)

            // Buat intent ke ProxyActivity yang sesuai slot
            val proxyClass = Class.forName(
                "com.asasain.poll.proxy.ProxyActivity\$P$slot"
            )
            val intent = Intent(context, proxyClass)
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            intent.putExtra("target_package", packageName)
            intent.putExtra("slot", slot)
            context.startActivity(intent)
            true
        } catch (e: Exception) {
            Log.e(TAG, "Launch failed: ${e.message}")
            false
        }
    }

    // Alokasi slot proxy untuk package
    private fun allocateSlot(packageName: String): Int {
        usedSlots[packageName]?.let { return it }
        val slot = nextSlot % 50 // 50 proxy slots tersedia
        usedSlots[packageName] = slot
        nextSlot++
        return slot
    }

    // Extract native library dari APK ke direktori virtual
    private fun extractNativeLibs(apkFile: java.io.File, targetDir: java.io.File) {
        val abi = if (Build.SUPPORTED_64_BIT_ABIS.isNotEmpty()) "arm64-v8a" else "armeabi-v7a"
        val libDir = java.io.File(targetDir, "lib/$abi")
        libDir.mkdirs()

        try {
            java.util.zip.ZipFile(apkFile).use { zip ->
                zip.entries().asSequence()
                    .filter { it.name.startsWith("lib/$abi/") && it.name.endsWith(".so") }
                    .forEach { entry ->
                        val libFile = java.io.File(libDir, entry.name.substringAfterLast("/"))
                        zip.getInputStream(entry).use { input ->
                            libFile.outputStream().use { output ->
                                input.copyTo(output)
                            }
                        }
                    }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Extract native libs failed: ${e.message}")
        }
    }
}
