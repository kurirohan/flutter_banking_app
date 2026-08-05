// PayMaye — Shared currency formatting utility
//
// Centralizes currency display so a locale/currency change (e.g. swapping
// PHP for another currency later) only requires editing this file.
import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static const String defaultCurrency = 'PHP';
  static const String _symbol = '₱';

  static final NumberFormat _amountFormat = NumberFormat('#,##0.00', 'en_PH');

  /// Formats an amount as "₱12,345.00".
  static String format(double amount, {String currency = defaultCurrency}) {
    return '${_symbolFor(currency)}${_amountFormat.format(amount)}';
  }

  /// Formats a signed amount for transaction lists, e.g. "+₱5,000.00" / "-₱89.99".
  static String formatSigned(double amount, {bool isCredit = false, String currency = defaultCurrency}) {
    return '${isCredit ? '+' : '-'}${format(amount, currency: currency)}';
  }

  static String _symbolFor(String currency) {
    switch (currency) {
      case 'PHP':
        return _symbol;
      case 'USD':
        return '\$';
      default:
        return '$currency ';
    }
  }
}
