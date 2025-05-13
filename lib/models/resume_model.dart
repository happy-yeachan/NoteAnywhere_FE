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

  const Resume({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.isShared = false,
    this.ownerName = '',
    this.sharingUrl = '',
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
        sharingUrl
      ];

  // 새로운 이력서 생성을 위한 팩토리 메서드
  factory Resume.create({
    required String title,
    String content = '',
  }) {
    final now = DateTime.now();
    return Resume(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // 임시 ID 생성 방식
      title: title,
      content: content,
      createdAt: now,
      updatedAt: now,
    );
  }
}
