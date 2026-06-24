import 'package:bostra/models/campaign_model.dart';
import 'package:bostra/models/payment_model.dart';
import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/ui/payment/state/payment_state.dart';
import 'package:bostra/ui/payment/view_model/payment_view_model.dart';
import 'package:bostra/ui/payment/widgets/card_brand_badge.dart';
import 'package:bostra/ui/payment/widgets/card_input_formatters.dart';
import 'package:bostra/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Mock card-entry sheet shown before a campaign is funded.
///
/// Returns a [PaymentResult] when the (simulated) charge succeeds, or null if
/// the user dismisses it. The caller is responsible for performing the actual
/// funding once a non-null result comes back.
class PaymentBottomSheet extends ConsumerStatefulWidget {
  final double amount;
  final CampaignModel campaign;

  const PaymentBottomSheet({
    super.key,
    required this.amount,
    required this.campaign,
  });

  static Future<PaymentResult?> show(
    BuildContext context, {
    required double amount,
    required CampaignModel campaign,
  }) {
    return showModalBottomSheet<PaymentResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => PaymentBottomSheet(amount: amount, campaign: campaign),
    );
  }

  @override
  ConsumerState<PaymentBottomSheet> createState() => _PaymentBottomSheetState();
}

class _PaymentBottomSheetState extends ConsumerState<PaymentBottomSheet> {
  final _numberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvcController = TextEditingController();
  final _nameController = TextEditingController();
  final _zipController = TextEditingController();

  String _country = 'Nepal';

  static const _navy = Color(0xFF1A1C4E);
  static const _borderColor = Color(0xFFE3E6EA);
  static const _labelColor = Color(0xFF3C4257);
  static const _hintColor = Color(0xFF9AA0A6);
  static const _valueColor = Color(0xFF1A1F36);

  static const _countries = [
    'Argentina',
    'Australia',
    'Austria',
    'Bangladesh',
    'Belgium',
    'Bhutan',
    'Brazil',
    'Canada',
    'China',
    'Denmark',
    'Egypt',
    'Finland',
    'France',
    'Germany',
    'Greece',
    'Hong Kong',
    'India',
    'Indonesia',
    'Ireland',
    'Israel',
    'Italy',
    'Japan',
    'Kenya',
    'Malaysia',
    'Maldives',
    'Mexico',
    'Nepal',
    'Netherlands',
    'New Zealand',
    'Nigeria',
    'Norway',
    'Pakistan',
    'Philippines',
    'Poland',
    'Portugal',
    'Qatar',
    'Saudi Arabia',
    'Singapore',
    'South Africa',
    'South Korea',
    'Spain',
    'Sri Lanka',
    'Sweden',
    'Switzerland',
    'Thailand',
    'Turkey',
    'United Arab Emirates',
    'United Kingdom',
    'United States',
    'Vietnam',
  ];

  @override
  void initState() {
    super.initState();
    // Provider is a long-lived singleton — clear any prior session's state.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(paymentViewModelProvider.notifier).reset();
    });
  }

  @override
  void dispose() {
    _numberController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    _nameController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paymentViewModelProvider);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Text(
                  'Bostra',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  'Funding ${widget.campaign.startupName}',
                  style: const TextStyle(fontSize: 13, color: _hintColor),
                ),
              ),
              const SizedBox(height: 24),

              _label('Card information'),
              const SizedBox(height: 8),
              _cardInfoBox(state),

              const SizedBox(height: 18),
              _label('Cardholder name'),
              const SizedBox(height: 8),
              _standaloneField(
                controller: _nameController,
                hint: 'Full name on card',
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
              ),

              const SizedBox(height: 18),
              _label('Country or region'),
              const SizedBox(height: 8),
              _countryZipBox(),

              if (state.errorMessage != null) ...[
                const SizedBox(height: 14),
                _errorBanner(state.errorMessage!),
              ],

              const SizedBox(height: 24),
              PrimaryButton(
                text: 'Pay  ${_formatAmount(widget.amount)}',
                backgroundColor: _navy,
                isLoading: state.status == PaymentStatus.processing,
                onTap: _onPay,
              ),
              const SizedBox(height: 16),
              _footer(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Card information (number + expiry + CVC) ──────────────────────────────
  Widget _cardInfoBox(PaymentState state) {
    return Container(
      decoration: _boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card number + brand strip
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _numberController,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    inputFormatters: [CardNumberInputFormatter()],
                    onChanged: (value) => ref
                        .read(paymentViewModelProvider.notifier)
                        .detectBrand(value),
                    style: _valueStyle,
                    decoration: _innerDecoration('1234 1234 1234 1234'),
                  ),
                ),
                const SizedBox(width: 8),
                CardBrandStrip(activeBrand: state.brand),
              ],
            ),
          ),
          _hDivider(),
          // Expiry | CVC
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: TextField(
                      controller: _expiryController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [ExpiryInputFormatter()],
                      style: _valueStyle,
                      decoration: _innerDecoration('MM / YY'),
                    ),
                  ),
                ),
                Container(width: 1, color: _borderColor),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _cvcController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(4),
                            ],
                            style: _valueStyle,
                            decoration: _innerDecoration('CVC'),
                          ),
                        ),
                        _cvcHintBadge(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Country selector + ZIP ────────────────────────────────────────────────
  Widget _countryZipBox() {
    return Container(
      decoration: _boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: _showCountryPicker,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              child: Row(
                children: [
                  Expanded(child: Text(_country, style: _valueStyle)),
                  const Icon(Icons.keyboard_arrow_down,
                      color: Color(0xFF6B7280)),
                ],
              ),
            ),
          ),
          _hDivider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: TextField(
              controller: _zipController,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.done,
              style: _valueStyle,
              decoration: _innerDecoration('ZIP'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _standaloneField({
    required TextEditingController controller,
    required String hint,
    TextCapitalization textCapitalization = TextCapitalization.none,
    TextInputAction textInputAction = TextInputAction.next,
  }) {
    return Container(
      decoration: _boxDecoration(),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: TextField(
        controller: controller,
        textCapitalization: textCapitalization,
        textInputAction: textInputAction,
        style: _valueStyle,
        decoration: _innerDecoration(hint),
      ),
    );
  }

  Widget _errorBanner(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F0),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFFD2CE)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 18, color: AppColors.redColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Color(0xFFB42318), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _footer() {
    return Center(
      child: Text.rich(
        TextSpan(
          text: 'By clicking Pay, you agree to the ',
          style: const TextStyle(fontSize: 12.5, color: _hintColor),
          children: [
            TextSpan(
              text: 'Bostra Terms',
              style: TextStyle(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const TextSpan(text: ' and '),
            TextSpan(
              text: 'Privacy Policy',
              style: TextStyle(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const TextSpan(text: '.'),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // ── Behaviour ─────────────────────────────────────────────────────────────
  Future<void> _onPay() async {
    FocusScope.of(context).unfocus();

    final rawNumber = _numberController.text.replaceAll(RegExp(r'\D'), '');
    final expiryParts = _expiryController.text.split('/');
    final month = expiryParts.isNotEmpty ? expiryParts.first.trim() : '';
    final year = expiryParts.length > 1 ? expiryParts[1].trim() : '';

    final card = PaymentCard(
      number: rawNumber,
      expiryMonth: month,
      expiryYear: year,
      cvc: _cvcController.text.trim(),
      holderName: _nameController.text.trim(),
      country: _country,
      zip: _zipController.text.trim(),
    );

    final succeeded = await ref
        .read(paymentViewModelProvider.notifier)
        .pay(card: card, amount: widget.amount);

    if (!mounted) return;
    if (succeeded) {
      Navigator.of(context).pop(ref.read(paymentViewModelProvider).result);
    }
  }

  void _showCountryPicker() {
    FocusScope.of(context).unfocus();
    showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Country or region',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final country in _countries)
                      ListTile(
                        title: Text(country),
                        trailing: country == _country
                            ? Icon(Icons.check, color: AppColors.primaryColor)
                            : null,
                        onTap: () => Navigator.of(context).pop(country),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ).then((selected) {
      if (selected != null && mounted) {
        setState(() => _country = selected);
      }
    });
  }

  // ── Small building blocks ─────────────────────────────────────────────────
  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: _labelColor,
        ),
      );

  Widget _hDivider() => Container(height: 1, color: _borderColor);

  BoxDecoration _boxDecoration() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _borderColor, width: 1.2),
      );

  InputDecoration _innerDecoration(String hint) => InputDecoration(
        isDense: true,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 16, color: _hintColor),
      );

  static const _valueStyle = TextStyle(
    fontSize: 16,
    color: _valueColor,
    fontWeight: FontWeight.w500,
  );

  /// Tiny "card back" icon hinting where the CVC lives.
  Widget _cvcHintBadge() {
    return Container(
      width: 30,
      height: 19,
      decoration: BoxDecoration(
        color: const Color(0xFFE9ECEF),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 4,
            left: 0,
            right: 0,
            child: Container(height: 3, color: const Color(0xFFCBD2D9)),
          ),
          Positioned(
            right: 2,
            bottom: 2,
            child: Container(
              width: 12,
              height: 12,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFF2B2F36),
                shape: BoxShape.circle,
              ),
              child: const Text(
                '123',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double value) {
    final fixed =
        value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(2);
    final parts = fixed.split('.');
    final intPart = parts[0];
    final buffer = StringBuffer();
    for (var i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buffer.write(',');
      buffer.write(intPart[i]);
    }
    final grouped = buffer.toString();
    return '₹${parts.length > 1 ? '$grouped.${parts[1]}' : grouped}';
  }
}
