class UpdateProfileRequestModel {
  final String name;
  final String? phone;
  final String? profileImage;

  const UpdateProfileRequestModel({
    required this.name,
    this.phone,
    this.profileImage,
  });

  factory UpdateProfileRequestModel.fromJson(Map<String, dynamic> json) {
    return UpdateProfileRequestModel(
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String?,
      profileImage: json['profileImage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name.trim(),
    };
    if (phone != null && phone!.trim().isNotEmpty) {
      map['phone'] = phone!.trim();
    }
    if (profileImage != null && profileImage!.trim().isNotEmpty) {
      map['profileImage'] = profileImage!.trim();
    }
    return map;
  }
}
