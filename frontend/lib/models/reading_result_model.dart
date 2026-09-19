import 'package:intl/intl.dart';
import 'package:tarot_consultation_app/models/rune_reading_model.dart';
import 'package:tarot_consultation_app/models/tarot_card_reading_model.dart';

class ReadingResultModel {
  final int id;
  final int bookingId;
  final String bookingReference;
  final int customerId;
  final String customerName;
  final String customerEmail;
  final String serviceName;
  final String summary;
  final String advice;
  final String? outcome;
  final String? additionalNotes;
  final List<TarotCardReadingModel> tarotCards;
  final List<RuneReadingModel> runeReadings;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ReadingResultModel({
    required this.id,
    required this.bookingId,
    required this.bookingReference,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
    required this.serviceName,
    required this.summary,
    required this.advice,
    this.outcome,
    this.additionalNotes,
    this.tarotCards = const [],
    this.runeReadings = const [],
    required this.createdAt,
    this.updatedAt,
  });

  factory ReadingResultModel.fromJson(Map<String, dynamic> json) {
    var rawCards = json['tarotCards'];
    List<TarotCardReadingModel> cards = [];
    if (rawCards is List) {
      cards = rawCards
          .map((item) => TarotCardReadingModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    var rawRunes = json['runeReadings'];
    List<RuneReadingModel> runes = [];
    if (rawRunes is List) {
      runes = rawRunes
          .map((item) => RuneReadingModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return ReadingResultModel(
      id: json['id'] as int? ?? 0,
      bookingId: json['bookingId'] as int? ?? 0,
      bookingReference: json['bookingReference'] as String? ?? '',
      customerId: json['customerId'] as int? ?? 0,
      customerName: json['customerName'] as String? ?? '',
      customerEmail: json['customerEmail'] as String? ?? '',
      serviceName: json['serviceName'] as String? ?? 'Consultation Reading',
      summary: json['summary'] as String? ?? '',
      advice: json['advice'] as String? ?? '',
      outcome: json['outcome'] as String?,
      additionalNotes: json['additionalNotes'] as String?,
      tarotCards: cards,
      runeReadings: runes,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingId': bookingId,
      'bookingReference': bookingReference,
      'customerId': customerId,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'serviceName': serviceName,
      'summary': summary,
      'advice': advice,
      'outcome': outcome,
      'additionalNotes': additionalNotes,
      'tarotCards': tarotCards.map((c) => c.toJson()).toList(),
      'runeReadings': runeReadings.map((r) => r.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  bool get hasTarotCards => tarotCards.isNotEmpty;
  bool get hasRuneReadings => runeReadings.isNotEmpty;
  int get cardCount => tarotCards.length + runeReadings.length;

  String get formattedDate => DateFormat('MMMM d, yyyy').format(createdAt);
  String get formattedDateTime => DateFormat('MMM d, yyyy • h:mm a').format(createdAt);
}
