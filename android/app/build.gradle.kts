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
// (see .github/workflows/release.yml). Release builds refuse to run
// without it (see the check at the bottom of this file), so a debug-signed
// bundle can never be uploaded to Play by mistake. Debug builds don't
// need it.
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
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
            // Upload keystore from key.properties. Never the debug key: if
            // the file is missing the release build fails (check below).
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

// Fail fast with a clear message instead of producing an unsigned or
// debug-signed release. Only release tasks of this module are checked, so
// `flutter run` and `flutter build apk --debug` keep working without
// key.properties.
gradle.taskGraph.whenReady {
    val appPath = project.path
    val buildsRelease = allTasks.any { task ->
        task.project.path == appPath &&
            task.name.endsWith("Release") &&
            (task.name.startsWith("assemble") ||
                task.name.startsWith("bundle") ||
                task.name.startsWith("package") ||
                task.name.startsWith("sign"))
    }
    if (buildsRelease && !keystorePropertiesFile.exists()) {
        throw GradleException(
            "Release signing is not set up: android/key.properties is missing. " +
                "Create it with storeFile, storePassword, keyAlias and keyPassword " +
                "for the Play upload key, then build again. Debug builds do not need it.",
        )
    }
}
