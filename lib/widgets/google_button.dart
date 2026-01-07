import 'package:flutter/material.dart';

class GoogleButton extends StatelessWidget {
  final Future<void> Function()? onPressed; // accepte les fonctions async

  const GoogleButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Image.asset(
        'assets/google.png', // Assure-toi d'avoir le logo Google ici
        height: 24.0,
        width: 24.0,
      ),
      label: const Text(
        "Se connecter avec Google",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      onPressed: onPressed != null
          ? () async {
              await onPressed!();
            }
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 2,
      ),
    );
  }
}
