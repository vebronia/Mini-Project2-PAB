import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/destination.dart';

class AddPage extends StatefulWidget {
  final Destination? destination;
  final int? index;

  const AddPage({
    super.key,
    this.destination,
    this.index,
  });

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final nameController = TextEditingController();
  final locationController = TextEditingController();
  final budgetController = TextEditingController();
  final noteController = TextEditingController();

  String? selectedCategory;

  final List<String> categories = ['Pantai', 'Pegunungan', 'Kota'];
  final Map<String, String> categoryLabel = {
    'Pantai': 'Beach',
    'Pegunungan': 'Mountains',
    'Kota': 'City',
  };

  @override
  void initState() {
    super.initState();
    if (widget.destination != null) {
      nameController.text = widget.destination!.name;
      locationController.text = widget.destination!.location;
      budgetController.text = widget.destination!.budget;
      noteController.text = widget.destination!.note;
      selectedCategory = widget.destination!.category;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    locationController.dispose();
    budgetController.dispose();
    noteController.dispose();
    super.dispose();
  }

  void saveData() {
    if (nameController.text.trim().isEmpty ||
        locationController.text.trim().isEmpty ||
        budgetController.text.trim().isEmpty ||
        selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Harap isi semua field termasuk kategori'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final result = Destination(
      id: widget.destination?.id,
      name: nameController.text.trim(),
      location: locationController.text.trim(),
      note: noteController.text.trim(),
      budget: budgetController.text.trim(),
      category: selectedCategory!,
    );

    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.destination != null;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Column(
          children: [
            // ===== APP BAR =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white, size: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isEdit ? 'Edit Destination' : 'New Destination',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            // ===== SCROLLABLE BODY =====
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // ===== DESTINATION NAME =====
                    _sectionLabel('Destination Name'),
                    const SizedBox(height: 8),
                    _buildTextField(
                        controller: nameController,
                        hint: 'e.g., Santorini, Greece'),

                    const SizedBox(height: 16),

                    // ===== LOCATION =====
                    _sectionLabel('Location'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: locationController,
                      hint: 'Search for a city or country',
                      suffixIcon: const Icon(Icons.map_outlined,
                          color: Colors.white54, size: 20),
                    ),

                    const SizedBox(height: 16),

                    // ===== BUDGET =====
                    _sectionLabel('Budget (Rp)'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: budgetController,
                      hint: '0',
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: false, signed: false),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),

                    const SizedBox(height: 16),

                    // ===== CATEGORY =====
                    _sectionLabel('Category'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: categories.map((cat) {
                        final isSelected = selectedCategory == cat;
                        return GestureDetector(
                          onTap: () => setState(() => selectedCategory = cat),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF4ECDC4)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF4ECDC4)
                                    : Colors.white38,
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              categoryLabel[cat] ?? cat,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.white70,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),

                    // ===== NOTES =====
                    _sectionLabel('Notes'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: noteController,
                      hint: 'What are you most excited about?\n(Packing lists, places to eat, things to do...)',
                      maxLines: 4,
                    ),

                    const SizedBox(height: 30),

                    // ===== SAVE BUTTON =====
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: saveData,
                        icon: const Icon(Icons.bookmark_border, color: Colors.white),
                        label: Text(
                          isEdit ? 'Update Destination' : 'Save Destination',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B6CA8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Center(
                      child: Text(
                        "Your destination will be added to your 'Dream List'",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(text,
        style: const TextStyle(
            color: Colors.white54,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5));
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.12), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF4ECDC4), width: 1.5),
        ),
      ),
    );
  }
}