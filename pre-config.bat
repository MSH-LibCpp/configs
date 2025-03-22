git clone https://github.com/MSH-LibCpp/configs.git

:: Move directories
xcopy /E /I /Y configs\.vscode .vscode
xcopy /E /I /Y configs\cmake cmake

:: Move files
copy /Y configs\.clang-format .clang-format
copy /Y configs\.gitignore .gitignore
copy /Y configs\CMakePresets.json CMakePresets.json
copy /Y configs\run-cursor.bat run-cursor.bat
copy /Y configs\pre-config.bat pre-config.bat

:: Remove the configs directory
rmdir /S /Q configs