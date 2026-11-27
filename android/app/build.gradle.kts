plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    // Required when android.builtInKotlin=false (AGP 9 + older plugins like app_links).
    id("org.jetbrains.kotlin.android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.devsync_open_source_collaboration_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.devsync_open_source_collaboration_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // AGP 9 defaults resValues off; required for flavor resValue() app_name.
    buildFeatures {
        resValues = true
    }

    flavorDimensions += "tier"
    productFlavors {
        // No applicationIdSuffix: google-services.json only registers the base package.
        create("free") {
            dimension = "tier"
            resValue("string", "app_name", "DevSync")
        }
        create("pro") {
            dimension = "tier"
            resValue("string", "app_name", "DevSync Pro")
        }
    }

    // AGP 8+/9 can omit jni from the APK unless legacy packaging is used.
    // Without this, the device crashes with MissingLibraryException: libflutter.so.
    packaging {
        jniLibs {
            useLegacyPackaging = true
            // Huge debug-only Vulkan layer — skip to save disk/APK size.
            excludes += setOf("**/libVkLayer_khronos_validation.so")
        }
    }

    buildTypes {
        release {
            // Upload keystore still TODO — debug signing keeps `flutter run --release` working.
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
