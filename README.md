# tiktok_video_downloader

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.









### Dev Section

adb connect 192.168.171.228:5555

flutter emulators
flutter emulators --launch Pixel_9_Pro_API_35-ext15

flutter clean build  
flutter build appbundle --dart-define-from-file=env/release.json

shorebird release android -- --dart-define-from-file=env/release.json

zip -d Archive.zip "__MACOSX*" 


flutter clean
flutter build apk --release --dart-define-from-file=env/release.json

build/app/outputs/flutter-apk/app-release.apk

Option A: Using flutter install
flutter install --release

Option B: Using adb directly
adb devices
adb install -r build/app/outputs/flutter-apk/app-release.apk
adb uninstall com.yourcompany.yourapp



flutter run --release
flutter run --release --dart-define-from-file=env/release.json



-------------------------
https://docs.shorebird.dev/code-push/initialize/
shorebird init

https://docs.shorebird.dev/code-push/release/
shorebird release android


https://docs.shorebird.dev/code-push/patch/
shorebird patch android
shorebird patch android --release-version latest
shorebird patch android --release-version 0.1.0+1










1. So the input field is still white and too short
2. the paste button does not work
3. the name of the download is sort of wierd with just numbers, the prev version of the project would save the download as the tiktok account name along with some alphanumeric code or tiktok itself save everythin with alpanuemric code so i wan the way the previous version works back
4. i noticed that when i download a video, it is there is my all downloads and view recent but not in my gallery. you do know the all download and view recent are supposed to come from the files that have already been saved in my gallery right the saved folder should be the data source
5. in the recent download section in the home page when i click on any of the view it does not open up the page where i can play the videos.
6. the input field right is white in a black background which makes it very inconsistant, in other to make it consistant you need to remove the first link icon and make the and the border of the input have to be prominent against the black bg in other for it to look nice
7. the images above represents what the all download page/history should look like pick the best blends of the 2 designs
