plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

import java.util.Properties
import java.util.Base64

// ── Signing ────────────────────────────────────────────────
// Priority: key.properties > CI env vars > debug (fallback)
val keystoreProperties = Properties()
val keystoreFile = rootProject.file("key.properties")
if (keystoreFile.exists()) {
    keystoreProperties.load(keystoreFile.inputStream())
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

    signingConfigs {
        create("release") {
            val envStore = System.getenv("ANDROID_KEYSTORE_BASE64")
            if (!envStore.isNullOrEmpty()) {
                // CI: decode base64 keystore from env
                val tmpFile = file("${System.getProperty("java.io.tmpdir")}/flcroc.p12")
                tmpFile.writeBytes(Base64.getDecoder().decode(envStore))
                storeFile = tmpFile
                storePassword = System.getenv("ANDROID_KEYSTORE_PASSWORD") ?: ""
                keyAlias = System.getenv("ANDROID_KEY_ALIAS") ?: "flcroc"
                keyPassword = System.getenv("ANDROID_KEY_PASSWORD") ?: storePassword
            } else if (keystoreProperties.containsKey("storeFile")) {
                // Local: read from key.properties
                storeFile = rootProject.file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
                keyAlias = keystoreProperties["keyAlias"] as String? ?: "flcroc"
                keyPassword = keystoreProperties["keyPassword"] as String? ?: storePassword
            } else {
                // Fallback to debug — only for local development
                storeFile = signingConfigs.getByName("debug").storeFile
                storePassword = signingConfigs.getByName("debug").storePassword
                keyAlias = signingConfigs.getByName("debug").keyAlias
                keyPassword = signingConfigs.getByName("debug").keyPassword
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
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
