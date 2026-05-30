plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

fun releaseSigningValue(name: String): String? =
    (project.findProperty(name) as String?)
        ?.takeIf { it.isNotBlank() }
        ?: System.getenv(name)?.takeIf { it.isNotBlank() }

val hasReleaseSigningConfig = listOf(
    "ANDROID_KEYSTORE_PATH",
    "ANDROID_KEYSTORE_PASSWORD",
    "ANDROID_KEY_ALIAS",
    "ANDROID_KEY_PASSWORD",
).all { releaseSigningValue(it) != null }

android {
    namespace = "com.example.ki_campus_companion"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.ki_campus_companion"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseSigningConfig) {
            create("release") {
                storeFile = file(releaseSigningValue("ANDROID_KEYSTORE_PATH")!!)
                storePassword = releaseSigningValue("ANDROID_KEYSTORE_PASSWORD")
                keyAlias = releaseSigningValue("ANDROID_KEY_ALIAS")
                keyPassword = releaseSigningValue("ANDROID_KEY_PASSWORD")
            }
        }
    }

    buildTypes {
        release {
            // GitHub releases must provide a stable release keystore so Android can
            // upgrade existing installations. Local release builds keep the Flutter
            // debug signing fallback unless all release signing values are present.
            signingConfig = signingConfigs.getByName(
                if (hasReleaseSigningConfig) "release" else "debug",
            )
        }
    }
}

flutter {
    source = "../.."
}
