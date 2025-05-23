git clone https://github.com/MSH-LibCpp/configs.git

:: Move directories
xcopy /E /I /Y configs\.vscode .vscode

:: Move files
copy /Y configs\AskAI.md AskAI.md
copy /Y configs\.clang-format .clang-format
copy /Y configs\CMakePresets.json CMakePresets.json
copy /Y configs\update-config.bat update-config.bat
copy /Y configs\install-packages.bat install-packages.bat
copy /Y configs\run-vscode.bat run-vscode.bat
copy /Y configs\.gitignore .gitignore
copy /Y configs\CMakeLists.txt CMakeLists.txt
copy /Y configs\README.md README.md

:: Force add .vscode/settings.json to git
git add -f .vscode/settings.json

:: Remove the configs directory
rmdir /S /Q configs

:: Delete this script itself
del "%~f0"