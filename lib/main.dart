import 'AdminPage.dart';
import 'package:flutter/material.dart';
import 'LoginPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StockWise',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFFFFDE3F)),
        useMaterial3: true,
        textTheme: GoogleFonts.aboretoTextTheme(Theme.of(context).textTheme)
      ),
      home: LoginPage(),
    );
  }
}


