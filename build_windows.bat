@echo off
echo ========================================================
echo Building Kanza Group WMS Desktop for Windows (Release)
echo ========================================================

where flutter >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Flutter SDK is not found in PATH!
    echo Please install Flutter and make sure flutter command works.
    pause
    exit /b 1
)

echo.
echo [1/3] Enabling Windows Desktop...
call flutter config --enable-windows-desktop

echo.
echo [2/3] Fetching dependencies...
call flutter pub get

echo.
echo [3/3] Compiling Release executable (.exe)...
call flutter build windows --release

if %errorlevel% equ 0 (
    echo.
    echo ========================================================
    echo Build Successful!
    echo.
    echo The executable and files are ready in:
    echo build\windows\x64\runner\Release\
    echo.
    echo You can send that entire "Release" folder to anyone on Windows.
    echo ========================================================
) else (
    echo.
    echo [ERROR] Build failed. Make sure Visual Studio with "Desktop development with C++" is installed.
)

pause
