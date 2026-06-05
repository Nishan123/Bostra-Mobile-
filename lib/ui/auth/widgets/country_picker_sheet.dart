import 'package:bostra/constants/country_picker_constants.dart';
import 'package:bostra/models/country.dart';
import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:flutter/material.dart';

class CountryPickerSheet {
  static void showAvailableCountry({
    required BuildContext context,
    required void Function(Country country) onCountrySelected,
    required Country pickedCountry,
  }) {
    showModalBottomSheet(
      showDragHandle: true,
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          height: 380,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Pick your Country",style: AppTextStyle.h2,),
              ListView.builder(
                shrinkWrap: true,
                itemCount: CountryPickerConstants.availableCountries.length,
                itemBuilder: (context, index) {
                  final data = CountryPickerConstants.availableCountries[index];
                  return ListTile(
                    onTap: () => onCountrySelected(data),
                    title: Text(data.phoneCode),
                    subtitle: Text(data.countryCode),
                    trailing: data == pickedCountry
                        ? Container(
                            height: 10,
                            width: 10,
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              shape: BoxShape.circle,
                            ),
                          )
                        : SizedBox(),
                    leading: SizedBox(
                      height: 30,
                      width: 30,
                      child: Image.network(data.prefixImage),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
