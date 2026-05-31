# Add project specific ProGuard rules here.
# Flutter-specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Drift / SQLite
-keep class com.google.android.apps.auto.sdk.** { *; }
-keepclassmembers class * extends com.google.protobuf.GeneratedMessageLite {
    <fields>;
}

# flutter_local_notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }
