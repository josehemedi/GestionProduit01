import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // ✅ Import nécessaire
import 'package:gestion_produit/views/auth/sign_page.dart';
import 'package:gestion_produit/widgets/google_button.dart';
import 'package:gestion_produit/widgets/custom_appbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gestion_produit/views/auth/dashboard_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  File? _imageFile;

  // Instance de l'image picker
  final ImagePicker _picker = ImagePicker();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // 🔹 Fonction pour ouvrir la galerie
  Future<void> _pickImage() async {
    try {
      // Ouvre la galerie du téléphone
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Optimisation légère de l'image
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      _showMessage("Erreur lors de la sélection de l'image : $e");
    }
  }

  // 🔹 Connexion email / mot de passe
  Future<void> _loginWithEmailPassword() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      _showMessage("Veuillez remplir tous les champs");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;
      Navigator.of(context).pushReplacement(_createRouteToDashboard());
    } on FirebaseAuthException catch (e) {
      String message = "Données incorrectes";
      if (e.code == 'user-not-found') {
        message = "Aucun utilisateur trouvé avec cet email";
      } else if (e.code == 'wrong-password') {
        message = "Mot de passe incorrect";
      }
      _showMessage(message);
    } catch (e) {
      _showMessage("Erreur : $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 🔹 Connexion Google
  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      if (!mounted) return;
      Navigator.of(context).pushReplacement(_createRouteToDashboard());
    } catch (e) {
      _showMessage("Erreur Google : $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // 🔹 Fonction animation vers Dashboard
  Route _createRouteToDashboard() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const DashboardScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const beginOffset = Offset(1.0, 0.0);
        const endOffset = Offset.zero;
        const curve = Curves.ease;
        var tween = Tween(
          begin: beginOffset,
          end: endOffset,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      transitionDuration: const Duration(milliseconds: 500),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(title: "Dorcas BM,"),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // --- DÉBUT : PHOTO DE PROFIL CLIQUABLE ---
                GestureDetector(
                  onTap:
                      _pickImage, // ✅ Ouvre la galerie quand on clique sur l'image
                  child: Stack(
                    children: [
                      // L'image circulaire (Avatar)
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: _imageFile != null
                            ? FileImage(_imageFile!)
                            : null,
                        child: _imageFile == null
                            ? const Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.blue,
                              )
                            : null,
                      ),
                      // Le petit bouton "+" au coin
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black26, blurRadius: 4),
                            ],
                          ),
                          child: const Icon(
                            Icons.add_a_photo,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // --- FIN : PHOTO DE PROFIL ---
                const SizedBox(height: 20),

                const Text(
                  "Connexion",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),

                // 🔹 Email
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email",
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // 🔹 Mot de passe
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Mot de passe",
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // 🔹 Bouton login
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: _isLoading ? null : _loginWithEmailPassword,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Se connecter"),
                ),

                const SizedBox(height: 20),
                const Text("OU"),
                const SizedBox(height: 20),

                GoogleButton(onPressed: _isLoading ? null : _signInWithGoogle),

                const SizedBox(height: 20),

                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignUpPage()),
                    );
                  },
                  child: const Text("Créer un compte"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
