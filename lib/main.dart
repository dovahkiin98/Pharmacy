import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/repository.dart';

const FIREBASE_IP = "192.168.1.105";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //region System UI
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
  ));

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);
  //endregion

  //region Firebase Init
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
    // [Firestore | localhost:8080]
    FirebaseFirestore.instance.settings = const Settings(
      host: '$FIREBASE_IP:8080',
      sslEnabled: false,
      persistenceEnabled: false,
    );

    // [Authentication | localhost:9099]
    await FirebaseAuth.instance.useAuthEmulator(FIREBASE_IP, 9099);
  }
  //endregion

  final prefs = await SharedPreferences.getInstance();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<Repository>(create: (_) => Repository(prefs)),
    ],
    child: const MyApp(),
  ));
}
