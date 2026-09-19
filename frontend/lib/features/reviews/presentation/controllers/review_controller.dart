import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tarot_consultation_app/core/network/api_exception.dart';
import 'package:tarot_consultation_app/features/reviews/data/review_repository.dart';
import 'package:tarot_consultation_app/features/reviews/domain/review_state.dart';
import 'package:tarot_consultation_app/models/create_review_request_model.dart';
import 'package:tarot_consultation_app/models/review_model.dart';

final submitReviewProvider = StateNotifierProvider.family
    .autoDispose<SubmitReviewNotifier, ReviewSubmissionState, int>((ref, bookingId) {
  final repository = ref.watch(reviewRepositoryProvider);
  return SubmitReviewNotifier(repository, bookingId);
});

class SubmitReviewNotifier extends StateNotifier<ReviewSubmissionState> {
  final ReviewRepository _repository;
  final int _bookingId;

  SubmitReviewNotifier(this._repository, this._bookingId)
      : super(const ReviewSubmissionState());

  void setRating(int rating) {
    state = state.copyWith(rating: rating);
  }

  void setComment(String comment) {
    state = state.copyWith(comment: comment);
  }

  Future<ReviewModel?> submitReview() async {
    final comment = state.comment.trim();
    if (comment.isEmpty) {
      state = state.copyWith(errorMessage: () => 'Please provide a short reflection or feedback comment.');
      return null;
    }

    state = state.copyWith(isSubmitting: true, errorMessage: () => null);
    try {
      final request = CreateReviewRequestModel(
        bookingId: _bookingId,
        rating: state.rating,
        comment: comment,
      );

      final review = await _repository.createReview(request);
      state = state.copyWith(
        isSubmitting: false,
        isSubmitted: true,
      );
      return review;
    } on ApiException catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: () => e.message,
      );
      return null;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: () => 'Could not submit review: $e',
      );
      return null;
    }
  }
}

final publicReviewsProvider =
    StateNotifierProvider<PublicReviewsNotifier, PublicReviewsState>((ref) {
  final repository = ref.watch(reviewRepositoryProvider);
  return PublicReviewsNotifier(repository);
});

class PublicReviewsNotifier extends StateNotifier<PublicReviewsState> {
  final ReviewRepository _repository;

  PublicReviewsNotifier(this._repository) : super(const PublicReviewsState()) {
    loadReviews();
  }

  Future<void> loadReviews() async {
    state = state.copyWith(isLoading: true, errorMessage: () => null);
    try {
      final reviews = await _repository.getApprovedReviews();
      state = state.copyWith(
        reviews: reviews,
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
        errorMessage: () => 'Failed to load reviews: $e',
      );
    }
  }

  Future<void> refresh() => loadReviews();
}
