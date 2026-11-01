package com.asasain.poll.proxy

import android.content.ContentProvider
import android.content.ContentValues
import android.database.Cursor
import android.net.Uri

// Proxy Content Provider untuk VirtualApp content resolution
// Clone dari com.ninja.engine.proxy_content_provider_*
open class ProxyContentProvider : ContentProvider() {
    override fun onCreate(): Boolean = true
    override fun query(uri: Uri, p: Array<String>?, s: String?, a: Array<String>?, o: String?): Cursor? = null
    override fun getType(uri: Uri): String? = null
    override fun insert(uri: Uri, values: ContentValues?): Uri? = null
    override fun delete(uri: Uri, s: String?, a: Array<String>?): Int = 0
    override fun update(uri: Uri, v: ContentValues?, s: String?, a: Array<String>?): Int = 0

    class P0 : ProxyContentProvider()
    class P1 : ProxyContentProvider()
    class P2 : ProxyContentProvider()
    class P3 : ProxyContentProvider()
    class P4 : ProxyContentProvider()
    class P5 : ProxyContentProvider()
    class P6 : ProxyContentProvider()
    class P7 : ProxyContentProvider()
    class P8 : ProxyContentProvider()
    class P9 : ProxyContentProvider()
    class P10 : ProxyContentProvider()
    class P11 : ProxyContentProvider()
    class P12 : ProxyContentProvider()
    class P13 : ProxyContentProvider()
    class P14 : ProxyContentProvider()
    class P15 : ProxyContentProvider()
    class P16 : ProxyContentProvider()
    class P17 : ProxyContentProvider()
    class P18 : ProxyContentProvider()
    class P19 : ProxyContentProvider()
}
