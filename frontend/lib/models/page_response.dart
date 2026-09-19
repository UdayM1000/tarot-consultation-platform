class PageResponse<T> {
  final List<T> content;
  final int totalPages;
  final int totalElements;
  final int size;
  final int number;
  final bool isLast;
  final bool isFirst;
  final bool isEmpty;

  const PageResponse({
    required this.content,
    required this.totalPages,
    required this.totalElements,
    required this.size,
    required this.number,
    required this.isLast,
    required this.isFirst,
    required this.isEmpty,
  });

  factory PageResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> json) fromJsonT,
  ) {
    final rawContent = json['content'] as List<dynamic>? ?? [];
    final items = rawContent
        .map((item) => fromJsonT(item as Map<String, dynamic>))
        .toList();

    return PageResponse<T>(
      content: items,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
      totalElements: (json['totalElements'] as num?)?.toInt() ?? 0,
      size: (json['size'] as num?)?.toInt() ?? 20,
      number: (json['number'] as num?)?.toInt() ?? 0,
      isLast: json['last'] as bool? ?? true,
      isFirst: json['first'] as bool? ?? true,
      isEmpty: json['empty'] as bool? ?? items.isEmpty,
    );
  }

  bool get hasNext => !isLast;
}
