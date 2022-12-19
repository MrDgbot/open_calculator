#!/bin/sh
test -f openCalculator.dmg && rm openCalculator.dmg
create-dmg \
  --volname "Open_calculator Installer" \
  --volicon "./assets/installer.icns" \
  --background "./assets/dmg_background.png" \
  --window-pos 200 120 \
  --window-size 800 530 \
  --icon-size 130 \
  --text-size 14 \
  --icon "open_calculator.app" 260 250 \
  --hide-extension "open_calculator.app" \
  --app-drop-link 540 250 \
  --hdiutil-quiet \
  "build/macos/Build/Products/Release/open_calculator.dmg" \
  "build/macos/Build/Products/Release/open_calculator.app"