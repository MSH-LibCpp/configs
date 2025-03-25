git clone https://github.com/MSH-LibCpp/configs.git

:: Move directories
xcopy /E /I /Y configs\.vscode .vscode
xcopy /E /I /Y configs\cmake cmake

:: Move files
copy /Y configs\AskAI.md AskAI.md
copy /Y configs\.clang-format .clang-format
copy /Y configs\CMakePresets.json CMakePresets.json
copy /Y configs\install-config.bat install-config.bat
copy /Y configs\run-cursor.bat run-cursor.bat

:: Remove the configs directory
rmdir /S /Q configs

:: Run the cursor batch file
run-cursor.bat