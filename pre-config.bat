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
copy /Y configs\.gitignore .gitignore
copy /Y configs\CMakeLists.txt CMakeLists.txt
copy /Y configs\README.md README.md

:: Force add .vscode/settings.json to git
git add -f .vscode/settings.json

:: Remove the configs directory
rmdir /S /Q configs

:: Run the cursor batch file
start "" cmd /c "run-cursor.bat"

:: Delete this script itself
del "%~f0"