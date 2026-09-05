import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing is read from android/key.properties (git-ignored). If it is
// absent, release falls back to the debug key so dev `--release` builds still
// work. See docs/release-build.md for keystore setup.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.lunexa.games.chessrescue"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.lunexa.games.chessrescue"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = (keystoreProperties["storeFile"] as String?)?.let { file(it) }
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        // Local development only. The debug build installs under a distinct
        // application ID so it can sit side-by-side with the Google Play
        // production install on a physical device — `flutter run` would
        // otherwise hit a signing mismatch against the Play build and
        // uninstall it (data and all) to force the install through.
        // Release identity and signing are deliberately untouched.
        getByName("debug") {
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
        }

        // `profile` is created by the Flutter Gradle plugin via
        // initWith(debug), but that copy happens while the plugin is applied —
        // before this block runs — so it does NOT inherit the suffix above.
        // Verified: without this, `flutter build apk --profile` produces the
        // production application ID. Profile runs are used for on-device
        // performance passes, so it needs the same isolation.
        getByName("profile") {
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
        }

        release {
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

flutter {
    source = "../.."
}
