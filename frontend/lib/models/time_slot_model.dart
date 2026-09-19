class TimeSlotModel {
  final String startTime;
  final String endTime;
  final bool available;
  final int? readerId;
  final String? readerName;

  const TimeSlotModel({
    required this.startTime,
    required this.endTime,
    required this.available,
    this.readerId,
    this.readerName,
  });

  factory TimeSlotModel.fromJson(Map<String, dynamic> json) {
    return TimeSlotModel(
      startTime: _parseTime(json['startTime']),
      endTime: _parseTime(json['endTime']),
      available: json['available'] as bool? ?? false,
      readerId: (json['readerId'] as num?)?.toInt(),
      readerName: json['readerName'] as String?,
    );
  }

  static String _parseTime(dynamic raw) {
    if (raw == null) return '00:00';
    final str = raw.toString();
    // In case backend sends "HH:mm:ss", format to "HH:mm"
    final parts = str.split(':');
    if (parts.length >= 2) {
      return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
    }
    return str;
  }

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime,
      'endTime': endTime,
      'available': available,
      'readerId': readerId,
      'readerName': readerName,
    };
  }

  /// Format 24h "HH:mm" to "hh:mm a" (e.g., "10:00 AM" or "02:30 PM")
  String format12Hour(String time24) {
    final parts = time24.split(':');
    if (parts.length < 2) return time24;
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '${hour12.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }

  String get formattedStartTime => format12Hour(startTime);
  String get formattedEndTime => format12Hour(endTime);
  String get formattedTimeRange => '$formattedStartTime - $formattedEndTime';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeSlotModel &&
          runtimeType == other.runtimeType &&
          startTime == other.startTime &&
          endTime == other.endTime &&
          readerId == other.readerId;

  @override
  int get hashCode => startTime.hashCode ^ endTime.hashCode ^ (readerId?.hashCode ?? 0);

  @override
  String toString() =>
      'TimeSlotModel($startTime-$endTime, available: $available, reader: $readerName)';
}
