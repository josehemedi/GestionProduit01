import 'package:flutter/material.dart';
import 'package:gestion_produit/views/auth/login_page.dart';
import 'package:gestion_produit/views/auth/dashboard_screen.dart';
import 'package:gestion_produit/views/auth/sign_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // <-- obligatoire pour Web

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialise Firebase avec les options adaptées à la plateforme
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // Page d'accueil : ici SignUpPage, tu peux mettre LoginPage si tu veux
      home: const LoginPage(),
    );
  }
}
