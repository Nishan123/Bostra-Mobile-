import 'dart:io';

import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:image_picker/image_picker.dart';

/// Grid-style cover image picker — 1 large primary slot + 3 stacked secondary
/// slots. Slots fill sequentially. All picked files are surfaced via
/// [onImagesChanged].
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

  @override
  Widget build(BuildContext context) {
    // The outer Container owns the border + borderRadius so the frame is always
    // visible regardless of what's inside (empty slots or filled images).
    // The inner ClipRRect clips content to match, and the ColoredBox background
    // shows through the 2 px gaps between slots, acting as grid dividers.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.primaryColor.withAlpha(130),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ClipRRect(
          // Subtract border width so content sits flush inside the stroke.
          borderRadius: BorderRadius.circular(14.5),
          child: ColoredBox(
            // This background peeks through the 2 px gaps as grid dividers.
            color: AppColors.primaryColor.withAlpha(90),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 3, child: _buildSlot(0, isMain: true)),
                const SizedBox(width: 2),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Expanded(child: _buildSlot(1)),
                      const SizedBox(height: 2),
                      Expanded(child: _buildSlot(2)),
                      const SizedBox(height: 2),
                      Expanded(child: _buildSlot(3)),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
            onRemove: () => _removeImage(index),
            onTap: () => _pickImage(index),
          )
        : _EmptySlot(
            isMain: isMain,
            isEnabled: isEnabled,
            onTap: isEnabled ? () => _pickImage(index) : null,
          );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _EmptySlot extends StatelessWidget {
  final bool isMain;
  final bool isEnabled;
  final VoidCallback? onTap;

  const _EmptySlot({
    required this.isMain,
    required this.isEnabled,
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
        // No inner border — the outer Container + ColoredBox gaps handle framing.
        color: isEnabled
            ? AppColors.primaryColor.withAlpha(18)
            : AppColors.primaryColor.withAlpha(8),
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
  final VoidCallback onRemove;
  final VoidCallback onTap;

  const _FilledSlot({
    required this.image,
    required this.isMain,
    required this.onRemove,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
    );
  }
}
