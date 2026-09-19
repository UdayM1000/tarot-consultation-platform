class TarotCardReadingModel {
  final int id;
  final String cardName;
  final String position;
  final String interpretation;

  const TarotCardReadingModel({
    required this.id,
    required this.cardName,
    required this.position,
    required this.interpretation,
  });

  factory TarotCardReadingModel.fromJson(Map<String, dynamic> json) {
    return TarotCardReadingModel(
      id: json['id'] as int? ?? 0,
      cardName: json['cardName'] as String? ?? 'Mystic Card',
      position: json['position'] as String? ?? 'Focus',
      interpretation: json['interpretation'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cardName': cardName,
      'position': position,
      'interpretation': interpretation,
    };
  }
}
