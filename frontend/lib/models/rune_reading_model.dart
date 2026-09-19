class RuneReadingModel {
  final int id;
  final String runeName;
  final String position;
  final String interpretation;

  const RuneReadingModel({
    required this.id,
    required this.runeName,
    required this.position,
    required this.interpretation,
  });

  factory RuneReadingModel.fromJson(Map<String, dynamic> json) {
    return RuneReadingModel(
      id: json['id'] as int? ?? 0,
      runeName: json['runeName'] as String? ?? 'Norse Rune',
      position: json['position'] as String? ?? 'Cosmic Focus',
      interpretation: json['interpretation'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'runeName': runeName,
      'position': position,
      'interpretation': interpretation,
    };
  }

  /// Authentic Nordic Elder Futhark rune glyph
  String get glyph {
    switch (runeName.trim().toLowerCase()) {
      case 'fehu':
        return 'ᚠ';
      case 'uruz':
        return 'ᚢ';
      case 'thurisaz':
        return 'ᚦ';
      case 'ansuz':
        return 'ᚨ';
      case 'raidho':
      case 'raido':
        return 'ᚱ';
      case 'kenaz':
      case 'kauno':
        return 'ᚲ';
      case 'gebo':
        return 'ᚷ';
      case 'wunjo':
        return 'ᚹ';
      case 'hagalaz':
        return 'ᚺ';
      case 'nauthiz':
        return 'ᚾ';
      case 'isa':
        return 'ᛁ';
      case 'jera':
        return 'ᛃ';
      case 'eihwaz':
        return 'ᛇ';
      case 'perthro':
        return 'ᛈ';
      case 'algiz':
        return 'ᛉ';
      case 'sowilo':
        return 'ᛋ';
      case 'tiwaz':
        return 'ᛏ';
      case 'berkano':
        return 'ᛒ';
      case 'ehwaz':
        return 'ᛖ';
      case 'mannaz':
        return 'ᛗ';
      case 'laguz':
        return 'ᛚ';
      case 'ingwaz':
        return 'ᛜ';
      case 'dagaz':
        return 'ᛞ';
      case 'othala':
      case 'odal':
        return 'ᛟ';
      default:
        return 'ᛟ';
    }
  }
}
