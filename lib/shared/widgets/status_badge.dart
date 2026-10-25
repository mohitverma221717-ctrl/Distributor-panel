import 'package:flutter/material.dart';

enum BadgeType { active, pending, processing, delivered, lowStock, urgent }

class StatusBadge extends StatelessWidget {
  final String text;
  final BadgeType type;

  const StatusBadge({
    super.key,
    required this.text,
    this.type = BadgeType.active,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    Color dotColor;

    switch (type) {
      case BadgeType.active:
        bg = const Color(0xFFDCFCE7).withOpacity(0.9);
        fg = const Color(0xFF15803D);
        dotColor = const Color(0xFF16A34A);
        break;
      case BadgeType.pending:
        bg = const Color(0xFFFEF3C7).withOpacity(0.9);
        fg = const Color(0xFFB45309);
        dotColor = const Color(0xFFF59E0B);
        break;
      case BadgeType.processing:
        bg = const Color(0xFFE0E7FF).withOpacity(0.9);
        fg = const Color(0xFF4338CA);
        dotColor = const Color(0xFF6366F1);
        break;
      case BadgeType.delivered:
        bg = const Color(0xFFE0F2FE).withOpacity(0.9);
        fg = const Color(0xFF0369A1);
        dotColor = const Color(0xFF0284C7);
        break;
      case BadgeType.lowStock:
      case BadgeType.urgent:
        bg = const Color(0xFFFFE4E6).withOpacity(0.9);
        fg = const Color(0xFFBE123C);
        dotColor = const Color(0xFFF43F5E);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: fg.withOpacity(0.2),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
