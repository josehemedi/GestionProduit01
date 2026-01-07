import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gestion_produit/widgets/custom_appbar.dart';
import 'package:gestion_produit/widgets/google_button.dart';
import 'login_page.dart'; // Pour rediriger après inscription

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _nomController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // ---------------- Inscription Email/Password ----------------
  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 1️⃣ Création utilisateur Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      // 2️⃣ Enregistrement dans Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'nom': _nomController.text.trim(),
            'email': _emailController.text.trim(),
            'role': 'user',
            'createdAt': Timestamp.now(),
          });

      // 3️⃣ Redirection vers Login
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } on FirebaseAuthException catch (e) {
      String message = "Erreur inconnue";
      if (e.code == 'email-already-in-use') {
        message = "Cet email est déjà utilisé";
      } else if (e.code == 'weak-password') {
        message = "Mot de passe trop faible (minimum 6 caractères)";
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ---------------- Google Sign-In ----------------
  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // utilisateur a annulé

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      // Enregistrement Firestore si nouvel utilisateur
      final userDoc = FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid);
      if ((await userDoc.get()).exists == false) {
        await userDoc.set({
          'nom': userCredential.user!.displayName ?? '',
          'email': userCredential.user!.email ?? '',
          'role': 'user',
          'createdAt': Timestamp.now(),
        });
      }

      // Redirection vers Login ou page principale
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? "Erreur Google")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: "Inscription",
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nomController,
                  decoration: InputDecoration(
                    labelText: "Nom complet",
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? "Champ obligatoire"
                      : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email",
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return "Champ obligatoire";
                    if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                      return "Email invalide";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Mot de passe",
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return "Champ obligatoire";
                    if (value.length < 6) return "Minimum 6 caractères";
                    return null;
                  },
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signup,
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text("S'inscrire"),
                  ),
                ),
                const SizedBox(height: 20),
                const Text("OU"),
                const SizedBox(height: 20),
                // ✅ GoogleButton corrigé
                GoogleButton(onPressed: _isLoading ? null : _signInWithGoogle),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
