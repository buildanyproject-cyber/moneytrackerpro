# Flutter standard rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Prevent stripping of Flutter plugins (like PathProvider or SharedPrefs)
-keep class com.baseflow.** { *; }
-keep class dev.flutter.plugins.** { *; }
-keep class com.dexterous.** { *; }
-keep class com.google.android.gms.** { *; }

# Hive specific rules
-keep class **.*Adapter { *; }
-keep class * extends hive.TypeAdapter
-keep class hive.** { *; }
-keepnames class * extends hive.TypeAdapter
-keep class com.moneytracker.pro.models.** { *; }
-keep class com.moneytracker.pro.** { *; }

# Google Drive / API rules
-keep class com.google.api.** { *; }
-keep class com.google.api.client.** { *; }
-keep class com.google.api.services.** { *; }

# Ignore missing Play Core classes pulled by Flutter engine deferred components
-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.**

# Flutter Embedder Rules
-keep class io.flutter.embedding.** { *; }
-keep class com.moneytracker.pro.MainActivity { *; }
