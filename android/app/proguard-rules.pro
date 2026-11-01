# Obfuscate semua class kecuali yang dibutuhkan sistem Android
-repackageclasses 'a.b.c'
-allowaccessmodification
-optimizationpasses 5

# Jangan obfuscate Flutter engine
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugin.** { *; }

# Jangan obfuscate class yang terdaftar di AndroidManifest
-keep class com.asasain.poll.engine.App { *; }
-keep class com.asasain.poll.engine.DaemonService { *; }
-keep class com.asasain.poll.engine.DaemonService$DaemonInnerService { *; }
-keep class com.asasain.poll.engine.StubReceiver { *; }
-keep class com.asasain.poll.engine.NinjaEngine { *; }
-keep class com.asasain.poll.base.** { *; }
-keep class com.asasain.poll.proxy.** { *; }
-keep class com.asasain.poll.view.** { *; }

# Jangan obfuscate JNI method names — native layer butuh nama ini persis
-keepclasseswithmembernames class com.asasain.poll.engine.NinjaEngine {
    native <methods>;
}

# Hapus semua Log.d dan Log.v di release — anti-cheat sering scan logcat
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}

# Hapus debug info dari class file
-dontusemixedcaseclassnames
-dontskipnonpubliclibraryclasses
-verbose
