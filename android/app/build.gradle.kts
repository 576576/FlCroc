plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "cn.sumitm.flcroc"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "cn.sumitm.flcroc"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
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

// Auto-patch plugin registrant after flutter pub get regenerates it.
// Desktop-only plugins (desktop_drop, jni, etc.) register on Android
// and throw NoClassDefFoundError which is NOT caught by catch(Exception).
tasks.register("patchPluginRegistrant") {
    doLast {
        val file = file("src/main/java/io/flutter/plugins/GeneratedPluginRegistrant.java")
        if (file.exists()) {
            val old = "catch (Exception e)"
            val rep = "catch (Throwable e)"
            var content = file.readText()
            if (content.contains(old)) {
                content = content.replace(old, rep)
                file.writeText(content)
                println("✓ Patched GeneratedPluginRegistrant.java: Exception → Throwable")
            }
        }
    }
}
tasks.matching { it.name.startsWith("compile") }.configureEach {
    dependsOn("patchPluginRegistrant")
}
