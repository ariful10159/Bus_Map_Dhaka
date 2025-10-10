plugins {
    // Google services (Firebase) Gradle plugin available to subprojects
    id("com.google.gms.google-services") version "4.4.3" apply false
}

// Central repositories for all projects (Gradle 8 simplified DSL)
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Relocate build directory to keep repo root clean
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    layout.buildDirectory.value(newSubprojectBuildDir)
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(layout.buildDirectory)
}
