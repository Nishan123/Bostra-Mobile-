import 'dart:io';

import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:image_picker/image_picker.dart';

/// Circular company-logo picker. Emits the picked local file path (or null when
/// cleared) via [onChanged].
class CompanyLogoPicker extends StatefulWidget {
  final String? initialPath;
  final ValueChanged<String?> onChanged;

  const CompanyLogoPicker({
    super.key,
    this.initialPath,
    required this.onChanged,
  });

  @override
  State<CompanyLogoPicker> createState() => _CompanyLogoPickerState();
}

class _CompanyLogoPickerState extends State<CompanyLogoPicker> {
  final ImagePicker _picker = ImagePicker();
  String? _path;

  @override
  void initState() {
    super.initState();
    _path = widget.initialPath;
  }

  Future<void> _pick() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;
    setState(() => _path = picked.path);
    widget.onChanged(picked.path);
  }

  bool get _isRemote => _path != null && _path!.startsWith('http');

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: _pick,
        child: Stack(
          children: [
            Container(
              height: 96,
              width: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryColor.withAlpha(18),
                border: Border.all(
                  color: AppColors.primaryColor.withAlpha(130),
                  width: 1.5,
                ),
                image: _path != null
                    ? DecorationImage(
                        image: _isRemote
                            ? NetworkImage(_path!)
                            : FileImage(File(_path!)) as ImageProvider,
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _path == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.image_plus,
                          color: AppColors.primaryColor,
                          size: 26,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Logo',
                          style: AppTextStyle.bodyText3.copyWith(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                  : null,
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.whiteColor, width: 2),
                ),
                child: Icon(
                  LucideIcons.pencil,
                  color: AppColors.whiteColor,
                  size: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
