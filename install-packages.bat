@echo off
setlocal enabledelayedexpansion
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
msvc-x64-win10-debug ^
msvc-x86-win10-release ^
msvc-x86-win10-debug ^
gxx-x64-release ^
gxx-x64-debug ^
gxx-x86-release ^
gxx-x86-debug

:: Loop through each preset and run CMake steps
for %%P in (%presets%) do (
    echo.
    echo ============================
    echo ==== Processing %%P ====
    echo ============================

    echo [%%P] Configuring...
    echo -------- CONFIGURE %%P --------
    cmake --preset %%P
    if errorlevel 1 (
        echo [ERROR] Configure step failed for %%P
        exit /b 1
    )

    echo [%%P] Building...
    echo -------- BUILD %%P --------
    cmake --build --preset %%P
    if errorlevel 1 (
        echo [ERROR] Build step failed for %%P
        exit /b 1
    )

    echo [%%P] Installing...
    echo -------- INSTALL %%P --------
    set "buildDir=build/%%P"
    cmake --install !buildDir!
    if errorlevel 1 (
        echo [ERROR] Install step failed for %%P
        exit /b 1
    )

    echo [%%P] Cleaning up build directory: !buildDir!
    rmdir /s /q "!buildDir!"
    if exist "!buildDir!" (
        echo [%%P] Failed to remove directory.
    ) else (
        echo [%%P] Build directory removed.
    )

    echo [%%P] Done!
)

git reset --hard
git clean -fd

echo.
echo All builds and installs completed.
endlocal
exit /b 0

:: Or use the old way

:: Make sure that the "MSH_ROOT_PATH" defined as e.g. "C:/MSH"
:: or set it manually
:: set "MSH_ROOT_PATH=C:/MSH"

@REM cmake --preset msvc-x64-win10-release
@REM cmake --build --preset msvc-x64-win10-release
@REM cmake --install build/msvc-x64-win10-release