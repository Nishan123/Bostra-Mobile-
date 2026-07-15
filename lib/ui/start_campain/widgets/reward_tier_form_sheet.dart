import 'dart:io';

import 'package:bostra/enums/reward_type.dart';
import 'package:bostra/models/reward_tier_model.dart';
import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:bostra/widgets/primary_button.dart';
import 'package:bostra/widgets/reward_tier_card.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Opens the add/edit reward-tier form. Resolves to the configured
/// [RewardTierModel], or null if cancelled.
Future<RewardTierModel?> showRewardTierForm(
  BuildContext context, {
  RewardTierModel? existing,
  required double goal,
}) {
  return showModalBottomSheet<RewardTierModel>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.whiteColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _RewardTierForm(existing: existing, goal: goal),
  );
}

class _RewardTierForm extends StatefulWidget {
  final RewardTierModel? existing;
  final double goal;
  const _RewardTierForm({this.existing, required this.goal});

  @override
  State<_RewardTierForm> createState() => _RewardTierFormState();
}

class _RewardTierFormState extends State<_RewardTierForm> {
  final _picker = ImagePicker();

  late final TextEditingController _title;
  late final TextEditingController _desc;
  late final TextEditingController _customType;
  late final TextEditingController _amount;
  late final TextEditingController _quantity;

  RewardType _type = RewardType.earlyAccess;
  bool _isPercent = true;
  DateTime? _delivery;
  bool _repeatable = false;
  String? _imagePath;
  String? _error;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _title = TextEditingController(text: e?.title ?? '');
    _desc = TextEditingController(text: e?.description ?? '');
    _customType = TextEditingController(text: e?.customTypeLabel ?? '');
    _quantity = TextEditingController(
      text: e?.quantityLimit != null ? '${e!.quantityLimit}' : '',
    );
    _type = e?.rewardType ?? RewardType.earlyAccess;
    _repeatable = e?.isRepeatable ?? false;
    _delivery = e?.deliveryEstimate;
    _imagePath = e?.imageUrl;

    if (e != null && e.minAmount != null) {
      _isPercent = false;
      _amount = TextEditingController(text: _trim(e.minAmount!));
    } else if (e != null && e.minPercent != null) {
      _isPercent = true;
      _amount = TextEditingController(text: _trim(e.minPercent!));
    } else {
      _amount = TextEditingController();
    }
  }

  String _trim(double v) {
    var s = v.toStringAsFixed(2);
    if (s.contains('.')) {
      s = s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    }
    return s;
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _customType.dispose();
    _amount.dispose();
    _quantity.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) setState(() => _imagePath = picked.path);
  }

  Future<void> _pickDelivery() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _delivery ?? now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 5)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.primaryColor,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _delivery = picked);
  }

  void _save() {
    final title = _title.text.trim();
    if (title.isEmpty) {
      setState(() => _error = 'Please enter a reward title.');
      return;
    }
    final value = double.tryParse(_amount.text.trim());
    if (value == null || value <= 0) {
      setState(() => _error = 'Enter a valid minimum investment.');
      return;
    }
    if (_isPercent && value > 100) {
      setState(() => _error = 'Percentage cannot exceed 100%.');
      return;
    }
    final quantity = int.tryParse(_quantity.text.trim());

    final tier = (widget.existing ?? const RewardTierModel()).copyWith(
      title: title,
      description: _desc.text.trim(),
      rewardType: _type,
      customTypeLabel:
          _type == RewardType.custom ? _customType.text.trim() : null,
      minPercent: _isPercent ? value : null,
      minAmount: _isPercent ? null : value,
      clearMinPercent: !_isPercent,
      clearMinAmount: _isPercent,
      deliveryEstimate: _delivery,
      clearDelivery: _delivery == null,
      quantityLimit: quantity,
      clearQuantity: quantity == null,
      imageUrl: _imagePath,
      clearImage: _imagePath == null,
      isRepeatable: _repeatable,
    );
    Navigator.of(context).pop(tier);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.blackColor.withAlpha(40),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.existing == null ? 'New Reward Tier' : 'Edit Reward Tier',
                  style: AppTextStyle.h2,
                ),
                const SizedBox(height: 18),

                _label('Reward title'),
                _textField(_title, 'e.g. Early Access + Founder Updates'),
                const SizedBox(height: 16),

                _label('Reward type'),
                _typeDropdown(),
                if (_type == RewardType.custom) ...[
                  const SizedBox(height: 10),
                  _textField(_customType, 'Name your custom reward'),
                ],
                const SizedBox(height: 16),

                _label('Description'),
                _textField(
                  _desc,
                  'What exactly does the investor get?',
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                _label('Minimum investment'),
                _thresholdField(),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Delivery estimate (optional)'),
                          _pickerBox(
                            _delivery != null
                                ? _fmtDate(_delivery!)
                                : 'Select date',
                            Icons.event_outlined,
                            _pickDelivery,
                            filled: _delivery != null,
                            onClear: _delivery != null
                                ? () => setState(() => _delivery = null)
                                : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 110,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Qty limit'),
                          _plainField(_quantity, '∞', number: true),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _label('Reward image (optional)'),
                _imagePicker(),
                const SizedBox(height: 12),

                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppColors.primaryColor,
                  value: _repeatable,
                  onChanged: (v) => setState(() => _repeatable = v),
                  title: Text('Repeatable reward', style: AppTextStyle.bodyText1),
                  subtitle: Text(
                    'Investor can earn this more than once',
                    style: AppTextStyle.bodyText3,
                  ),
                ),

                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _error!,
                    style: AppTextStyle.bodyText2.copyWith(color: AppColors.redColor),
                  ),
                ],
                const SizedBox(height: 16),
                PrimaryButton(
                  text: widget.existing == null ? 'Add Reward' : 'Save Changes',
                  onTap: _save,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Field builders ──────────────────────────────────────────────────────────

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: AppTextStyle.bodyText2.copyWith(
            color: AppColors.blackColor.withAlpha(180),
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  InputDecoration _decoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyle.normalText
            .copyWith(color: AppColors.blackColor.withAlpha(100)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.blackColor.withAlpha(50)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5),
        ),
      );

  Widget _textField(TextEditingController c, String hint, {int maxLines = 1}) {
    return TextField(
      controller: c,
      maxLines: maxLines,
      style: AppTextStyle.normalText.copyWith(color: AppColors.blackColor),
      decoration: _decoration(hint),
    );
  }

  Widget _plainField(TextEditingController c, String hint,
      {bool number = false}) {
    return TextField(
      controller: c,
      keyboardType: number ? TextInputType.number : TextInputType.text,
      style: AppTextStyle.normalText.copyWith(color: AppColors.blackColor),
      decoration: _decoration(hint),
    );
  }

  Widget _typeDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.blackColor.withAlpha(50)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<RewardType>(
          value: _type,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded,
              color: AppColors.blackColor.withAlpha(150)),
          items: RewardType.values
              .map(
                (t) => DropdownMenuItem<RewardType>(
                  value: t,
                  child: Row(
                    children: [
                      Icon(t.icon, size: 18, color: AppColors.primaryColor),
                      const SizedBox(width: 10),
                      Text(t.label, style: AppTextStyle.normalText),
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: (t) => setState(() => _type = t ?? _type),
        ),
      ),
    );
  }

  Widget _thresholdField() {
    final goal = widget.goal;
    String helper = '';
    final v = double.tryParse(_amount.text.trim());
    if (_isPercent && v != null && goal > 0) {
      helper = '≈ Rs ${formatRs(v / 100 * goal)} of the Rs ${formatRs(goal)} goal';
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Basis toggle
            _basisToggle(),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _amount,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => setState(() {}),
                style: AppTextStyle.normalText
                    .copyWith(color: AppColors.blackColor),
                decoration: _decoration(_isPercent ? 'e.g. 2' : 'e.g. 5000')
                    .copyWith(
                  suffixText: _isPercent ? '%' : 'Rs',
                ),
              ),
            ),
          ],
        ),
        if (helper.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(helper, style: AppTextStyle.bodyText3),
        ],
      ],
    );
  }

  Widget _basisToggle() {
    Widget seg(String label, bool percent) {
      final selected = _isPercent == percent;
      return GestureDetector(
        onTap: () => setState(() => _isPercent = percent),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: AppTextStyle.bodyText2.copyWith(
              color: selected ? AppColors.whiteColor : AppColors.blackColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.blackColor.withAlpha(12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(children: [seg('%', true), seg('Rs', false)]),
    );
  }

  Widget _pickerBox(
    String text,
    IconData icon,
    VoidCallback onTap, {
    bool filled = false,
    VoidCallback? onClear,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.blackColor.withAlpha(50)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primaryColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: AppTextStyle.normalText.copyWith(
                  color: filled
                      ? AppColors.blackColor
                      : AppColors.blackColor.withAlpha(100),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (onClear != null)
              GestureDetector(
                onTap: onClear,
                child: Icon(Icons.close,
                    size: 16, color: AppColors.blackColor.withAlpha(120)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _imagePicker() {
    final hasImage = _imagePath != null && _imagePath!.isNotEmpty;
    final isRemote = hasImage &&
        (_imagePath!.startsWith('http://') || _imagePath!.startsWith('https://'));
    return Row(
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.turnaryColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.blackColor.withAlpha(40)),
            ),
            clipBehavior: Clip.hardEdge,
            child: hasImage
                ? (isRemote
                    ? Image.network(_imagePath!, fit: BoxFit.cover)
                    : Image.file(File(_imagePath!), fit: BoxFit.cover))
                : Icon(Icons.add_photo_alternate_outlined,
                    color: AppColors.blackColor.withAlpha(120)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            hasImage ? 'Tap to change image' : 'Add an image (optional)',
            style: AppTextStyle.bodyText3,
          ),
        ),
        if (hasImage)
          GestureDetector(
            onTap: () => setState(() => _imagePath = null),
            child: Text('Remove',
                style: AppTextStyle.bodyText3
                    .copyWith(color: AppColors.redColor)),
          ),
      ],
    );
  }

  static String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
