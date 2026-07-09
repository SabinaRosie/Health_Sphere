import 'package:flutter/material.dart';
import 'package:health_sphere/core/theme/app_colors.dart';

class ValidationHelper extends StatelessWidget {
  final String title;
  final List<ValidationRequirementItem> requirements;

  const ValidationHelper({
    super.key,
    required this.title,
    required this.requirements,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC), // very light slate/grey
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: AppColors.textMain,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...requirements.map((req) => _buildRequirementRow(req)),
        ],
      ),
    );
  }

  Widget _buildRequirementRow(ValidationRequirementItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        children: [
          Icon(
            item.isMet ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: item.isMet ? const Color(0xFF10B981) : const Color(0xFFEF4444),
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              item.text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: item.isMet ? const Color(0xFF047857) : const Color(0xFFB91C1C),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ValidationRequirementItem {
  final String text;
  final bool isMet;

  ValidationRequirementItem({
    required this.text,
    required this.isMet,
  });
}
