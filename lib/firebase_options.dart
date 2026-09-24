// File generated manually from Firebase project configuration.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'FirebaseOptions are not configured for Web.',
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;

      case TargetPlatform.iOS:
        throw UnsupportedError(
          'FirebaseOptions are not configured for iOS.',
        );

      case TargetPlatform.macOS:
        throw UnsupportedError(
          'FirebaseOptions are not configured for macOS.',
        );

      case TargetPlatform.windows:
        throw UnsupportedError(
          'FirebaseOptions are not configured for Windows.',
        );

      case TargetPlatform.linux:
        throw UnsupportedError(
          'FirebaseOptions are not configured for Linux.',
        );

      default:
        throw UnsupportedError(
          'This platform is not supported.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDIqhto4Gk7yZphl2vC_1zF5aThSw1hUyE',
    appId: '1:670703818696:android:021f51202ef45940b952fd',
    messagingSenderId: '670703818696',
    projectId: 'cloudsms-e9900',
    storageBucket: 'cloudsms-e9900.firebasestorage.app',
  );
}