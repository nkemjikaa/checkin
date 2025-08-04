import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'login.dart';
import 'nin_checkin.dart';
import 'options.dart';
import 'vc_checkin.dart';
import 'nin_registration.dart';
import 'unregistered_nin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Checkin',
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/nincheckin': (context) => NINCheckInScreen(),
        '/options': (context) => OptionsScreen(),
        '/vccheckin': (context) =>  VCCheckInScreen(),
      }
    );
  }
}