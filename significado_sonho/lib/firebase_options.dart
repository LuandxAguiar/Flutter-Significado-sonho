import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: "AIzaSyDevIGUZobKzSwsBcvdi8_3brqwXTkU8dc",
      authDomain: "significado-sonho.firebaseapp.com",
      projectId: "significado-sonho",
      storageBucket: "significado-sonho.firebasestorage.app",
      messagingSenderId: "137345763803",
      appId: "1:137345763803:web:3f6d1b881dc2e94ecc3ffe",
    );
  }
}
