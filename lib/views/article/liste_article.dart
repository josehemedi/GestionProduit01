import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ListeArticlePage extends StatelessWidget {
  const ListeArticlePage({super.key});

  @override
  Widget build(BuildContext context) {
    final CollectionReference articles = FirebaseFirestore.instance.collection(
      'produits',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des Articles'),
        backgroundColor: Colors.green.shade700, // AppBar en vert
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: articles.orderBy('nom_du_produit').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('Aucun article trouvé.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: Colors.green.shade300, // bordure verte
                    width: 1,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Colors.green.shade300, // vert
                    child: Text(
                      (index + 1).toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    data['nom_du_produit'] ?? 'Sans nom',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Prix vente: ${data['prix_vente'] ?? '-'}',
                        style: const TextStyle(fontSize: 13),
                      ),
                      Text(
                        'Prix unitaire: ${data['prix_initaire'] ?? '-'}',
                        style: const TextStyle(fontSize: 13),
                      ),
                      Text(
                        'Stock: ${data['stock_initial'] ?? '-'}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.green, // flèche verte
                  ),
                  onTap: () {
                    // Page de détail ou action future
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
