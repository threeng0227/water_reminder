# flutter_local_notifications
-keep class com.dexterous.** { *; }
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# Gson / serialization (used by flutter_local_notifications)
-keep class com.google.gson.** { *; }
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Keep generic type info at runtime
-keepattributes RuntimeVisibleAnnotations
-keepattributes RuntimeVisibleParameterAnnotations

# flutter_timezone / timezone
-keep class dev.fluttercommunity.plus.timezone.** { *; }

# home_widget
-keep class es.antonborri.home_widget.** { *; }
