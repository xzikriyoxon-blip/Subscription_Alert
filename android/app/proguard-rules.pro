# ProGuard/R8 rules
#
# Fix for flutter_local_notifications crash:
# "TypeToken must be created with a type argument ... make sure that generic signatures are preserved"
#
# This ensures generic type signatures are kept so Gson's TypeToken works at runtime.

-keepattributes Signature,InnerClasses,EnclosingMethod,*Annotation*

# Keep flutter_local_notifications plugin classes (uses reflection/serialization)
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# Keep Gson TypeToken and subclasses
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken { *; }
