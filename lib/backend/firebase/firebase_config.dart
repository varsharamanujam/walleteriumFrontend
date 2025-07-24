import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyACPOTClXLWLEWA0Cs_qMals3POf7Ciwo4",
            authDomain: "walleterium.firebaseapp.com",
            projectId: "walleterium",
            storageBucket: "walleterium.firebasestorage.app",
            messagingSenderId: "741700316107",
            appId: "1:741700316107:web:bce5c891098a0f9752e44e",
            measurementId: "G-37LX08S5E8"));
  } else {
    await Firebase.initializeApp();
  }
}
