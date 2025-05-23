git clone https://github.com/MSH-LibCpp/configs.git

:: Move directories
xcopy /E /I /Y configs\.vscode .vscode

:: Move files
copy /Y configs\AskAI.md AskAI.md
copy /Y configs\.clang-format .clang-format
copy /Y configs\CMakePresets.json CMakePresets.json
copy /Y configs\config.bat config.bat
copy /Y configs\install.bat install.bat
copy /Y configs\run-vscode.bat run-vscode.bat

if not exist "CMakeLists.txt" (
  :: Move files
  copy /Y configs\README.md README.md
  copy /Y configs\CMakeLists.txt CMakeLists.txt
  copy /Y configs\.gitignore .gitignore
  
  :: Force add .vscode/settings.json to git
  git add -f .vscode/settings.json
)

:: Remove the configs directory
rmdir /S /Q configs
