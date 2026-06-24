import 'package:bostra/enums/card_brand.dart';
import 'package:flutter/services.dart';

/// Formats the card number with brand-aware grouping (4-4-4-4, or 4-6-5 for
/// Amex) and caps the length to the detected network's PAN length.
class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final brand = CardBrand.fromNumber(digits);
    final maxLen = brand.numberLength;
    final trimmed =
        digits.length > maxLen ? digits.substring(0, maxLen) : digits;

    final buffer = StringBuffer();
    var index = 0;
    for (final size in brand.grouping) {
      if (index >= trimmed.length) break;
      final end = (index + size) <= trimmed.length ? index + size : trimmed.length;
      if (buffer.isNotEmpty) buffer.write(' ');
      buffer.write(trimmed.substring(index, end));
      index = end;
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Formats the expiry field as MM/YY, auto-padding an unambiguous month
/// (e.g. "5" -> "05/") and inserting the slash before the year digits.
class ExpiryInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 4) digits = digits.substring(0, 4);

    String formatted;
    if (digits.length <= 2) {
      if (digits.length == 1 && int.parse(digits) > 1) {
        formatted = '0$digits/'; // 3 -> 03/
      } else {
        formatted = digits; // 1, 12
      }
    } else {
      formatted = '${digits.substring(0, 2)}/${digits.substring(2)}';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
