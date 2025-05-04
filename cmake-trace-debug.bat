@echo off
setlocal

:: Configure CMake with trace output for debugging
cmake --preset edge8500_vc_x86_win10_debug --trace-expand

:: Uncomment to use release mode
:: cmake --preset edge8500_vc_x86_win10 --trace-expand

pause
