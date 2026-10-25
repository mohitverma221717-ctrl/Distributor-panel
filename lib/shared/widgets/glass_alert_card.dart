import 'package:flutter/material.dart';

class GlassAlertCard extends StatelessWidget {
  final String title;
  final String timeAgo;
  final bool isUnread;
  final VoidCallback onTap;

  const GlassAlertCard({
    super.key,
    required this.title,
    required this.timeAgo,
    this.isUnread = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.42),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.68),
            width: 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Glowing blue dot indicator
            Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: isUnread ? const Color(0xFF0284C7) : const Color(0xFF94A3B8),
                shape: BoxShape.circle,
                boxShadow: isUnread
                    ? [
                        BoxShadow(
                          color: const Color(0xFF38BDF8).withOpacity(0.8),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    timeAgo,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
