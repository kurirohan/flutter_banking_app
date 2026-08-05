// PayMaye — Transaction category → icon/color mapping
//
// Centralized so the Home dashboard and the Accounts/History screen render
// the exact same icon and pastel color for a given category, instead of
// each screen keeping its own copy of this lookup table.
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class TransactionStyle {
  TransactionStyle._();

  static const _icons = {
    'Food & Drinks': Icons.restaurant_rounded,
    'Shopping': Icons.shopping_bag_rounded,
    'Transport': Icons.directions_car_rounded,
    'Entertainment': Icons.movie_rounded,
    'Income': Icons.account_balance_rounded,
    'Utilities': Icons.bolt_rounded,
    'Healthcare': Icons.local_hospital_rounded,
    'Transfer': Icons.send_rounded,
    'Other': Icons.receipt_rounded,
  };

  static const _paletteIndex = {
    'Food & Drinks': 1,
    'Shopping': 0,
    'Transport': 4,
    'Entertainment': 2,
    'Income': 3,
    'Utilities': 2,
    'Healthcare': 3,
    'Transfer': 0,
    'Other': 4,
  };

  static IconData iconFor(String category) =>
      _icons[category] ?? Icons.receipt_rounded;

  /// Returns a `[background, foreground]` pastel color pair for [category].
  static List<Color> colorsFor(String category) {
    final index = _paletteIndex[category] ?? 4;
    return AppColors.pastelPalette[index % AppColors.pastelPalette.length];
  }
}
