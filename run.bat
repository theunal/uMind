@echo off
setlocal EnableExtensions EnableDelayedExpansion
set PATH=%PATH%;C:\tools\flutter\bin;C:\Users\UNAL\AppData\Local\Android\Sdk\emulator;C:\Users\UNAL\AppData\Local\Android\Sdk\platform-tools
set "RESET=0"
if /i "%~1"=="--reset" set "RESET=1"
if /i "%~1"=="-reset" set "RESET=1"

call :color_print 96 "Starting emulator..."
call flutter emulators --launch Medium_Phone
if %ERRORLEVEL% neq 0 (
    call :color_print 12 "Failed to start emulator!"
    exit /b 1
)

call :color_print 14 "Opening emulator, please wait..."
adb wait-for-device

call :color_print 14 "Waiting for system boot..."
:wait_boot
adb shell getprop sys.boot_completed >nul 2>&1
for /f %%i in ('adb shell getprop sys.boot_completed') do set boot=%%i
if not "%boot%"=="1" (
    timeout /t 2 /nobreak >nul
    goto wait_boot
)

if "%RESET%"=="1" (
    call :color_print 14 "Reset mode: clearing app data..."
    adb shell pm clear com.umind.umind >nul 2>&1
    if %ERRORLEVEL% neq 0 (
        call :color_print 12 "Failed to clear app data!"
        exit /b 1
    )
)

call :color_print 10 "Emulator is ready. Launching app..."
flutter run -d emulator-5554
exit /b 0

:color_print
set "color=%~1"
set "message=%~2"
if /i "%color%"=="96" (
    color 0B
) else if /i "%color%"=="14" (
    color 0E
) else if /i "%color%"=="10" (
    color 0A
) else if /i "%color%"=="12" (
    color 0C
) else (
    color 07
)
echo %message%
color 07
exit /b 0
