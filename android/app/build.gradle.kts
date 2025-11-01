import java.util.Properties

// 🟢 Load keystoreProperties from key.properties file
val keystoreProperties = Properties()
//val keystorePropertiesFile = file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(keystorePropertiesFile.inputStream())
}

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.proappsbuild.marsuseduverse"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.proappsbuild.marsuseduverse"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

//    signingConfigs {
//        create("release") {
//            val storeFilePath = keystoreProperties["storeFile"] as String?
//            val storePasswordValue = keystoreProperties["storePassword"] as String?
//            val keyAliasValue = keystoreProperties["keyAlias"] as String?
//            val keyPasswordValue = keystoreProperties["keyPassword"] as String?
//
//            if (storeFilePath.isNullOrEmpty() ||
//                storePasswordValue.isNullOrEmpty() ||
//                keyAliasValue.isNullOrEmpty() ||
//                keyPasswordValue.isNullOrEmpty()) {
//                throw GradleException("❌ Missing values in key.properties — check paths or keys!")
//            }
//
//            storeFile = file(storeFilePath)
//            storePassword = storePasswordValue
//            keyAlias = keyAliasValue
//            keyPassword = keyPasswordValue
//        }
//    }



    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("com.google.android.material:material:1.12.0")
}
