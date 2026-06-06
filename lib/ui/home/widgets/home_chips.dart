import 'package:bostra/theme/app_colors.dart';
import 'package:flutter/material.dart';

class HomeChips<T> extends StatefulWidget {
  final List<T> values;
  final String Function(T) labelBuilder;
  final IconData? Function(T)? iconBuilder;
  final void Function(T)? onSelected;
  final EdgeInsetsGeometry padding;
  final T? selectedValue;
  final bool isWrap;

  const HomeChips({
    super.key,
    required this.values,
    required this.labelBuilder,
    required this.iconBuilder,
    this.onSelected,
    this.padding = const EdgeInsets.only(right: 16),
    this.selectedValue,
    this.isWrap = false,
  });

  @override
  State<HomeChips<T>> createState() => _HomeChipsState<T>();
}

class _HomeChipsState<T> extends State<HomeChips<T>> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _initializeSelectedIndex();
  }

  @override
  void didUpdateWidget(HomeChips<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedValue != oldWidget.selectedValue) {
      _initializeSelectedIndex();
    }
  }

  void _initializeSelectedIndex() {
    if (widget.selectedValue != null) {
      final index = widget.values.indexOf(widget.selectedValue as T);
      _selectedIndex = index >= 0 ? index : 0;
    } else {
      _selectedIndex = 0;
    }
  }

  void _handleSelection(bool selected, int index, T item) {
    if (selected) {
      setState(() => _selectedIndex = index);
      widget.onSelected?.call(item);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chips = widget.values.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;

      final chip = _AnimatedChip<T>(
        isWrap: widget.isWrap,
        key: ValueKey(index),
        index: index,
        item: item,
        label: widget.labelBuilder(item),
        icon: widget.iconBuilder?.call(item),
        isSelected: _selectedIndex == index,
        onSelected: (selected) => _handleSelection(selected, index, item),
      );

      if (widget.isWrap) return chip as Widget;

      return Padding(
            padding: index == 0
                ? const EdgeInsets.only(left: 18, right: 10)
                : const EdgeInsets.only(right: 10),
            child: chip,
          )
          as Widget;
    }).toList();

    if (widget.isWrap) {
      return Padding(
        padding: widget.padding,
        child: Wrap(spacing: 12, runSpacing: 2, children: chips),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: widget.padding,
        child: Row(children: chips),
      ),
    );
  }
}

// ── Animated individual chip ──────────────────────────────────────────────────

class _AnimatedChip<T> extends StatefulWidget {
  final int index;
  final T item;
  final String label;
  final IconData? icon;
  final bool isSelected;
  final void Function(bool) onSelected;
  final bool isWrap;

  const _AnimatedChip({
    super.key,
    required this.index,
    required this.item,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onSelected,
    required this.isWrap,
  });

  @override
  State<_AnimatedChip<T>> createState() => _AnimatedChipState<T>();
}

class _AnimatedChipState<T> extends State<_AnimatedChip<T>>
    with TickerProviderStateMixin {
  late final AnimationController _colorController;
  late final AnimationController _popController;

  late final Animation<double> _colorT;
  late final Animation<double> _popScale;

  late bool _wasSelected;

  @override
  void initState() {
    super.initState();
    _wasSelected = widget.isSelected;

    // Separate controller for color — animates both forward and backward smoothly
    _colorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: widget.isSelected ? 1.0 : 0.0, // jump to correct state, no flash
    );

    // Separate controller for pop — only ever plays forward on select
    _popController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _colorT = CurvedAnimation(
      parent: _colorController,
      curve: Curves.easeInOutCubic,
    );

    _popScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.94, // Premium Apple feel: Press inwards
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.94,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOutBack)), // Snappy spring release
        weight: 60,
      ),
    ]).animate(_popController);
  }

  @override
  void didUpdateWidget(_AnimatedChip<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isSelected == _wasSelected) return;
    _wasSelected = widget.isSelected;

    if (widget.isSelected) {
      // Selecting: animate color fill + trigger pop
      _colorController.animateTo(1.0);
      _popController.forward(from: 0.0);
    } else {
      // Deselecting: animate color drain only — pop controller untouched (stays at 1.0/idle)
      _colorController.animateTo(0.0);
    }
  }

  @override
  void dispose() {
    _colorController.dispose();
    _popController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_colorController, _popController]),
      builder: (context, _) {
        final t = _colorT.value;
        final bgColor = Color.lerp(
          AppColors.turnaryColor,
          AppColors.primaryColor,
          t,
        )!;
        final contentColor = Color.lerp(
          AppColors.blackColor,
          AppColors.whiteColor,
          t,
        )!;

        return Transform.scale(
          scale: _popScale.value,
          child: GestureDetector(
            onTap: () => widget.onSelected(!widget.isSelected),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              margin: widget.isWrap
                  ? EdgeInsets.only(bottom: 8)
                  : EdgeInsets.all(0),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                spacing: widget.icon == null ? 0 : 8,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null)
                    Icon(widget.icon, size: 20, color: contentColor),
                  if (widget.icon == null) const SizedBox(),
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 15,
                      color: contentColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
