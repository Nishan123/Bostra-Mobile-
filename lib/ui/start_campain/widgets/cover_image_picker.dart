import 'dart:io';

import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:image_picker/image_picker.dart';

class CoverImagePicker extends StatefulWidget {
  final List<String>? initialImagePaths;
  final ValueChanged<List<File>>? onImagesChanged;

  const CoverImagePicker({
    super.key,
    this.initialImagePaths,
    this.onImagesChanged,
  });

  @override
  State<CoverImagePicker> createState() => _CoverImagePickerState();
}

class _CoverImagePickerState extends State<CoverImagePicker> {
  static const int _maxSlots = 4;
  static const double _gap = 5;
  static const double _outerRadius = 16; // the 4 absolute outer corners
  static const double _innerRadius = 5; // corners adjacent to another box

  final List<File?> _images = List.filled(_maxSlots, null, growable: false);
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final paths = widget.initialImagePaths ?? [];
    for (int i = 0; i < paths.length && i < _maxSlots; i++) {
      final p = paths[i];
      if (p.isNotEmpty && !p.startsWith('http')) {
        _images[i] = File(p);
      }
    }
  }

  Future<void> _pickImage(int index) async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;
    setState(() => _images[index] = File(picked.path));
    _emit();
  }

  void _removeImage(int index) {
    setState(() {
      for (int i = index; i < _maxSlots - 1; i++) {
        _images[i] = _images[i + 1];
      }
      _images[_maxSlots - 1] = null;
    });
    _emit();
  }

  void _emit() {
    widget.onImagesChanged?.call(_images.whereType<File>().toList());
  }

  /// A distinct light fill for each slot so the boxes read as separate.
  Color _fillFor(int index) {
    switch (index) {
      case 0:
        return AppColors.primaryColor.withAlpha(22);
      case 1:
        return AppColors.blueColor.withAlpha(18);
      case 2:
        return AppColors.yelloColor.withAlpha(28);
      default:
        return AppColors.secondryColor.withAlpha(20);
    }
  }

  BorderRadius _radiusFor(int index) {
    const outer = Radius.circular(_outerRadius);
    const inner = Radius.circular(_innerRadius);
    switch (index) {
      case 0: // left box: outer on the left edge, inner on the right
        return const BorderRadius.only(
          topLeft: outer,
          bottomLeft: outer,
          topRight: inner,
          bottomRight: inner,
        );
      case 1: // top-right box: outer only at top-right
        return const BorderRadius.only(
          topRight: outer,
          topLeft: inner,
          bottomLeft: inner,
          bottomRight: inner,
        );
      case 3: // bottom-right box: outer only at bottom-right
        return const BorderRadius.only(
          bottomRight: outer,
          topLeft: inner,
          topRight: inner,
          bottomLeft: inner,
        );
      default: // middle-right box: fully interior
        return const BorderRadius.all(inner);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 220,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(flex: 3, child: _buildSlot(0, isMain: true)),
            const SizedBox(width: _gap),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Expanded(child: _buildSlot(1)),
                  const SizedBox(height: _gap),
                  Expanded(child: _buildSlot(2)),
                  const SizedBox(height: _gap),
                  Expanded(child: _buildSlot(3)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlot(int index, {bool isMain = false}) {
    final image = _images[index];
    final isEnabled = index == 0 || _images[index - 1] != null;

    return image != null
        ? _FilledSlot(
            image: image,
            isMain: isMain,
            borderRadius: _radiusFor(index),
            onRemove: () => _removeImage(index),
            onTap: () => _pickImage(index),
          )
        : _EmptySlot(
            isMain: isMain,
            isEnabled: isEnabled,
            fillColor: _fillFor(index),
            borderRadius: _radiusFor(index),
            onTap: isEnabled ? () => _pickImage(index) : null,
          );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _EmptySlot extends StatelessWidget {
  final bool isMain;
  final bool isEnabled;
  final Color fillColor;
  final BorderRadius borderRadius;
  final VoidCallback? onTap;

  const _EmptySlot({
    required this.isMain,
    required this.isEnabled,
    required this.fillColor,
    required this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = isEnabled
        ? AppColors.primaryColor
        : AppColors.primaryColor.withAlpha(70);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: isEnabled ? fillColor : AppColors.blackColor.withAlpha(8),
          borderRadius: borderRadius,
          border: Border.all(
            color: AppColors.blackColor.withAlpha(isEnabled ? 45 : 25),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.image_plus,
              color: iconColor,
              size: isMain ? 28 : 18,
            ),
            if (isMain) ...[
              const SizedBox(height: 8),
              Text(
                'Add cover image',
                style: AppTextStyle.bodyText3.copyWith(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'jpg, png • 16:9 preferred',
                style: AppTextStyle.bodyText3.copyWith(
                  color: AppColors.blackColor.withAlpha(90),
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FilledSlot extends StatelessWidget {
  final File image;
  final bool isMain;
  final BorderRadius borderRadius;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  const _FilledSlot({
    required this.image,
    required this.isMain,
    required this.borderRadius,
    required this.onRemove,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          border: Border.all(
            color: AppColors.blackColor.withAlpha(45),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.file(image, fit: BoxFit.cover),

              if (isMain)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Cover',
                      style: AppTextStyle.bodyText3.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),

              Positioned(
                top: 6,
                right: 6,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onRemove,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(170),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      LucideIcons.x,
                      color: Colors.white,
                      size: isMain ? 14 : 11,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
