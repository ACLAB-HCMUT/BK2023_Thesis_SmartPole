// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBS08sAU3ip3SBpQnYccoPUpscPdoqzqtk',
    appId: '1:512474153375:web:f82376a013f3c76f033daa',
    messagingSenderId: '512474153375',
    projectId: 'nema-nbiot-controller',
    authDomain: 'nema-nbiot-controller.firebaseapp.com',
    databaseURL: 'https://nema-nbiot-controller-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'nema-nbiot-controller.appspot.com',
    measurementId: 'G-7KVF7J19CL',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAusMm747OC2m2d6LeB4v694rYs-lKNASk',
    appId: '1:512474153375:android:e2247329243342b9033daa',
    messagingSenderId: '512474153375',
    projectId: 'nema-nbiot-controller',
    databaseURL: 'https://nema-nbiot-controller-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'nema-nbiot-controller.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCHhhC5fcoxG4pNlKqQfFSFcCGitB45HK8',
    appId: '1:512474153375:ios:60f4316d5739400b033daa',
    messagingSenderId: '512474153375',
    projectId: 'nema-nbiot-controller',
    databaseURL: 'https://nema-nbiot-controller-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'nema-nbiot-controller.appspot.com',
    iosBundleId: 'com.example.flutterApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCHhhC5fcoxG4pNlKqQfFSFcCGitB45HK8',
    appId: '1:512474153375:ios:60f4316d5739400b033daa',
    messagingSenderId: '512474153375',
    projectId: 'nema-nbiot-controller',
    databaseURL: 'https://nema-nbiot-controller-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'nema-nbiot-controller.appspot.com',
    iosBundleId: 'com.example.flutterApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBS08sAU3ip3SBpQnYccoPUpscPdoqzqtk',
    appId: '1:512474153375:web:8691501ad523bead033daa',
    messagingSenderId: '512474153375',
    projectId: 'nema-nbiot-controller',
    authDomain: 'nema-nbiot-controller.firebaseapp.com',
    databaseURL: 'https://nema-nbiot-controller-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'nema-nbiot-controller.appspot.com',
    measurementId: 'G-VKSSX7R4HR',
  );
}