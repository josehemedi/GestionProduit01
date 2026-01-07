import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/Product.dart';
import './liste_article.dart'; // Assure-toi que le chemin est correct

class AddArticleScreen extends StatefulWidget {
  const AddArticleScreen({super.key});

  @override
  State<AddArticleScreen> createState() => _AddArticleScreenState();
}

class _AddArticleScreenState extends State<AddArticleScreen> {
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs pour récupérer les valeurs
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _prixUnitaireController = TextEditingController();
  final TextEditingController _prixVenteController = TextEditingController();

  double _benefice = 0.0;

  @override
  void dispose() {
    _nomController.dispose();
    _stockController.dispose();
    _prixUnitaireController.dispose();
    _prixVenteController.dispose();
    super.dispose();
  }

  // Calcul automatique du bénéfice
  void _calculerBenefice() {
    double pu = double.tryParse(_prixUnitaireController.text) ?? 0.0;
    double pv = double.tryParse(_prixVenteController.text) ?? 0.0;
    setState(() {
      _benefice = pv - pu;
    });
  }

  // Fonction pour enregistrer le produit dans Firestore
  Future<void> _enregistrerProduit() async {
    if (_formKey.currentState!.validate()) {
      try {
        String nomProduit = _nomController.text;
        int stockInitial = int.parse(_stockController.text);
        double prixUnitaire = double.parse(_prixUnitaireController.text);
        double prixVente = double.parse(_prixVenteController.text);
        double benefice = prixVente - prixUnitaire;

        Product produit = Product(
          nomDuProduit: nomProduit,
          prixUnitaire: prixUnitaire,
          prixVente: prixVente,
          benefice: benefice,
          stockInitial: stockInitial,
        );

        await FirebaseFirestore.instance
            .collection('produits')
            .add(produit.toMap());

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Article enregistré avec succès !')),
        );

        // Réinitialiser le formulaire
        _nomController.clear();
        _stockController.clear();
        _prixUnitaireController.clear();
        _prixVenteController.clear();
        setState(() {
          _benefice = 0.0;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'enregistrement : $e')),
        );
      }
    }
  }

  // Fonction pour créer les champs du formulaire
  Widget _buildField(
    String label,
    IconData icon,
    TextInputType type, {
    TextEditingController? controller,
    Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      onChanged: onChanged,
      inputFormatters: type == TextInputType.number
          ? [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(15),
            ]
          : [],
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return "Champ obligatoire";
        return null;
      },
    );
  }

  // 🔹 Fonction pour animation de transition
  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const ListeArticlePage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Animation combinée : slide + fade
        const beginOffset = Offset(1.0, 0.0); // glisse depuis la droite
        const endOffset = Offset.zero;
        const curve = Curves.ease;

        var tween = Tween(
          begin: beginOffset,
          end: endOffset,
        ).chain(CurveTween(curve: curve));
        var fadeTween = Tween<double>(begin: 0.0, end: 1.0);

        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 500), // durée
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ajouter un Article"),
        backgroundColor: const Color(0xFF16A085),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildField(
                "Nom du produit",
                Icons.shopping_bag,
                TextInputType.text,
                controller: _nomController,
              ),
              const SizedBox(height: 15),

              _buildField(
                "Stock initial",
                Icons.inventory_2,
                TextInputType.number,
                controller: _stockController,
              ),
              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      "Prix Unitaire (Achat)",
                      Icons.money,
                      TextInputType.number,
                      controller: _prixUnitaireController,
                      onChanged: (value) => _calculerBenefice(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildField(
                      "Prix de Vente",
                      Icons.sell,
                      TextInputType.number,
                      controller: _prixVenteController,
                      onChanged: (value) => _calculerBenefice(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Affichage du bénéfice
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Bénéfice calculé :",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "${_benefice.toStringAsFixed(2)} DA",
                      style: TextStyle(
                        color: _benefice >= 0 ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Bouton ENREGISTRER
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _enregistrerProduit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A085),
                  ),
                  child: const Text(
                    "ENREGISTRER L'ARTICLE",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // Bouton “Voir les produits” avec animation
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(_createRoute());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text(
                    "VOIR LES PRODUITS",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
