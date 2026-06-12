import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:bostra/ui/start_campain/widgets/projection_textfield.dart';
import 'package:flutter/material.dart';

class MonthProjectionCard extends StatefulWidget {
  final int monthNumber;
  final String monthLabel;
  final String initialObjectives;
  final String initialGoals;
  final String initialInitiative;
  final ValueChanged<String>? onObjectivesChanged;
  final ValueChanged<String>? onGoalsChanged;
  final ValueChanged<String>? onInitiativeChanged;

  const MonthProjectionCard({
    super.key,
    required this.monthNumber,
    required this.monthLabel,
    this.initialObjectives = '',
    this.initialGoals = '',
    this.initialInitiative = '',
    this.onObjectivesChanged,
    this.onGoalsChanged,
    this.onInitiativeChanged,
  });

  @override
  State<MonthProjectionCard> createState() => _MonthProjectionCardState();
}

class _MonthProjectionCardState extends State<MonthProjectionCard> {
  late final TextEditingController _objectivesController;
  late final TextEditingController _goalsController;
  late final TextEditingController _initiativeController;

  @override
  void initState() {
    super.initState();
    _objectivesController = TextEditingController(text: widget.initialObjectives);
    _goalsController = TextEditingController(text: widget.initialGoals);
    _initiativeController = TextEditingController(text: widget.initialInitiative);
  }

  @override
  void didUpdateWidget(covariant MonthProjectionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialObjectives != _objectivesController.text) {
      _objectivesController.text = widget.initialObjectives;
    }
    if (widget.initialGoals != _goalsController.text) {
      _goalsController.text = widget.initialGoals;
    }
    if (widget.initialInitiative != _initiativeController.text) {
      _initiativeController.text = widget.initialInitiative;
    }
  }

  @override
  void dispose() {
    _objectivesController.dispose();
    _goalsController.dispose();
    _initiativeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month header bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Month ${widget.monthNumber}',
                style: AppTextStyle.h4.copyWith(
                  color: AppColors.whiteColor,
                ),
              ),
              Text(
                widget.monthLabel,
                style: AppTextStyle.bodyText2.copyWith(
                  color: AppColors.whiteColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Text fields card
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.primaryColor.withAlpha(80),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              ProjectionTextfield(
                hintText: 'Objectives',
                controller: _objectivesController,
                onChanged: widget.onObjectivesChanged,
              ),
              const SizedBox(height: 12),
              ProjectionTextfield(
                hintText: 'Goals',
                controller: _goalsController,
                onChanged: widget.onGoalsChanged,
              ),
              const SizedBox(height: 12),
              ProjectionTextfield(
                hintText: 'Initiative',
                controller: _initiativeController,
                onChanged: widget.onInitiativeChanged,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
