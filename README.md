# simple_flutter_chat_app

description: https://fileidea.com/2021/04/26/create-a-simple-flutter-chat-app/

22.11.21: funktioniert bereits unter Android
23.11.21: funktioniert unter iOS

```plaintext

```

```plaintext

```

```plaintext
bottom_navy_bar: ^6.0.0
shared_preferences: ^2.0.5
firebase_core: "^1.0.4"
cloud_firestore: "^1.0.6"
intl: ^0.17.0

dev_dependencies:
pedantic: ^1.10.0
```

```plaintext
setup for Android:

Open up android/build.gradle and add this under dependencies:

classpath 'com.google.gms:google-services:4.3.10'
Then open up android/app/build.gradle and add this:

apply plugin: 'com.google.gms.google-services'

Firebase console: https://console.firebase.google.com/

doc: https://firebase.flutter.dev/docs/firestore/usage/

https://firebase.flutter.dev/docs/overview

https://codelabs.developers.google.com/codelabs/friendlyeats-flutter/#0

Codelab: Get to know Firebase for Flutter https://www.youtube.com/watch?v=wUSkeTaBonA

ios installation: https://firebase.flutter.dev/docs/installation/ios

Then go to Project settings at Firebase under the configuration wheel icon and click 
on the Android icon and match it with your app information which you can find under 
simplechatapp\android\app\src\main\AndroidManifest.xml.

de.fluttercrypto1.simple_flutter_chat_app
SimpleChat

iOS:
Apple BundleId: de.fluttercrypto1.simpleflutterchatapp
in Xcode: de.fluttercrypto1.simpleFlutterChatApp



//in Info.plist eingefügt:
//<key>softwareVersionBundleId</key>
//<string>de.fluttercrypto1.simpleflutterchatapp</string>

GoogleService-Info.plist heruntergeladen
AndroidStudio Tools - Flutter - OpeniOS module in Xcode
drag & drop file to inner Runner Folder, Destination: Copy items angehakt
Add to targets: Runner angehakt
build & run app
Running pod install dauert beim ersten start länger


Podfile:
platform :ios, '10.0'

CloudFirestore im Testmodus (23.11.2021) eur3

in der Oberfläche unter Regeln geändert:

rules_version = '2';
service cloud.firestore {
match /databases/{database}/documents {
match /{document=**} {
allow read, write: if
request.time < timestamp.date(2025, 12, 23);
}
}
}

So inside Register app I’ll type in: com.fileidea.simpleChat (I actually changed mine from 
example to fileidea with this rename package) and SimpleChat as nickname and skip SHA-1.
Download the config file into your android/app folder

renaming: google-services-2.json to google-services.json

in build.gradle (app):
defaultConfig {
applicationId "de.fluttercrypto1.simple_flutter_chat_app"
minSdkVersion 21
```

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
