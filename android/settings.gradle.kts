pluginManagement {
    val flutterSdkPath: String = settings.extra["flutter.sdk"].toString()
    settings.extra["gradle.user.home"] = file("${settings.settingsDir.parentFile}/.gradle")

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }

    resolutionStrategy {
        eachPlugin {
            when (requested.id.name) {
                "com.android.application" -> useModule("com.android.tools.build:gradle:8.1.0")
                "com.android.library" -> useModule("com.android.tools.build:gradle:8.1.0")
                "org.jetbrains.kotlin.android" -> useVersion("1.9.0")
                "dev.flutter.flutter-gradle-plugin" -> useModule("dev.flutter:gradle:3.16.0")
            }
        }
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.1.0" apply false
    id("org.jetbrains.kotlin.android") version "1.9.0" apply false
}

include(":app")

// Configuração para melhorar o desempenho do build
gradle.projectsLoaded {
    allprojects {
        repositories {
            google()
            mavenCentral()
            maven { url = uri("https://storage.googleapis.com/download.flutter.io") }
        }
    }
}

// Configuração para evitar problemas de memória
gradle.projectsEvaluated {
    tasks.withType<JavaCompile> {
        options.compilerArgs.add("-Xmx4g")
    }
}
