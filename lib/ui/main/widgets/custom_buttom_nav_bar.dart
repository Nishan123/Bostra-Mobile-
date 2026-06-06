import 'package:bostra/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class CustomButtomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomButtomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<CustomButtomNavBar> createState() => _CustomButtomNavBarState();
}

class _CustomButtomNavBarState extends State<CustomButtomNavBar> {
  static const List<IconData> _icons = [
    LucideIcons.house,
    LucideIcons.heart,
    LucideIcons.building_2,
    LucideIcons.chart_no_axes_combined,
    LucideIcons.circle_user_round,
  ];

  static const int _itemCount = 5;
  static const double _navHeight = 70;
  static const double _pillHeight = 42;
  static const double _iconSize = 24;
  static const Duration _animationDuration = Duration(milliseconds: 500);
  static const Curve _animationCurve = Curves.easeInOut;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(width: 0.6, color: AppColors.primaryColor.withAlpha(100)),
        ),
        color: AppColors.whiteColor,
      ),
      height: _navHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double totalWidth = constraints.maxWidth - 20;
          final double itemWidth = totalWidth / _itemCount;

          // Pill is slightly wider than the icon to match the design
          const double pillWidth = 60;

          // Center the pill within the item slot
          final double pillLeft =
              (itemWidth * widget.currentIndex) +
              (itemWidth / 2) -
              (pillWidth / 2);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Sliding pill background
                AnimatedPositioned(
                  duration: _animationDuration,
                  curve: _animationCurve,
                  left: pillLeft,
                  top: (_navHeight - _pillHeight) / 2,
                  child: Container(
                    width: pillWidth,
                    height: _pillHeight,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withAlpha(180),
                      borderRadius: BorderRadius.circular(120),
                    ),
                  ),
                ),

                // Icons row
                Row(
                  children: List.generate(_itemCount, (index) {
                    final bool isSelected = widget.currentIndex == index;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => widget.onTap(index),
                        behavior: HitTestBehavior.opaque,
                        child: SizedBox(
                          height: _navHeight,
                          child: Center(
                            child: Icon(
                              _icons[index],
                              size: _iconSize,
                              color: isSelected
                                  ? AppColors.whiteColor
                                  : const Color.fromARGB(255, 169, 155, 149),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
