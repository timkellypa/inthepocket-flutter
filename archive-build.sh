flutter clean    
flutter pub get
cd ios
rm -rf Pods Podfile.lock
pod install --repo-update
flutter build ios