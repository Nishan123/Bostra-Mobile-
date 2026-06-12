import 'dart:io';
import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class DocUploadBox extends StatefulWidget {
  final String docType;
  final String? initialFilePath;
  final ValueChanged<File?>? onFilePicked;

  const DocUploadBox({
    super.key,
    required this.docType,
    this.initialFilePath,
    this.onFilePicked,
  });

  @override
  State<DocUploadBox> createState() => _DocUploadBoxState();
}

class _DocUploadBoxState extends State<DocUploadBox> {
  File? _pickedFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.initialFilePath != null && widget.initialFilePath!.isNotEmpty) {
      _pickedFile = File(widget.initialFilePath!);
    }
  }

  @override
  void didUpdateWidget(covariant DocUploadBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialFilePath != oldWidget.initialFilePath) {
      setState(() {
        _pickedFile = widget.initialFilePath != null && widget.initialFilePath!.isNotEmpty
            ? File(widget.initialFilePath!)
            : null;
      });
    }
  }

  Future<void> _pickFile() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        _pickedFile = File(file.path);
      });
      widget.onFilePicked?.call(_pickedFile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: _pickFile,
        child: DottedBorder(
        options: RoundedRectDottedBorderOptions(
          color: AppColors.primaryColor.withAlpha(150),
          strokeWidth: 1.5,
          dashPattern: const [8, 5],
          radius: const Radius.circular(12),
          padding: EdgeInsets.zero,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: _pickedFile != null
              ? _buildPickedFileView()
              : _buildUploadPrompt(),
        ),
      ),
      ),
    );
  }

  Widget _buildUploadPrompt() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.blackColor.withAlpha(20),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.cloud_upload_outlined,
            color: AppColors.blackColor.withAlpha(150),
            size: 28,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Click to select and upload doc',
          style: AppTextStyle.normalText.copyWith(
            color: AppColors.blackColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '(${widget.docType})',
          style: AppTextStyle.bodyText2.copyWith(
            color: AppColors.blackColor.withAlpha(150),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'pdf, jpg, png',
          style: AppTextStyle.bodyText3.copyWith(
            color: AppColors.blackColor.withAlpha(100),
          ),
        ),
      ],
    );
  }

  Widget _buildPickedFileView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withAlpha(30),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle_outline,
            color: AppColors.primaryColor,
            size: 28,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'File selected',
          style: AppTextStyle.normalText.copyWith(
            color: AppColors.primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            _pickedFile!.path.split('/').last,
            style: AppTextStyle.bodyText3.copyWith(
              color: AppColors.blackColor.withAlpha(150),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tap to change',
          style: AppTextStyle.bodyText3.copyWith(
            color: AppColors.textButtonColor,
          ),
        ),
      ],
    );
  }
}
