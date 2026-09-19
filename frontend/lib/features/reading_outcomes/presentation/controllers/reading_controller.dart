import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tarot_consultation_app/core/network/api_exception.dart';
import 'package:tarot_consultation_app/features/reading_outcomes/data/reading_repository.dart';
import 'package:tarot_consultation_app/features/reading_outcomes/domain/reading_outcomes_state.dart';

final myReadingsProvider =
    StateNotifierProvider<MyReadingsNotifier, MyReadingsState>((ref) {
  final repository = ref.watch(readingRepositoryProvider);
  return MyReadingsNotifier(repository);
});

class MyReadingsNotifier extends StateNotifier<MyReadingsState> {
  final ReadingRepository _repository;

  MyReadingsNotifier(this._repository) : super(const MyReadingsState()) {
    loadReadings();
  }

  Future<void> loadReadings() async {
    state = state.copyWith(isLoading: true, errorMessage: () => null);
    try {
      final readings = await _repository.getCustomerReadings();
      state = state.copyWith(
        readings: readings,
        isLoading: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: () => e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: () => 'Failed to load reading journal: $e',
      );
    }
  }

  Future<void> refresh() => loadReadings();
}

final readingDetailProvider = StateNotifierProvider.family
    .autoDispose<ReadingDetailNotifier, ReadingDetailState, int>((ref, readingId) {
  final repository = ref.watch(readingRepositoryProvider);
  return ReadingDetailNotifier(repository, readingId);
});

class ReadingDetailNotifier extends StateNotifier<ReadingDetailState> {
  final ReadingRepository _repository;
  final int _readingId;

  ReadingDetailNotifier(this._repository, this._readingId)
      : super(ReadingDetailState(readingId: _readingId)) {
    loadReading();
  }

  Future<void> loadReading() async {
    state = state.copyWith(isLoading: true, errorMessage: () => null);
    try {
      final reading = await _repository.getReadingById(_readingId);
      state = state.copyWith(
        reading: () => reading,
        isLoading: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: () => e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: () => 'Failed to load reading dossier: $e',
      );
    }
  }

  Future<void> refresh() => loadReading();
}
