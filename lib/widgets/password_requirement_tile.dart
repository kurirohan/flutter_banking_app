import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PasswordRequirementTile extends StatelessWidget {
  final String text;
  final bool met;

  const PasswordRequirementTile({
    super.key,
    required this.text,
    required this.met,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            size: 18,
            color: met ? AppColors.success : AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: met ? AppColors.success : AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

