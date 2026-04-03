import 'package:flutter/material.dart';

class DailyMessageCard extends StatelessWidget {
  const DailyMessageCard({
    super.key,
    required this.message,
    required this.zodiacHint,
    required this.luckyColor,
    required this.dateText,
  });

  final String message;
  final String zodiacHint;
  final String luckyColor;
  final String dateText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFF7EF),
            Color(0xFFFDEEF4),
            Color(0xFFEFF7FB),
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F8F6D6D),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dateText,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  letterSpacing: 0.3,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF8D7A83),
                ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                  color: const Color(0xFF5F4F59),
                ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 1,
            color: const Color(0x22A07D87),
          ),
          const SizedBox(height: 14),
          _MetaRow(
            icon: Icons.stars_rounded,
            text: zodiacHint,
          ),
          const SizedBox(height: 10),
          _MetaRow(
            icon: Icons.palette_outlined,
            text: 'Lucky color: $luckyColor',
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF7B6A73)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF776771),
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }
}
