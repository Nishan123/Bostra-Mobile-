import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

/// Shared Hero tag so the search bar visually flies between the home,
/// search and results screens during navigation.
const String kSearchBarHeroTag = 'bostra_search_bar_hero';

/// Rounded, green-bordered search field with a search icon and a filter
/// button — reused across Home, Search and Search-results screens.
///
/// * On Home / Results it is [readOnly] with an [onTap] (acts as a button).
/// * On the Search screen it is editable with [autofocus] + [onSubmitted].
///
/// When [showHero] is true the whole bar is wrapped in a [Hero] using
/// [kSearchBarHeroTag], giving the "field animates and moves to the top"
/// transition. A static flight shuttle is used so no live [TextField] is
/// lifted into the overlay mid-flight.
class AppSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final bool autofocus;
  final bool readOnly;
  final VoidCallback? onTap;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;
  final String hintText;
  final bool showHero;

  /// Shows a small badge on the filter button when a filter is applied.
  final bool filterActive;

  const AppSearchBar({
    super.key,
    this.controller,
    this.autofocus = false,
    this.readOnly = false,
    this.onTap,
    this.onSubmitted,
    this.onChanged,
    this.onFilterTap,
    this.hintText = 'Search “Organic Cafe”',
    this.showHero = true,
    this.filterActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final field = _decoration(
      child: Row(
        children: [
          Icon(LucideIcons.search, color: AppColors.primaryColor, size: 26.0),
          const SizedBox(width: 12.0),
          Expanded(
            child: TextField(
              controller: controller,
              autofocus: autofocus,
              readOnly: readOnly,
              onTap: onTap,
              onSubmitted: onSubmitted,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              cursorColor: AppColors.primaryColor,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: AppTextStyle.bodyText2.copyWith(
                  color: AppColors.blackColor.withAlpha(100),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: AppTextStyle.bodyText1.copyWith(
                color: AppColors.blackColor,
              ),
            ),
          ),
          _FilterButton(onTap: onFilterTap, active: filterActive),
        ],
      ),
    );

    if (!showHero) return field;

    return Hero(
      tag: kSearchBarHeroTag,
      flightShuttleBuilder: (_, __, ___, ____, _____) => _FlightShuttle(
        text: controller?.text ?? '',
        hintText: hintText,
        onFilterTap: onFilterTap,
        filterActive: filterActive,
      ),
      child: field,
    );
  }
}

/// Shared container chrome for the bar (border, radius, height, padding).
Widget _decoration({required Widget child}) {
  return Container(
    height: 52,
    padding: const EdgeInsets.only(left: 12.0, right: 8.0),
    decoration: BoxDecoration(
      color: AppColors.whiteColor,
      borderRadius: BorderRadius.circular(12.0),
      border: Border.all(color: AppColors.primaryColor, width: 1.2),
    ),
    child: child,
  );
}

class _FilterButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool active;
  const _FilterButton({this.onTap, this.active = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Icon(
              LucideIcons.sliders_horizontal,
              color: AppColors.whiteColor,
              size: 18.0,
            ),
          ),
          if (active)
            Positioned(
              top: -3,
              right: -3,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.redColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.whiteColor, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Non-interactive replica shown while the Hero is in flight. Uses a plain
/// [Text] instead of a [TextField] so no focus node / material is required in
/// the overlay.
class _FlightShuttle extends StatelessWidget {
  final String text;
  final String hintText;
  final VoidCallback? onFilterTap;
  final bool filterActive;
  const _FlightShuttle({
    required this.text,
    required this.hintText,
    this.onFilterTap,
    this.filterActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final isEmpty = text.isEmpty;
    return Material(
      type: MaterialType.transparency,
      child: _decoration(
        child: Row(
          children: [
            Icon(LucideIcons.search, color: AppColors.primaryColor, size: 26.0),
            const SizedBox(width: 12.0),
            Expanded(
              child: Text(
                isEmpty ? hintText : text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: isEmpty
                    ? AppTextStyle.bodyText2.copyWith(
                        color: AppColors.blackColor.withAlpha(100),
                      )
                    : AppTextStyle.bodyText1.copyWith(
                        color: AppColors.blackColor,
                      ),
              ),
            ),
            _FilterButton(onTap: onFilterTap, active: filterActive),
          ],
        ),
      ),
    );
  }
}
