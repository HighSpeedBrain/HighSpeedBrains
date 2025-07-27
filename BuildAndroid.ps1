# Turn off default verbose/progress output for cleaner logs
$VerbosePreference = 'SilentlyContinue'
$ProgressPreference = 'SilentlyContinue'

function EchoInfo($msg) {
    Write-Host "[INFO]  $msg" -ForegroundColor Cyan
}
function EchoSuccess($msg) {
    Write-Host "[DONE]  $msg" -ForegroundColor Green
}
function EchoError($msg) {
    Write-Host "[ERROR] $msg" -ForegroundColor Red
}

try {
    Set-Location "C:\Users\Rushi\Favorites\Projects\Minigame-Website\"
    EchoInfo "Starting gulp build with bun..."
    bunx gulp build
    EchoSuccess "Gulp build finished."

    EchoInfo "Copying assets from Source to www"
    # Ensure target directory exists
    if (-Not (Test-Path .\www\assets)) {
        New-Item -ItemType Directory -Path .\www\assets | Out-Null
    }

    # Copy assets (contents only)
    Copy-Item .\src\assets\* .\www\assets\ -Recurse -Force

    EchoSuccess "Assets successfully copied"

    EchoInfo "Cleaning Android www folder..."
    Remove-Item -Recurse -Force .\Android\www\* -ErrorAction Stop
    EchoSuccess "Android www folder cleaned."

    EchoInfo "Copying built files to Android www folder..."
    Copy-Item -Recurse -Force .\www\* .\Android\www -ErrorAction Stop
    EchoSuccess "Files copied successfully."

    EchoInfo "Switching to Android android directory..."
    Push-Location .\Android\android

    $apkPath = ".\app\build\outputs\apk\debug\app-debug.apk"
    if (Test-Path $apkPath) {
        EchoInfo "Removing previous APK..."
        Remove-Item -Force $apkPath -ErrorAction Stop
        EchoSuccess "Previous APK removed."
    }

    EchoInfo "Building debug APK with Gradle..."
    .\gradlew assembleDebug
    EchoSuccess "APK build complete."

    EchoInfo "Copying APK to root directory..."
    Remove-Item ..\..\AppDebug.apk *> log.log
    remove-item log.log
    Copy-Item $apkPath ..\..\AppDebug.apk -ErrorAction Stop
    EchoSuccess "APK copied to root."

} catch {
    EchoError $_.Exception.Message
} finally {
    Set-Location ../../
    EchoInfo "Returned to original directory."
    adb install .\AppDebug.apk
}
