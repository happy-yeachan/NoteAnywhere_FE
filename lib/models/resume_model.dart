import 'package:equatable/equatable.dart';

class Resume extends Equatable {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isShared;
  final String ownerName;
  final String sharingUrl;

  // 추가 필드
  final int likeCount; // 따봉(좋아요) 수
  final List<String> likedUserIds; // 따봉한 사용자 ID 목록
  final String category; // 이력서 카테고리
  final bool isPremium; // 프리미엄 이력서 여부
  final double reviewPrice; // 검토 요청 기본 가격

  const Resume({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.isShared = false,
    this.ownerName = '',
    this.sharingUrl = '',
    this.likeCount = 0,
    this.likedUserIds = const [],
    this.category = '기타',
    this.isPremium = false,
    this.reviewPrice = 0.0,
  });

  Resume copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isShared,
    String? ownerName,
    String? sharingUrl,
    int? likeCount,
    List<String>? likedUserIds,
    String? category,
    bool? isPremium,
    double? reviewPrice,
  }) {
    return Resume(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isShared: isShared ?? this.isShared,
      ownerName: ownerName ?? this.ownerName,
      sharingUrl: sharingUrl ?? this.sharingUrl,
      likeCount: likeCount ?? this.likeCount,
      likedUserIds: likedUserIds ?? this.likedUserIds,
      category: category ?? this.category,
      isPremium: isPremium ?? this.isPremium,
      reviewPrice: reviewPrice ?? this.reviewPrice,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isShared': isShared,
      'ownerName': ownerName,
      'sharingUrl': sharingUrl,
      'likeCount': likeCount,
      'likedUserIds': likedUserIds,
      'category': category,
      'isPremium': isPremium,
      'reviewPrice': reviewPrice,
    };
  }

  factory Resume.fromJson(Map<String, dynamic> json) {
    return Resume(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isShared: json['isShared'] ?? false,
      ownerName: json['ownerName'] ?? '',
      sharingUrl: json['sharingUrl'] ?? '',
      likeCount: json['likeCount'] ?? 0,
      likedUserIds:
          (json['likedUserIds'] as List?)?.map((e) => e as String).toList() ??
              [],
      category: json['category'] ?? '기타',
      isPremium: json['isPremium'] ?? false,
      reviewPrice: (json['reviewPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        content,
        createdAt,
        updatedAt,
        isShared,
        ownerName,
        sharingUrl,
        likeCount,
        likedUserIds,
        category,
        isPremium,
        reviewPrice,
      ];

  // 새로운 이력서 생성을 위한 팩토리 메서드
  factory Resume.create({
    required String title,
    String content = '',
    String category = '기타',
    double reviewPrice = 0.0,
    bool isShared = false,
  }) {
    final now = DateTime.now();
    return Resume(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // 임시 ID 생성 방식
      title: title,
      content: content,
      createdAt: now,
      updatedAt: now,
      category: category,
      reviewPrice: reviewPrice,
      isShared: isShared,
    );
  }

  // 따봉 추가 메서드
  Resume addLike(String userId) {
    if (likedUserIds.contains(userId)) {
      return this;
    }

    final newLikedUserIds = List<String>.from(likedUserIds)..add(userId);
    return copyWith(
      likeCount: likeCount + 1,
      likedUserIds: newLikedUserIds,
    );
  }

  // 따봉 취소 메서드
  Resume removeLike(String userId) {
    if (!likedUserIds.contains(userId)) {
      return this;
    }

    final newLikedUserIds = List<String>.from(likedUserIds)..remove(userId);
    return copyWith(
      likeCount: likeCount - 1,
      likedUserIds: newLikedUserIds,
    );
  }

  // 이력서가 유료인지 확인
  bool get isReviewPriced => reviewPrice > 0;
}
