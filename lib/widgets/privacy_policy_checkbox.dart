import 'package:bostra/theme/app_text_style.dart';
import 'package:flutter/material.dart';

class PrivacyPolicyCheckbox extends StatelessWidget {
  final bool value;
  final Function(bool? value) onChanged;
  const PrivacyPolicyCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      spacing: 4,
      children: [
        Checkbox(splashRadius: 0, value: value, onChanged: onChanged),
        Text("Agree to all"),
        Text("Privacy policy",style: AppTextStyle.buttonTextStyle,),
        Text("&"),
        Text("Legal Information",style: AppTextStyle.buttonTextStyle,),
      ],
    );
  }
}
