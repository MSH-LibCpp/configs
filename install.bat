@echo off
setlocal enabledelayedexpansion

:: Change working directory to script's location
cd /d "%~dp0"
set "LOGFILE=%~dp0install.log"
echo Log file: %LOGFILE%

call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" x64

:: Optional: set MSH_ROOT_PATH if not already defined
if not defined MSH_ROOT_PATH (
    echo MSH_ROOT_PATH not defined. Using default: C:/MSH
    set "MSH_ROOT_PATH=C:/MSH"
) else (
    :: Normalize backslashes to forward slashes
    set "MSH_ROOT_PATH_FIXED=%MSH_ROOT_PATH:\=/%"
    set "MSH_ROOT_PATH=!MSH_ROOT_PATH_FIXED!"
)

:: Now MSH_ROOT_PATH is guaranteed to use forward slashes
echo Normalized MSH_ROOT_PATH: %MSH_ROOT_PATH%

:: List of all configure/build presets
set presets=^
msvc-x64-win10-release ^
msvc-x64-win10-debug
@REM msvc-x86-win10-release ^
@REM msvc-x86-win10-debug ^
@REM gxx-x64-release ^
@REM gxx-x64-debug ^
@REM gxx-x86-release ^
@REM gxx-x86-debug

:: Loop through each preset and run CMake steps
for %%P in (%presets%) do (
    echo -------- INSTALL %%P --------

    echo -------- CONFIGURE %%P -------- >> "%LOGFILE%" 2>&1
    cmake --preset %%P >> "%LOGFILE%" 2>&1
    if errorlevel 1 (
        echo [ERROR] Configure step failed for %%P
        exit /b 1
    )

    echo -------- BUILD %%P -------- >> "%LOGFILE%" 2>&1
    cmake --build --preset %%P >> "%LOGFILE%" 2>&1
    if errorlevel 1 (
        echo [ERROR] Build step failed for %%P
        exit /b 1
    )

    echo -------- INSTALL %%P -------- >> "%LOGFILE%" 2>&1
    set "buildDir=build/%%P"
    cmake --install !buildDir! >> "%LOGFILE%" 2>&1
    if errorlevel 1 (
        echo [ERROR] Install step failed for %%P
        exit /b 1
    )

    echo [%%P] Cleaning up build directory: !buildDir! >> "%LOGFILE%" 2>&1
    rmdir /s /q "!buildDir!"
    if exist "!buildDir!" (
        echo [%%P] Failed to remove directory.
        echo [%%P] Failed to remove directory. >> "%LOGFILE%" 2>&1
    ) else (
        echo [%%P] Build directory removed. >> "%LOGFILE%" 2>&1
    )

    echo [%%P] Done!
    echo [%%P] Done! >> "%LOGFILE%" 2>&1
)

echo.
echo All builds and installs completed.
echo. >> "%LOGFILE%" 2>&1
echo All builds and installs completed. >> "%LOGFILE%" 2>&1

endlocal

@REM git reset --hard
@REM git clean -fd

exit /b 0

:: Or use the old way

:: Make sure that the "MSH_ROOT_PATH" defined as e.g. "C:/MSH"
:: or set it manually
:: set "MSH_ROOT_PATH=C:/MSH"

@REM cmake --preset msvc-x64-win10-release
@REM cmake --build --preset msvc-x64-win10-release
@REM cmake --install build/msvc-x64-win10-release