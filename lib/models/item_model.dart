class ItemModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String location;
  final DateTime datePosted;
  final DateTime dateLostFound;
  final ItemType type; // lost or found
  final String imagePath;
  final String userEmail;
  final String userPhone;
  final ItemStatus status;

  ItemModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.datePosted,
    required this.dateLostFound,
    required this.type,
    required this.imagePath,
    required this.userEmail,
    this.userPhone = '',
    this.status = ItemStatus.active,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'category': category,
    'location': location,
    'datePosted': datePosted.toIso8601String(),
    'dateLostFound': dateLostFound.toIso8601String(),
    'type': type.name,
    'imagePath': imagePath,
    'userEmail': userEmail,
    'userPhone': userPhone,
    'status': status.name,
  };

  static ItemModel fromJson(Map<String, dynamic> json) => ItemModel(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    category: json['category'],
    location: json['location'],
    datePosted: DateTime.parse(json['datePosted']),
    dateLostFound: DateTime.parse(json['dateLostFound']),
    type: ItemType.values.firstWhere((e) => e.name == json['type']),
    imagePath: json['imagePath'],
    userEmail: json['userEmail'],
    userPhone: json['userPhone'] ?? '',
    status: ItemStatus.values.firstWhere((e) => e.name == json['status']),
  );
}

enum ItemType { lost, found }

enum ItemStatus { active, resolved, inactive }

class ItemCategories {
  static const List<String> categories = [
    'Electronics',
    'Personal Items',
    'Clothing',
    'Bags',
    'Books',
    'Keys',
    'Jewelry',
    'Documents',
    'Sports Equipment',
    'Other',
  ];
}