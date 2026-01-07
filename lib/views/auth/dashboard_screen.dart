import 'package:flutter/material.dart';
import 'package:gestion_produit/views/article/add_article_screen.dart';
import 'package:gestion_produit/views/article/liste_article.dart'; // <-- Assure-toi que ce fichier existe

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _modules = [
    {
      'title': 'Tableau de Bord',
      'icon': Icons.bar_chart,
      'color': const Color(0xFF1976D2),
    },
    {
      'title': 'Produits',
      'icon': Icons.list_alt,
      'color': const Color(0xFF16A085),
    },
    {
      'title': 'Clients',
      'icon': Icons.people,
      'color': const Color(0xFF43A047),
    },
    {
      'title': 'Devis',
      'icon': Icons.calculate_outlined,
      'color': const Color(0xFF7F8C8D),
    },
    // ... ajoute les autres modules si nécessaire
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        leading: const Icon(Icons.menu, color: Colors.white),
        title: const Text(
          'GESTMOB',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: const [
          Icon(Icons.help_outline, color: Colors.white),
          SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          _buildHeaderStats(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: GridView.builder(
                itemCount: _modules.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemBuilder: (context, index) {
                  return _buildTile(_modules[index]);
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          switch (index) {
            case 1: // Ajouter
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddArticleScreen()),
              );
              break;
            case 2: // Lister
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ListeArticlePage()),
              );
              break;
          }
        },
        selectedItemColor: const Color(0xFF1976D2),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Ajouter',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.format_list_bulleted),
            label: 'Lister',
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStats() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem(Icons.arrow_upward, "C.A (Mois)", "0.00 DA"),
          _statItem(Icons.arrow_downward, "Achats (Mois)", "0.00 DA"),
        ],
      ),
    );
  }

  Widget _statItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTile(Map<String, dynamic> data) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: data['color'],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        splashColor: Colors.white24,
        onTap: () {
          if (data['title'] == 'Produits') {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const AddArticleScreen()));
          }
          // Tu peux ajouter d'autres navigations selon le titre du module
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(data['icon'], color: Colors.white, size: 32),
            const SizedBox(height: 8),
            Text(
              data['title'],
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
