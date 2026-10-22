# Proguard / R8 rules for ParkSmart App

# Google ML Kit (Text Recognition, Barcode, Image Labeling)
-dontwarn com.google.mlkit.vision.text.**
-dontwarn com.google_mlkit_text_recognition.**
-dontwarn com.google.mlkit.vision.common.**
-dontwarn com.google.mlkit.vision.barcode.**
-dontwarn com.google.mlkit.vision.label.**

# Suppress warnings for optional language models
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**

# Keep ML Kit and camera classes
-keep class com.google.mlkit.** { *; }
-keep interface com.google.mlkit.** { *; }
-keep class io.flutter.plugins.camera.** { *; }

# Google Play Core (Flutter Deferred Components)
-dontwarn com.google.android.play.core.**

# Keep Flutter engine & app
-keep class io.flutter.** { *; }
-keep class com.example.smart_parking.** { *; }
