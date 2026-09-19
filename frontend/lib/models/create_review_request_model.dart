class CreateReviewRequestModel {
  final int bookingId;
  final int rating;
  final String comment;

  const CreateReviewRequestModel({
    required this.bookingId,
    required this.rating,
    required this.comment,
  });

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'rating': rating,
      'comment': comment,
    };
  }
}
