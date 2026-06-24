import 'package:bostra/enums/card_brand.dart';
import 'package:flutter/material.dart';

/// Row of the four accepted network logos. When a brand is detected from the
/// card number, the matching badge stays lit and the others dim out.
class CardBrandStrip extends StatelessWidget {
  final CardBrand activeBrand;
  const CardBrandStrip({super.key, required this.activeBrand});

  static const _order = [
    CardBrand.visa,
    CardBrand.mastercard,
    CardBrand.amex,
    CardBrand.discover,
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final brand in _order)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity:
                  (activeBrand != CardBrand.unknown && activeBrand != brand)
                      ? 0.28
                      : 1,
              child: CardBrandBadge(brand: brand),
            ),
          ),
      ],
    );
  }
}

/// A single mini network logo, drawn in code so it needs no image assets.
class CardBrandBadge extends StatelessWidget {
  final CardBrand brand;
  final double width;
  final double height;

  const CardBrandBadge({
    super.key,
    required this.brand,
    this.width = 32,
    this.height = 21,
  });

  @override
  Widget build(BuildContext context) {
    switch (brand) {
      case CardBrand.visa:
        return _frame(
          color: Colors.white,
          border: const Color(0xFFE6E8EB),
          child: const Text(
            'VISA',
            style: TextStyle(
              color: Color(0xFF1A1F71),
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w800,
              fontSize: 9.5,
              letterSpacing: 0.2,
            ),
          ),
        );
      case CardBrand.mastercard:
        return _frame(
          color: const Color(0xFF252525),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: _circle(const Color(0xFFEB001B)),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: _circle(const Color(0xFFF79E1B)),
              ),
            ],
          ),
        );
      case CardBrand.amex:
        return _frame(
          color: const Color(0xFF2E77BC),
          child: const Text(
            'AMEX',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 8,
              letterSpacing: 0.2,
            ),
          ),
        );
      case CardBrand.discover:
        return _frame(
          color: Colors.white,
          border: const Color(0xFFE6E8EB),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'DISC',
                style: TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontWeight: FontWeight.w800,
                  fontSize: 7.5,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 1),
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFFF76B1C),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        );
      case CardBrand.unknown:
        return _frame(
          color: const Color(0xFFF1F3F5),
          child: Icon(Icons.credit_card, size: 13, color: Colors.grey.shade500),
        );
    }
  }

  Widget _circle(Color color) => Container(
        width: 13,
        height: 13,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );

  Widget _frame({
    required Color color,
    Color? border,
    required Widget child,
  }) {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        border: border != null ? Border.all(color: border) : null,
      ),
      child: child,
    );
  }
}
