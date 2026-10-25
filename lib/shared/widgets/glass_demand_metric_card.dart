import 'package:flutter/material.dart';

class GlassDemandMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color accentColor;
  final Color bgColor;
  final Color glowColor;
  final List<Color> iconGradient;
  final VoidCallback onTap;

  const GlassDemandMetricCard({
    super.key,
    required this.title,
    required this.value,
    this.unit = 'units',
    required this.icon,
    required this.accentColor,
    required this.bgColor,
    required this.glowColor,
    required this.iconGradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.72),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Glowing circular icon container
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: iconGradient,
                ),
                boxShadow: [
                  BoxShadow(
                    color: glowColor.withOpacity(0.55),
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 19,
                ),
              ),
            ),
            const SizedBox(height: 7),
            // Title
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: accentColor,
                letterSpacing: -0.1,
              ),
            ),
            const SizedBox(height: 2),
            // Value
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: accentColor,
                  letterSpacing: -0.4,
                  height: 1.1,
                ),
              ),
            ),
            const SizedBox(height: 1),
            // Unit
            Text(
              unit,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: accentColor.withOpacity(0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
