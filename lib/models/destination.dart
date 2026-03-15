class Destination {
  String? id;
  String name;
  String location;
  String note;
  String budget;
  String category;
  double rating;

  Destination({
    this.id,
    required this.name,
    required this.location,
    required this.note,
    required this.budget,
    required this.category,
    this.rating = 0,
  });

  factory Destination.fromMap(Map<String, dynamic> map) {
    return Destination(
      id: map['id'],
      name: map['name'] ?? '',
      location: map['location'] ?? '',
      note: map['note'] ?? '',
      budget: map['budget'] ?? '',
      category: map['category'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'location': location,
      'note': note,
      'budget': budget,
      'category': category,
    };
  }
}