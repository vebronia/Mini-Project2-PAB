import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/destination.dart';
import 'add_page.dart';
import 'detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final supabase = Supabase.instance.client;

  String _searchText = '';
  String? selectedCategory;
  List<Destination> travelList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDestinations();
  }

  Future<void> fetchDestinations() async {
    try {
      setState(() => isLoading = true);
      final response = await supabase
          .from('destinations')
          .select()
          .order('created_at', ascending: false);
      final data = (response as List)
          .map((item) => Destination.fromMap(item))
          .toList();
      if (!mounted) return;
      setState(() {
        travelList = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil data: $e')),
      );
    }
  }

  void showCategoryFilter() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B6CA8).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.tune, color: Color(0xFF4ECDC4), size: 18),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Filter Kategori',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('Pilih kategori destinasi',
                          style: TextStyle(color: Colors.white38, fontSize: 11)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ...['Semua', 'Pantai', 'Pegunungan', 'Kota'].map((cat) {
                final isAll = cat == 'Semua';
                final isSelected = isAll ? selectedCategory == null : selectedCategory == cat;
                final Map<String, IconData> icons = {
                  'Semua': Icons.explore,
                  'Pantai': Icons.beach_access,
                  'Pegunungan': Icons.terrain,
                  'Kota': Icons.location_city,
                };
                final Map<String, Color> colors = {
                  'Semua': const Color(0xFF4ECDC4),
                  'Pantai': const Color(0xFF4ECDC4),
                  'Pegunungan': const Color(0xFF56ab2f),
                  'Kota': const Color(0xFF1B6CA8),
                };
                return GestureDetector(
                  onTap: () {
                    setState(() => selectedCategory = isAll ? null : cat);
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? colors[cat]!.withOpacity(0.15) : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? colors[cat]! : Colors.white.withOpacity(0.08),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: colors[cat]!.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(icons[cat], color: colors[cat], size: 18),
                        ),
                        const SizedBox(width: 12),
                        Text(cat,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 14,
                            )),
                        const Spacer(),
                        if (isSelected)
                          Icon(Icons.check_circle_rounded, color: colors[cat], size: 20),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> addTravel(Destination destination) async {
    try {
      await supabase.from('destinations').insert(destination.toMap());
      await fetchDestinations();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Destinasi berhasil ditambahkan ✅')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambah destinasi: $e')),
      );
    }
  }

  Future<void> updateTravel(Destination destination) async {
    try {
      if (destination.id == null) throw Exception('ID tidak ditemukan');
      await supabase
          .from('destinations')
          .update(destination.toMap())
          .eq('id', destination.id!);
      await fetchDestinations();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Destinasi berhasil diupdate ✅')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal update destinasi: $e')),
      );
    }
  }

  void deleteTravel(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Destinasi"),
        content: const Text("Yakin mau hapus destinasi ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                final item = travelList[index];
                if (item.id == null) throw Exception('ID tidak ditemukan');
                await supabase.from('destinations').delete().eq('id', item.id!);
                if (!mounted) return;
                Navigator.pop(context);
                await fetchDestinations();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Destinasi berhasil dihapus')),
                );
              } catch (e) {
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal menghapus: $e')),
                );
              }
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void showRatingDialog(int realIndex) {
    double tempRating = travelList[realIndex].rating;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Beri Rating',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(travelList[realIndex].name,
                  style: const TextStyle(color: Colors.white60, fontSize: 13)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  return GestureDetector(
                    onTap: () => setDialogState(() => tempRating = (i + 1).toDouble()),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        i < tempRating ? Icons.star : Icons.star_border,
                        color: Colors.amber, size: 36,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),
              Text(
                tempRating == 0 ? 'Pilih bintang' : '${tempRating.toStringAsFixed(0)} / 5',
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.white38)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B6CA8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                setState(() => travelList[realIndex].rating = tempRating);
                Navigator.pop(context);
              },
              child: const Text('Simpan', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  List<Destination> get filteredList {
    List<Destination> list = selectedCategory == null
        ? travelList
        : travelList.where((d) => d.category == selectedCategory).toList();
    if (_searchText.isNotEmpty) {
      list = list.where((d) =>
          d.name.toLowerCase().contains(_searchText.toLowerCase()) ||
          d.location.toLowerCase().contains(_searchText.toLowerCase())).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: fetchDestinations,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== TOP BAR =====
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: const Color(0xFFFFE0B2),
                        child: const Icon(Icons.person, color: Color(0xFFFF8C00), size: 24),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text("Welcome back,",
                              style: TextStyle(fontSize: 12, color: Colors.black54)),
                          Text("Dream Traveler",
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                        ],
                      ),
                    ],
                  ),
                ),

                // ===== HERO BANNER =====
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(
                      children: [
                        Container(
                          height: 200,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF1B6CA8), Color(0xFF4ECDC4)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                        Positioned(
                          right: -20, top: -20,
                          child: Container(
                            width: 150, height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.08),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 30, bottom: -30,
                          child: Container(
                            width: 120, height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.06),
                            ),
                          ),
                        ),
                        const Positioned(
                          bottom: 24, left: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Where is your",
                                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                              Text("next adventure?",
                                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ===== SEARCH BAR =====
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3))
                      ],
                    ),
                    child: TextField(
                      onChanged: (val) => setState(() => _searchText = val),
                      decoration: InputDecoration(
                        hintText: 'Search destinations, hotels...',
                        hintStyle: const TextStyle(fontSize: 14, color: Colors.black38),
                        prefixIcon: const Icon(Icons.search, color: Colors.black38),
                        suffixIcon: GestureDetector(
                          onTap: showCategoryFilter,
                          child: Container(
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: selectedCategory != null ? Colors.orange : const Color(0xFF1B6CA8),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.tune, color: Colors.white, size: 18),
                          ),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                ),

                // ===== FEATURED HEADER =====
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Featured Destinations",
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                      TextButton(
                        onPressed: () {},
                        child: const Text("View Maps",
                            style: TextStyle(color: Color(0xFF1B6CA8), fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),

                // ===== LIST =====
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (filteredList.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(40),
                    child: Center(
                      child: Column(
                        children: const [
                          Icon(Icons.flight_takeoff, size: 60, color: Colors.black26),
                          SizedBox(height: 12),
                          Text("Belum ada destinasi impian.\nTambah sekarang! ✈️",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14, color: Colors.black45)),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredList.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final data = filteredList[index];
                      final realIndex = travelList.indexOf(data);

                      Color cardColor;
                      switch (data.category) {
                        case 'Pantai': cardColor = const Color(0xFF4ECDC4); break;
                        case 'Pegunungan': cardColor = const Color(0xFF56ab2f); break;
                        case 'Kota': cardColor = const Color(0xFF1B6CA8); break;
                        default: cardColor = const Color(0xFF8E44AD);
                      }

                      return GestureDetector(
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (context) => DetailPage(destination: data))),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ===== IMAGE =====
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                                child: Stack(
                                  children: [
                                    Container(
                                      height: 200,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [cardColor.withOpacity(0.6), cardColor],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                      child: Icon(
                                        data.category == 'Pantai' ? Icons.beach_access
                                            : data.category == 'Pegunungan' ? Icons.terrain
                                            : data.category == 'Kota' ? Icons.location_city
                                            : Icons.explore,
                                        size: 80,
                                        color: Colors.white.withOpacity(0.25),
                                      ),
                                    ),
                                    // Badge
                                    Positioned(
                                      top: 14, left: 14,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: cardColor,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(data.category.toUpperCase(),
                                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                                      ),
                                    ),
                                    // Edit button
                                    Positioned(
                                      top: 10, right: 10,
                                      child: _circleIconBtn(
                                        icon: Icons.edit,
                                        color: Colors.orange,
                                        onPressed: () async {
                                          final updated = await Navigator.push(context,
                                              MaterialPageRoute(builder: (context) => AddPage(destination: data, index: realIndex)));
                                          if (updated != null) {
                                            updated.id = data.id;
                                            await updateTravel(updated);
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // ===== INFO =====
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(data.name,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                  color: Color(0xFF1A1A2E)),
                                              overflow: TextOverflow.ellipsis),
                                        ),
                                        // Rating tap
                                        GestureDetector(
                                          onTap: () => showRatingDialog(realIndex),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.amber.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.star, color: Colors.amber, size: 16),
                                                const SizedBox(width: 3),
                                                Text(
                                                  data.rating == 0 ? 'Beri rating' : data.rating.toStringAsFixed(1),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: data.rating == 0 ? Colors.black38 : Colors.amber,
                                                    fontSize: data.rating == 0 ? 11 : 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on, size: 14, color: Colors.black38),
                                        const SizedBox(width: 3),
                                        Text(data.location,
                                            style: const TextStyle(fontSize: 13, color: Colors.black45)),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        RichText(
                                          text: TextSpan(children: [
                                            TextSpan(
                                              text: "Rp ${data.budget}",
                                              style: const TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF1A1A2E)),
                                            ),
                                            const TextSpan(
                                              text: " /trip",
                                              style: TextStyle(fontSize: 12, color: Colors.black38),
                                            ),
                                          ]),
                                        ),
                                        _circleIconBtn(
                                          icon: Icons.delete_outline,
                                          color: Colors.red,
                                          onPressed: () => deleteTravel(realIndex),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AddPage()));
          if (result != null) await addTravel(result);
        },
        backgroundColor: const Color(0xFF1B6CA8),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _circleIconBtn({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 38, height: 38,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 18, color: color),
        onPressed: onPressed,
      ),
    );
  }
}