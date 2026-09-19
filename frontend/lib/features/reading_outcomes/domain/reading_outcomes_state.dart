import 'package:tarot_consultation_app/models/reading_result_model.dart';

class MyReadingsState {
  final List<ReadingResultModel> readings;
  final bool isLoading;
  final String? errorMessage;

  const MyReadingsState({
    this.readings = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  MyReadingsState copyWith({
    List<ReadingResultModel>? readings,
    bool? isLoading,
    String? Function()? errorMessage,
  }) {
    return MyReadingsState(
      readings: readings ?? this.readings,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }
}

class ReadingDetailState {
  final int readingId;
  final ReadingResultModel? reading;
  final bool isLoading;
  final String? errorMessage;

  const ReadingDetailState({
    required this.readingId,
    this.reading,
    this.isLoading = false,
    this.errorMessage,
  });

  ReadingDetailState copyWith({
    int? readingId,
    ReadingResultModel? Function()? reading,
    bool? isLoading,
    String? Function()? errorMessage,
  }) {
    return ReadingDetailState(
      readingId: readingId ?? this.readingId,
      reading: reading != null ? reading() : this.reading,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }
}
