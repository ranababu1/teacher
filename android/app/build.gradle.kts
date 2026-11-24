import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Firebase: consumes android/app/google-services.json (project
    // "teacher-max") and uploads Dart symbols for obfuscated builds.
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
}

// Release signing, standard Flutter key.properties style. The file is
// local-only (see .gitignore); CI materializes it from GitHub Secrets
// (see .github/workflows/release.yml). A release build without it fails
// right away instead of quietly signing with the debug key, which Play
// rejects. Debug and profile builds don't need it.
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}
val isReleaseBuild = gradle.startParameter.taskNames.any {
    it.contains("Release", ignoreCase = true)
}
if (isReleaseBuild && !keystorePropertiesFile.exists()) {
    throw GradleException(
        "Release signing is not set up: android/key.properties is missing. " +
            "Create it (storeFile, storePassword, keyAlias, keyPassword) " +
            "before building a release. Release builds are never signed " +
            "with the debug key."
    )
}

android {
    // Reverse-DNS of teacher.imrn.dev. The Play Store treats the application
    // id as permanent once the app is published — never change it.
    namespace = "dev.imrn.teacher"
    // Pinned instead of flutter.compileSdkVersion: that resolves to API 37,
    // whose SDK platform is only published as "android-37.0" on this
    // machine (a naming mismatch with newer Android point-releases), not
    // the plain "android-37" Gradle looks for. API 36 is installed and
    // plenty current.
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // Required by flutter_local_notifications.
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        applicationId = "dev.imrn.teacher"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // Always the upload keystore. The check above stops a release
            // build early when key.properties is missing.
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
