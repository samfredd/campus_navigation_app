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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyCB9jFtpjoTz1Y6IrxGLC4N861mcqTyr3Q',
    appId: '1:185782392776:web:25e89c9c35573f9e1a12fd',
    messagingSenderId: '185782392776',
    projectId: 'learning-19563',
    authDomain: 'learning-19563.firebaseapp.com',
    storageBucket: 'learning-19563.appspot.com',
    measurementId: 'G-YX09NY90H6',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAo2VDc4JOL_9O2tCeIpWL_KXMbCxPbIQU',
    appId: '1:940576499143:android:8b5f4a65deb6edb9b4e5e2',
    messagingSenderId: '940576499143',
    projectId: 'oou-nav',
    storageBucket: 'oou-nav.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD0eIghNCr_b6PcC3skuCkFgqUekSeYS0g',
    appId: '1:940576499143:ios:9a0855e58ae5b649b4e5e2',
    messagingSenderId: '940576499143',
    projectId: 'oou-nav',
    storageBucket: 'oou-nav.appspot.com',
    iosBundleId: 'com.example.locationApp',
  );

}