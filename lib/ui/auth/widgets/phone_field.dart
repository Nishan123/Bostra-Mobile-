import 'package:bostra/models/country.dart';
import 'package:bostra/theme/app_colors.dart';
import 'package:flutter/material.dart';

class PhoneField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback pickerTab;
  final Country pickedCountry;
  const PhoneField({
    super.key,
    required this.controller,
    required this.pickerTab,
    required this.pickedCountry,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: pickerTab,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.primaryColor,
            ),
            child: Center(
              child: Row(
                children: [
                  Text(
                    pickedCountry.phoneCode,
                    style: TextStyle(color: AppColors.whiteColor),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 6),
        Expanded(
          child: TextField(
            keyboardType: TextInputType.number,
            controller: controller,
            decoration: InputDecoration(
              hintText: "Phone Number",
              border: OutlineInputBorder(
                borderSide: BorderSide(width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
