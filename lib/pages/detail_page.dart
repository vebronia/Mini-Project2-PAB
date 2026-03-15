import 'package:flutter/material.dart';
import '../models/destination.dart';
import 'add_page.dart';

class DetailPage extends StatelessWidget {
  final Destination destination;

  const DetailPage({super.key, required this.destination});

  Color get categoryColor {
    switch (destination.category) {
      case 'Pantai': return const Color(0xFF4ECDC4);
      case 'Pegunungan': return const Color(0xFF56ab2f);
      case 'Kota': return const Color(0xFF1B6CA8);
      default: return const Color(0xFF8E44AD);
    }
  }

  IconData get categoryIcon {
    switch (destination.category) {
      case 'Pantai': return Icons.beach_access;
      case 'Pegunungan': return Icons.terrain;
      case 'Kota': return Icons.location_city;
      default: return Icons.explore;
    }
  }

  String get categoryLabel {
    switch (destination.category) {
      case 'Pantai': return 'Beach';
      case 'Pegunungan': return 'Mountains';
      case 'Kota': return 'City';
      default: return destination.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== HERO =====
              Stack(
                children: [
                  Container(
                    height: 280,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          categoryColor.withOpacity(0.6),
                          categoryColor,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Icon(categoryIcon,
                        size: 100, color: Colors.white.withOpacity(0.15)),
                  ),
                  // Dark overlay bawah
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  // Back button
                  Positioned(
                    top: 12, left: 16,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 38, height: 38,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                  // Edit button
                  Positioned(
                    top: 12, right: 16,
                    child: GestureDetector(
                      onTap: () async {
                        final updated = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AddPage(destination: destination),
                          ),
                        );
                        if (updated != null && context.mounted) {
                          Navigator.pop(context, updated);
                        }
                      },
                      child: Container(
                        width: 38, height: 38,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.edit_outlined,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                  // Badge kategori
                  Positioned(
                    bottom: 20, left: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: categoryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        categoryLabel.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // ===== CONTENT =====
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama + Rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            destination.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                        ),
                        if (destination.rating > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  destination.rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: Colors.amber,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Lokasi
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Color(0xFF4ECDC4), size: 16),
                        const SizedBox(width: 4),
                        Text(
                          destination.location,
                          style: const TextStyle(color: Colors.white60, fontSize: 14),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ===== INFO CARDS =====
                    Row(
                      children: [
                        Expanded(
                          child: _infoCard(
                            icon: Icons.account_balance_wallet_outlined,
                            label: 'Budget',
                            value: 'Rp ${destination.budget}',
                            color: const Color(0xFF4ECDC4),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _infoCard(
                            icon: Icons.category_outlined,
                            label: 'Kategori',
                            value: categoryLabel,
                            color: categoryColor,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ===== NOTES =====
                    if (destination.note.isNotEmpty) ...[
                      const Text(
                        'Notes',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.10)),
                        ),
                        child: Text(
                          destination.note,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}