import 'package:bostra/enums/chips_options.dart';
import 'package:bostra/models/campaign_filter.dart';
import 'package:bostra/models/campaign_model.dart';
import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:bostra/ui/home/widgets/home_chips.dart';
import 'package:bostra/widgets/primary_button.dart';
import 'package:flutter/material.dart';

/// Opens the campaign filter bottom sheet and resolves to the chosen
/// [CampaignFilter], or `null` if the sheet is dismissed without applying.
///
/// [source] is used only to derive the amount slider's upper bound so the range
/// reflects the campaigns actually being filtered.
Future<CampaignFilter?> showCampaignFilterSheet(
  BuildContext context, {
  required CampaignFilter current,
  required List<CampaignModel> source,
}) {
  return showModalBottomSheet<CampaignFilter>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.whiteColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => CampaignFilterSheet(current: current, source: source),
  );
}

/// South-Asian (lakh) digit grouping: 100000 → "1,00,000".
String _groupRs(double v) {
  final s = v.toStringAsFixed(0);
  if (s.length <= 3) return s;
  final last3 = s.substring(s.length - 3);
  String rest = s.substring(0, s.length - 3);
  final parts = <String>[];
  while (rest.length > 2) {
    parts.insert(0, rest.substring(rest.length - 2));
    rest = rest.substring(0, rest.length - 2);
  }
  if (rest.isNotEmpty) parts.insert(0, rest);
  return '${parts.join(',')},$last3';
}

class CampaignFilterSheet extends StatefulWidget {
  final CampaignFilter current;
  final List<CampaignModel> source;

  const CampaignFilterSheet({
    super.key,
    required this.current,
    required this.source,
  });

  @override
  State<CampaignFilterSheet> createState() => _CampaignFilterSheetState();
}

class _CampaignFilterSheetState extends State<CampaignFilterSheet> {
  static const double _step = 100000; // Rs 1 lakh slider granularity.
  static const double _fallbackMax = 1000000;

  late final double _minBound;
  late final double _maxBound;

  late ChipsOptions _industry;
  late RangeValues _range;

  @override
  void initState() {
    super.initState();
    _minBound = 0;
    _maxBound = _computeMaxBound(widget.source);

    _industry = widget.current.industry;

    final lo = (widget.current.minAmount ?? _minBound)
        .clamp(_minBound, _maxBound)
        .toDouble();
    final hiRaw = (widget.current.maxAmount ?? _maxBound)
        .clamp(_minBound, _maxBound)
        .toDouble();
    final hi = hiRaw < lo ? _maxBound : hiRaw;
    _range = RangeValues(lo, hi);
  }

  double _computeMaxBound(List<CampaignModel> source) {
    final amounts =
        source.map((c) => c.targetAmount).where((v) => v > 0).toList();
    if (amounts.isEmpty) return _fallbackMax;
    final raw = amounts.reduce((a, b) => a > b ? a : b);
    final rounded = (raw / _step).ceil() * _step;
    return rounded <= 0 ? _fallbackMax : rounded.toDouble();
  }

  int get _divisions {
    final steps = ((_maxBound - _minBound) / _step).round();
    return steps.clamp(4, 40);
  }

  void _reset() {
    setState(() {
      _industry = ChipsOptions.all;
      _range = RangeValues(_minBound, _maxBound);
    });
  }

  void _apply() {
    final min = _range.start <= _minBound ? null : _range.start;
    final max = _range.end >= _maxBound ? null : _range.end;
    Navigator.of(context).pop(
      CampaignFilter(industry: _industry, minAmount: min, maxAmount: max),
    );
  }

  @override
  Widget build(BuildContext context) {
    final endLabel =
        '${_groupRs(_range.end)}${_range.end >= _maxBound ? '+' : ''}';

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Grabber ────────────────────────────────────────────────────
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
            const SizedBox(height: 18),

            // ── Header ─────────────────────────────────────────────────────
            Row(
              children: [
                Text('Filters', style: AppTextStyle.h2),
                const Spacer(),
                GestureDetector(
                  onTap: _reset,
                  child: Text(
                    'Reset',
                    style: AppTextStyle.bodyText1.copyWith(
                      color: AppColors.textButtonColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Industry ───────────────────────────────────────────────────
            Text('Industry', style: AppTextStyle.h4),
            const SizedBox(height: 12),
            HomeChips<ChipsOptions>(
              values: ChipsOptions.values,
              labelBuilder: (o) => o.text,
              iconBuilder: null,
              isWrap: true,
              padding: EdgeInsets.zero,
              selectedValue: _industry,
              onSelected: (o) => setState(() => _industry = o),
            ),
            const SizedBox(height: 22),

            // ── Amount requested ───────────────────────────────────────────
            Row(
              children: [
                Text('Amount requested', style: AppTextStyle.h4),
                const Spacer(),
                Text(
                  'Rs ${_groupRs(_range.start)} – Rs $endLabel',
                  style: AppTextStyle.bodyText2.copyWith(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            RangeSlider(
              values: _range,
              min: _minBound,
              max: _maxBound,
              divisions: _divisions,
              activeColor: AppColors.primaryColor,
              inactiveColor: AppColors.primaryColor.withAlpha(45),
              labels: RangeLabels(
                'Rs ${_groupRs(_range.start)}',
                'Rs $endLabel',
              ),
              onChanged: (values) => setState(() => _range = values),
            ),
            const SizedBox(height: 20),

            // ── Apply ──────────────────────────────────────────────────────
            PrimaryButton(text: 'Apply Filters', onTap: _apply),
          ],
        ),
      ),
    );
  }
}
