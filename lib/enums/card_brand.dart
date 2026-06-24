/// Supported card networks for the (mock) payment gateway.
///
/// Detection, digit grouping and CVC length all derive from the network so the
/// payment sheet can format input and validate the same way a real processor
/// would surface it to the user.
enum CardBrand {
  visa,
  mastercard,
  amex,
  discover,
  unknown;

  /// Detects the network from the leading digits of [rawNumber].
  /// Non-digit characters (spaces from formatting) are ignored.
  static CardBrand fromNumber(String rawNumber) {
    final digits = rawNumber.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return CardBrand.unknown;

    // Visa — starts with 4.
    if (digits.startsWith('4')) return CardBrand.visa;

    // American Express — 34 or 37.
    if (RegExp(r'^3[47]').hasMatch(digits)) return CardBrand.amex;

    // Mastercard — 51-55, or 2221-2720.
    final firstTwo = digits.length >= 2 ? int.parse(digits.substring(0, 2)) : -1;
    final firstFour =
        digits.length >= 4 ? int.parse(digits.substring(0, 4)) : -1;
    if (firstTwo >= 51 && firstTwo <= 55) return CardBrand.mastercard;
    if (firstFour >= 2221 && firstFour <= 2720) return CardBrand.mastercard;

    // Discover — 6011, 65, or 644-649.
    if (digits.startsWith('6011') || digits.startsWith('65')) {
      return CardBrand.discover;
    }
    final firstThree =
        digits.length >= 3 ? int.parse(digits.substring(0, 3)) : -1;
    if (firstThree >= 644 && firstThree <= 649) return CardBrand.discover;

    return CardBrand.unknown;
  }

  /// Total number of digits in the PAN for this network.
  int get numberLength => this == CardBrand.amex ? 15 : 16;

  /// Number of digits in the security code for this network.
  int get cvcLength => this == CardBrand.amex ? 4 : 3;

  /// Digit grouping used when formatting the PAN (4-6-5 for Amex, else 4-4-4-4).
  List<int> get grouping =>
      this == CardBrand.amex ? const [4, 6, 5] : const [4, 4, 4, 4];

  String get label {
    switch (this) {
      case CardBrand.visa:
        return 'Visa';
      case CardBrand.mastercard:
        return 'Mastercard';
      case CardBrand.amex:
        return 'American Express';
      case CardBrand.discover:
        return 'Discover';
      case CardBrand.unknown:
        return 'Card';
    }
  }
}
