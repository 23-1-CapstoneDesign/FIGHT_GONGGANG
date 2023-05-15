import 'package:flutter/material.dart';

class Comment {
  final String id; // 식별자(데이터베이스 내 레코드 식별)
  final String text;
  final String userId; // 댓글 작성자
  final DateTime timestamp;

  Comment({
    required this.id,
    required this.text,
    required this.userId,
    required this.timestamp,
  });
}
