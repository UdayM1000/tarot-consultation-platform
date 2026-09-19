import '../core/constants/app_constants.dart';

class ReadingServiceModel {
  final int id;
  final int categoryId;
  final String categoryName;
  final String name;
  final String slug;
  final String description;
  final double price;
  final int durationMinutes;
  final bool active;
  final bool questionRequired;
  final String? cardCountDescription;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ReadingServiceModel({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.name,
    required this.slug,
    required this.description,
    required this.price,
    required this.durationMinutes,
    this.active = true,
    this.questionRequired = false,
    this.cardCountDescription,
    this.createdAt,
    this.updatedAt,
  });

  factory ReadingServiceModel.fromJson(Map<String, dynamic> json) {
    return ReadingServiceModel(
      id: (json['id'] as num).toInt(),
      categoryId: (json['categoryId'] as num).toInt(),
      categoryName: json['categoryName'] as String? ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 0,
      active: json['active'] as bool? ?? true,
      questionRequired: json['questionRequired'] as bool? ?? false,
      cardCountDescription: json['cardCountDescription'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'name': name,
      'slug': slug,
      'description': description,
      'price': price,
      'durationMinutes': durationMinutes,
      'active': active,
      'questionRequired': questionRequired,
      'cardCountDescription': cardCountDescription,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  String get formattedPrice => '${AppConstants.currencySymbol}${price.toStringAsFixed(2)}';

  String get formattedDuration => '$durationMinutes mins';

  ReadingServiceModel copyWith({
    int? id,
    int? categoryId,
    String? categoryName,
    String? name,
    String? slug,
    String? description,
    double? price,
    int? durationMinutes,
    bool? active,
    bool? questionRequired,
    String? cardCountDescription,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReadingServiceModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      price: price ?? this.price,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      active: active ?? this.active,
      questionRequired: questionRequired ?? this.questionRequired,
      cardCountDescription: cardCountDescription ?? this.cardCountDescription,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReadingServiceModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'ReadingServiceModel(id: $id, name: $name, category: $categoryName, price: $price, duration: $durationMinutes min)';
}
