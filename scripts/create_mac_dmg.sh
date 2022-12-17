#!/bin/sh
test -f openCalculator.dmg && rm openCalculator.dmg
create-dmg \
  --volname "openCalculator Installer" \
  --volicon "./assets/installer.icns.icns" \
  --background "./assets/dmg_background.png" \
  --window-pos 200 120 \
  --window-size 800 530 \
  --icon-size 130 \
  --text-size 14 \
  --icon "openCalculator.app" 260 250 \
  --hide-extension "openCalculator.app" \
  --app-drop-link 540 250 \
  --hdiutil-quiet \
  "build/macos/Build/Products/Release/openCalculator.dmg" \
  "build/macos/Build/Products/Release/openCalculator.app"