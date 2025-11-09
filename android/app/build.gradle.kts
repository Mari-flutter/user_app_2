plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // Must be applied after Android + Kotlin
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.user_app"
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
        applicationId = "com.example.user_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Debug signing used for now (safe for dev)
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Firebase BOM ensures version compatibility
    implementation(platform("com.google.firebase:firebase-bom:33.2.0"))

    // Firebase Authentication
    implementation("com.google.firebase:firebase-auth")

    // Google Sign-In SDK
    implementation("com.google.android.gms:play-services-auth")
}
