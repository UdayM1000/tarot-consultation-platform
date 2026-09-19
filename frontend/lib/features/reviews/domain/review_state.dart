import 'package:tarot_consultation_app/models/review_model.dart';

class ReviewSubmissionState {
  final int rating;
  final String comment;
  final bool isSubmitting;
  final bool isSubmitted;
  final String? errorMessage;

  const ReviewSubmissionState({
    this.rating = 5,
    this.comment = '',
    this.isSubmitting = false,
    this.isSubmitted = false,
    this.errorMessage,
  });

  ReviewSubmissionState copyWith({
    int? rating,
    String? comment,
    bool? isSubmitting,
    bool? isSubmitted,
    String? Function()? errorMessage,
  }) {
    return ReviewSubmissionState(
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }
}

class PublicReviewsState {
  final List<ReviewModel> reviews;
  final bool isLoading;
  final String? errorMessage;

  const PublicReviewsState({
    this.reviews = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  PublicReviewsState copyWith({
    List<ReviewModel>? reviews,
    bool? isLoading,
    String? Function()? errorMessage,
  }) {
    return PublicReviewsState(
      reviews: reviews ?? this.reviews,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }
}
