import 'package:flutter/material.dart';

class StatusStyle {
  final Color background;
  final Color foreground;

  const StatusStyle({
    required this.background,
    required this.foreground,
  });
}

StatusStyle projectStatusStyle(String status) {
  switch (status.toLowerCase()) {
    case 'draft':
      return const StatusStyle(
        background: Color(0xFFE5E7EB),
        foreground: Color(0xFF374151),
      );
    case 'active':
      return const StatusStyle(
        background: Color(0xFFDBEAFE),
        foreground: Color(0xFF1D4ED8),
      );
    case 'completed':
      return const StatusStyle(
        background: Color(0xFFDCFCE7),
        foreground: Color(0xFF15803D),
      );
    default:
      return const StatusStyle(
        background: Color(0xFFF3F4F6),
        foreground: Color(0xFF374151),
      );
  }
}

StatusStyle orderStatusStyle(String status) {
  switch (status.toLowerCase()) {
    case 'draft':
      return const StatusStyle(
        background: Color(0xFFE5E7EB),
        foreground: Color(0xFF374151),
      );
    case 'waiting_admin':
      return const StatusStyle(
        background: Color(0xFFFFEDD5),
        foreground: Color(0xFFEA580C),
      );
    case 'waiting_payment':
      return const StatusStyle(
        background: Color(0xFFFEF3C7),
        foreground: Color(0xFFD97706),
      );
    case 'paid':
      return const StatusStyle(
        background: Color(0xFFDBEAFE),
        foreground: Color(0xFF2563EB),
      );
    case 'processing':
      return const StatusStyle(
        background: Color(0xFFE0E7FF),
        foreground: Color(0xFF4F46E5),
      );
    case 'shipped':
      return const StatusStyle(
        background: Color(0xFFCFFAFE),
        foreground: Color(0xFF0891B2),
      );
    case 'ready_pickup':
      return const StatusStyle(
        background: Color(0xFFFCE7F3),
        foreground: Color(0xFFBE185D),
      );
    case 'completed':
      return const StatusStyle(
        background: Color(0xFFDCFCE7),
        foreground: Color(0xFF15803D),
      );
    case 'cancelled':
      return const StatusStyle(
        background: Color(0xFFFEE2E2),
        foreground: Color(0xFFDC2626),
      );
    default:
      return const StatusStyle(
        background: Color(0xFFF3F4F6),
        foreground: Color(0xFF374151),
      );
  }
}