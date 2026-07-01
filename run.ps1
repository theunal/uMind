$env:Path += ";C:\tools\flutter\bin;C:\Users\UNAL\AppData\Local\Android\Sdk\emulator;C:\Users\UNAL\AppData\Local\Android\Sdk\platform-tools"

Write-Host "Emülatör başlatılıyor..." -ForegroundColor Cyan
flutter emulators --launch Medium_Phone
if ($LASTEXITCODE -ne 0) {
    Write-Host "Emülatör başlatılamadı!" -ForegroundColor Red
    exit 1
}

Write-Host "Emülatör açılıyor, bekleniyor..." -ForegroundColor Yellow
adb wait-for-device

Write-Host "Sistem açılışı bekleniyor..." -ForegroundColor Yellow
do {
    Start-Sleep -Seconds 2
    $boot = adb shell getprop sys.boot_completed 2>$null
} while ($boot -ne "1")

Write-Host "Emülatör hazır. Uygulama çalıştırılıyor..." -ForegroundColor Green
flutter run -d emulator-5554
