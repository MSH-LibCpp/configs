git clone https://github.com/MSH-LibCpp/configs.git

:: Move files
copy /Y configs\CMakePresets.json CMakePresets.json
copy /Y configs\run-cursor.bat run-cursor.bat
copy /Y configs\install-config.bat install-config.bat

:: Remove the configs directory
rmdir /S /Q configs

:: Run the cursor batch file
run-cursor.bat