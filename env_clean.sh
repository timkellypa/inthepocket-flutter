#!/bin/zsh

# env_clean.sh - full cleanup for Flutter/CocoaPods/Xcode environment
# usage: chmod +x env_clean.sh && ./env_clean.sh

set -eu

echo "==> 1. Clean Flutter project files"
# cd to this executable's directory to ensure relative paths work
cd "$(dirname "$0")"
flutter clean
rm -rf .dart_tool build

echo "==> 2. Clean iOS pods and Xcode derived data"
cd ios
rm -rf Pods Podfile.lock
pod cache clean --all || true
pod deintegrate || true
rm -rf ~/Library/Developer/Xcode/DerivedData/*

echo "==> 3. Reinstall CocoaPods (Homebrew ruby path)"
# If you're using system ruby, adjust path accordingly; avoid mismatch
sudo gem uninstall cocoapods -aIx || true
sudo gem install cocoapods
pod --version

echo "==> 4. Rebuild Flutter pub packages"
flutter pub get

echo "==> 5. Reinstall iOS pods"
cd ios
pod setup
pod install --repo-update
cd ../

echo "==> 6. (Optional) xcode-select fix"
if [ -d "/Applications/Xcode.app" ]; then
  sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
fi

echo "==> COMPLETED: environment reset finished"

echo "Now run: flutter run -v"