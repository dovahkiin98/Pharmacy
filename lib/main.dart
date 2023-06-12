import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pharmacy/ui/add_med/add_med_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/repository.dart';
import 'theme/theme.dart';
import 'ui/auth/login/login_page.dart';
import 'ui/home/home_container.dart';

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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isUserLoggedIn = context.read<Repository>().isUserLoggedIn;

    return MaterialApp(
      title: 'Pharmacy',
      theme: theme,
      routes: Routes.routes,
      initialRoute: isUserLoggedIn ? Routes.HOME : Routes.LOGIN,
    );
  }
}

class Routes {
  static const HOME = 'home';
  static const LOGIN = 'login';
  static const ADD_MED = 'add_med';

  static final routes = <String, WidgetBuilder>{
    LOGIN: (_) => const LoginPage(),
    HOME: (_) => const HomeContainer(),
    ADD_MED: (_) => const AddMedPage(),
  };
}
