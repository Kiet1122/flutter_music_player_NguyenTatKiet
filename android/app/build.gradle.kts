plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.offline_music_player"
    
    // GHI ĐÈ SDK: Đặt 34/36. Giữ 36 theo yêu cầu của plugin
    compileSdk = 36 
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // SỬA LỖI CÚ PHÁP & TỐI ƯU: Dùng JavaVersion 17 để tương thích hiện tại
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        // SỬA LỖI CÚ PHÁP: jvmTarget phải khớp với compileOptions
        jvmTarget = JavaVersion.VERSION_17.toString() 
    }

    defaultConfig {
        applicationId = "com.example.offline_music_player"
        // TỐI ƯU: Đặt minSdk cố định là 21 (hoặc 19) để tránh lỗi
        minSdk = flutter.minSdkVersion 
        targetSdk = 36 
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
