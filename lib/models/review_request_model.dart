import 'package:equatable/equatable.dart';

// 검토 요청 상태 열거형
enum ReviewRequestStatus {
  pending, // 대기 중
  accepted, // 수락됨
  rejected, // 거절됨
  completed, // 완료됨
  cancelled // 취소됨
}

// 검토 요청 모델
class ReviewRequest extends Equatable {
  final String id;
  final String requesterId; // 요청자 ID
  final String requesterName; // 요청자 이름
  final String reviewerId; // 검토자 ID
  final String reviewerName; // 검토자 이름
  final String resumeId; // 검토할 이력서 ID
  final String resumeTitle; // 검토할 이력서 제목
  final double suggestedPrice; // 제안 가격
  final String message; // 요청 메시지
  final DateTime createdAt; // 요청 생성 시간
  final ReviewRequestStatus status; // 요청 상태
  final String? rejectReason; // 거절 이유 (거절된 경우)
  final DateTime? acceptedAt; // 수락 시간
  final DateTime? completedAt; // 완료 시간
  final String? reviewComment; // 검토 코멘트

  const ReviewRequest({
    required this.id,
    required this.requesterId,
    required this.requesterName,
    required this.reviewerId,
    required this.reviewerName,
    required this.resumeId,
    required this.resumeTitle,
    required this.suggestedPrice,
    required this.message,
    required this.createdAt,
    this.status = ReviewRequestStatus.pending,
    this.rejectReason,
    this.acceptedAt,
    this.completedAt,
    this.reviewComment,
  });

  ReviewRequest copyWith({
    String? id,
    String? requesterId,
    String? requesterName,
    String? reviewerId,
    String? reviewerName,
    String? resumeId,
    String? resumeTitle,
    double? suggestedPrice,
    String? message,
    DateTime? createdAt,
    ReviewRequestStatus? status,
    String? rejectReason,
    DateTime? acceptedAt,
    DateTime? completedAt,
    String? reviewComment,
  }) {
    return ReviewRequest(
      id: id ?? this.id,
      requesterId: requesterId ?? this.requesterId,
      requesterName: requesterName ?? this.requesterName,
      reviewerId: reviewerId ?? this.reviewerId,
      reviewerName: reviewerName ?? this.reviewerName,
      resumeId: resumeId ?? this.resumeId,
      resumeTitle: resumeTitle ?? this.resumeTitle,
      suggestedPrice: suggestedPrice ?? this.suggestedPrice,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      rejectReason: rejectReason ?? this.rejectReason,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      completedAt: completedAt ?? this.completedAt,
      reviewComment: reviewComment ?? this.reviewComment,
    );
  }

  // 요청 상태 변경 메서드들
  ReviewRequest accept() {
    if (status != ReviewRequestStatus.pending) {
      return this;
    }
    return copyWith(
      status: ReviewRequestStatus.accepted,
      acceptedAt: DateTime.now(),
    );
  }

  ReviewRequest reject(String reason) {
    if (status != ReviewRequestStatus.pending) {
      return this;
    }
    return copyWith(
      status: ReviewRequestStatus.rejected,
      rejectReason: reason,
    );
  }

  ReviewRequest complete(String comment) {
    if (status != ReviewRequestStatus.accepted) {
      return this;
    }
    return copyWith(
      status: ReviewRequestStatus.completed,
      completedAt: DateTime.now(),
      reviewComment: comment,
    );
  }

  ReviewRequest cancel() {
    if (status != ReviewRequestStatus.pending &&
        status != ReviewRequestStatus.accepted) {
      return this;
    }
    return copyWith(
      status: ReviewRequestStatus.cancelled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'requesterId': requesterId,
      'requesterName': requesterName,
      'reviewerId': reviewerId,
      'reviewerName': reviewerName,
      'resumeId': resumeId,
      'resumeTitle': resumeTitle,
      'suggestedPrice': suggestedPrice,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'status': status.index,
      'rejectReason': rejectReason,
      'acceptedAt': acceptedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'reviewComment': reviewComment,
    };
  }

  factory ReviewRequest.fromJson(Map<String, dynamic> json) {
    return ReviewRequest(
      id: json['id'],
      requesterId: json['requesterId'],
      requesterName: json['requesterName'],
      reviewerId: json['reviewerId'],
      reviewerName: json['reviewerName'],
      resumeId: json['resumeId'],
      resumeTitle: json['resumeTitle'],
      suggestedPrice: (json['suggestedPrice'] as num).toDouble(),
      message: json['message'],
      createdAt: DateTime.parse(json['createdAt']),
      status: ReviewRequestStatus.values[json['status']],
      rejectReason: json['rejectReason'],
      acceptedAt: json['acceptedAt'] != null
          ? DateTime.parse(json['acceptedAt'])
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      reviewComment: json['reviewComment'],
    );
  }

  // 새 검토 요청 생성 팩토리 메서드
  factory ReviewRequest.create({
    required String requesterId,
    required String requesterName,
    required String reviewerId,
    required String reviewerName,
    required String resumeId,
    required String resumeTitle,
    required double suggestedPrice,
    required String message,
  }) {
    return ReviewRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      requesterId: requesterId,
      requesterName: requesterName,
      reviewerId: reviewerId,
      reviewerName: reviewerName,
      resumeId: resumeId,
      resumeTitle: resumeTitle,
      suggestedPrice: suggestedPrice,
      message: message,
      createdAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        requesterId,
        requesterName,
        reviewerId,
        reviewerName,
        resumeId,
        resumeTitle,
        suggestedPrice,
        message,
        createdAt,
        status,
        rejectReason,
        acceptedAt,
        completedAt,
        reviewComment,
      ];
}
