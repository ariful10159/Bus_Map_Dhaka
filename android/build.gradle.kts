// NOTE: Plugin versions are now managed in `settings.gradle.kts` via pluginManagement -> plugins {}
// Keep this file focused on repository and build directory configuration.

// Central repositories for all projects (Gradle 8 simplified DSL)
allprojects {
    repositories {
        google()        // For Firebase and other Google services
        mavenCentral()  // For Maven dependencies
        jcenter()       // Add jcenter if needed (deprecated but used in some projects)
    }
}

// Relocate build directory to keep the root of the repository clean
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

// Configure subprojects to use the relocated build directory
subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    layout.buildDirectory.value(newSubprojectBuildDir)
    project.evaluationDependsOn(":app")  // Ensure the :app module is evaluated first
}

// Clean task to remove the build directories
tasks.register<Delete>("clean") {
    delete(layout.buildDirectory)
}
