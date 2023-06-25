import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/repository.dart';
import 'notifications.dart';

/// Firebase Emulator IP (Local IP)
const FIREBASE_IP = "192.168.1.105";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //region System UI
  // Setting StatusBar and NavigationBar colors to transparent.
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
  ));

  // Forcing the application to run in only Portrait mode.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);
  //endregion

  //region Firebase Init
  // Initializing the Firebase app with dummy information.
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: '123',
      appId: 'pharmacy',
      messagingSenderId: '',
      projectId: 'pharmacy',
    ),
  );

  const bool USE_EMULATOR = true;

  if (USE_EMULATOR) {
    // Initializing Firestore with the Firebase Emulator IP.
    FirebaseFirestore.instance.settings = const Settings(
      host: '$FIREBASE_IP:8080',
      sslEnabled: false,
      persistenceEnabled: true,
    );

    // Initializing Firebase Auth with the Firebase Emulator IP.
    await FirebaseAuth.instance.useAuthEmulator(FIREBASE_IP, 9099);
  }
  //endregion

  // Initialize a SharedPreference instance before application starts.
  final prefs = await SharedPreferences.getInstance();

  await initNotifications();

  runApp(MultiProvider(
    providers: [
      // Create a Repository Singleton to be shared throughout the entire application.
      ChangeNotifierProvider<Repository>(create: (_) => Repository(prefs)),
    ],
    child: const MyApp(),
  ));
}
