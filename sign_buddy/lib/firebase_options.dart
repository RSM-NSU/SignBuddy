
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyAOiQPlVlkjYYb5hkfujL1544-HtoLM5dk',
    appId: '1:878639428076:web:00288f2c9612d71fc610c9',
    messagingSenderId: '878639428076',
    projectId: 'signbuddy-aa2d9',
    authDomain: 'signbuddy-aa2d9.firebaseapp.com',
    storageBucket: 'signbuddy-aa2d9.firebasestorage.app',
    measurementId: 'G-XTYKN87ZS7',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBP77kei-1JNGAmrEmh36cQNHC-GrpicLk',
    appId: '1:878639428076:android:c818f9d49780f047c610c9',
    messagingSenderId: '878639428076',
    projectId: 'signbuddy-aa2d9',
    storageBucket: 'signbuddy-aa2d9.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCBS-wUYMKzVEDtBzMPo2z-eUy28TK29IA',
    appId: '1:878639428076:ios:bc9fca040948c417c610c9',
    messagingSenderId: '878639428076',
    projectId: 'signbuddy-aa2d9',
    storageBucket: 'signbuddy-aa2d9.firebasestorage.app',
    iosBundleId: 'com.example.signBuddy',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCBS-wUYMKzVEDtBzMPo2z-eUy28TK29IA',
    appId: '1:878639428076:ios:bc9fca040948c417c610c9',
    messagingSenderId: '878639428076',
    projectId: 'signbuddy-aa2d9',
    storageBucket: 'signbuddy-aa2d9.firebasestorage.app',
    iosBundleId: 'com.example.signBuddy',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAOiQPlVlkjYYb5hkfujL1544-HtoLM5dk',
    appId: '1:878639428076:web:d71c5f514ea57b0dc610c9',
    messagingSenderId: '878639428076',
    projectId: 'signbuddy-aa2d9',
    authDomain: 'signbuddy-aa2d9.firebaseapp.com',
    storageBucket: 'signbuddy-aa2d9.firebasestorage.app',
    measurementId: 'G-78NKD1K652',
  );

}