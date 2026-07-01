@echo off
set PATH=%PATH%;C:\tools\flutter\bin;C:\Users\UNAL\AppData\Local\Android\Sdk\emulator;C:\Users\UNAL\AppData\Local\Android\Sdk\platform-tools

echo Emulator baslatiliyor...
call flutter emulators --launch Medium_Phone
if %ERRORLEVEL% neq 0 (
    echo Emulator baslatilamadi!
    exit /b 1
)

echo Emulator aciliyor, bekleniyor...
adb wait-for-device

echo Sistem acilisi bekleniyor...
:wait_boot
adb shell getprop sys.boot_completed >nul 2>&1
for /f %%i in ('adb shell getprop sys.boot_completed') do set boot=%%i
if not "%boot%"=="1" (
    timeout /t 2 /nobreak >nul
    goto wait_boot
)

echo Emulator hazir. Uygulama calistiriliyor...
flutter run -d emulator-5554
pause
