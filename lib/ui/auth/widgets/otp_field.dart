import 'package:bostra/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class OtpField extends StatelessWidget {
  final TextEditingController controller;
  const OtpField({super.key, required this.controller});

  BorderRadius _pinRadiusForIndex({required int index, required int length}) {
    const largeRadius = 12.0;
    const smallRadius = 6.0;
    const middleRadius = 6.0;

    if (index == 0) {
      return const BorderRadius.only(
        topLeft: Radius.circular(largeRadius),
        bottomLeft: Radius.circular(largeRadius),
        topRight: Radius.circular(smallRadius),
        bottomRight: Radius.circular(smallRadius),
      );
    }

    if (index == length - 1) {
      return const BorderRadius.only(
        topLeft: Radius.circular(smallRadius),
        bottomLeft: Radius.circular(smallRadius),
        topRight: Radius.circular(largeRadius),
        bottomRight: Radius.circular(largeRadius),
      );
    }

    return BorderRadius.circular(middleRadius);
  }

  @override
  Widget build(BuildContext context) {
    const otpLength = 6;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final pinWidth = ((screenWidth - 64) / otpLength)
        .clamp(46.0, 86.0)
        .toDouble();
    final pinHeight = (pinWidth * 1).clamp(56.0, 98.0).toDouble();

    return Pinput.builder(
      builder: (context, pinState) {
        final isFocused = pinState.type == PinItemStateType.focused;
        final borderColor = isFocused
            ? AppColors.primaryColor
            : const Color(0xFF9AC8BE);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          alignment: Alignment.center,
          width: pinWidth,
          height: pinHeight,
          decoration: BoxDecoration(
            color: const Color(0xFFF2F3F5),
            borderRadius: _pinRadiusForIndex(
              index: pinState.index,
              length: otpLength,
            ),
            border: Border.all(color: borderColor, width: isFocused ? 1.6 : 1),
          ),
          child: Center(
            child: Text(
              pinState.value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryColor,
              ),
            ),
          ),
        );
      },
      controller: controller,
      length: otpLength,
      separatorBuilder: (index) => const SizedBox(width: 8),
      keyboardType: TextInputType.number,
    );
  }
}
