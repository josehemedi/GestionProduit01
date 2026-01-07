class Product {
  String? id; // facultatif, utile si tu veux récupérer l'ID du document
  String nomDuProduit;
  double prixUnitaire;
  double prixVente;
  double benefice;
  int stockInitial;

  Product({
    this.id,
    required this.nomDuProduit,
    required this.prixUnitaire,
    required this.prixVente,
    required this.benefice,
    required this.stockInitial,
  });

  // Convertir un Product en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'nom_du_produit': nomDuProduit,
      'prix_unitaire': prixUnitaire,
      'prix_vente': prixVente,
      'benefice': benefice,
      'stock_initial': stockInitial,
    };
  }

  // Convertir un document Firestore en Product
  factory Product.fromMap(Map<String, dynamic> map, {String? id}) {
    return Product(
      id: id,
      nomDuProduit: map['nom_du_produit'] ?? '',
      prixUnitaire: (map['prix_unitaire'] ?? 0).toDouble(),
      prixVente: (map['prix_vente'] ?? 0).toDouble(),
      benefice: (map['benefice'] ?? 0).toDouble(),
      stockInitial: (map['stock_initial'] ?? 0).toInt(),
    );
  }
}
