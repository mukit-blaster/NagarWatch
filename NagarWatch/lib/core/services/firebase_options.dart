import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD_YOUR_ANDROID_API_KEY',
    appId: '1:YOUR_PROJECT_ID:android:YOUR_ANDROID_APP_ID',
    messagingSenderId: 'YOUR_PROJECT_ID',
    projectId: 'nagarwatch-25693',
    databaseURL: 'https://nagarwatch-25693.firebaseio.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD_YOUR_IOS_API_KEY',
    appId: '1:YOUR_PROJECT_ID:ios:YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_PROJECT_ID',
    projectId: 'nagarwatch-25693',
    databaseURL: 'https://nagarwatch-25693.firebaseio.com',
    iosBundleId: 'com.nagarwatch.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD_YOUR_WEB_API_KEY',
    appId: '1:YOUR_PROJECT_ID:web:YOUR_WEB_APP_ID',
    messagingSenderId: 'YOUR_PROJECT_ID',
    projectId: 'nagarwatch-25693',
    authDomain: 'nagarwatch-25693.firebaseapp.com',
    databaseURL: 'https://nagarwatch-25693.firebaseio.com',
    storageBucket: 'nagarwatch-25693.appspot.com',
    measurementId: 'G-YOUR_MEASUREMENT_ID',
  );

  static FirebaseOptions get currentPlatform {
    return android; // Default to Android; IDE will auto-detect based on build context
  }
}
