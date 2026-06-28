import 'dart:io';

import 'package:bostra/controllers/user_controller.dart';
import 'package:bostra/ui/auth/state/user_details_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

final userDetailsViewModelProvider =
    NotifierProvider<UserDetailsViewModel, UserDetailsState>(
        UserDetailsViewModel.new);

class UserDetailsViewModel extends Notifier<UserDetailsState> {
  late UserController _userController;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  UserDetailsState build() {
    _userController = ref.read(userControllerProvider);
    return const UserDetailsState();
  }

  void setDocumentType(DocumentType type) {
    state = state.copyWith(documentType: type);
  }

  void goToStep(int step) {
    state = state.copyWith(currentStep: step);
  }

  /// Pick an image for the specified document slot.
  Future<void> pickDocument(String slot) async {
    final XFile? picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;

    switch (slot) {
      case 'profilePic':
        state = state.copyWith(profilePicFile: picked);
        break;
      case 'citizenship':
        state = state.copyWith(citizenshipFile: picked);
        break;
      case 'nationalIdFront':
        state = state.copyWith(nationalIdFrontFile: picked);
        break;
      case 'nationalIdBack':
        state = state.copyWith(nationalIdBackFile: picked);
        break;
    }
  }

  /// Validates and submits personal details — advances to step 1 on success.
  Future<bool> submitPersonalDetails({
    required String userId,
    required String fullName,
    required String dob,
    required String address,
  }) async {
    state = state.copyWith(status: UserDetailsStatus.loading, errorMessage: null);

    String? profilePicUrl;
    if (state.profilePicFile != null) {
      final uploadResult = await _userController.uploadDocument(
        userId: userId,
        file: File(state.profilePicFile!.path),
        fileName: 'profile_pic.${state.profilePicFile!.path.split('.').last}',
      );

      bool uploadSuccess = false;
      await uploadResult.fold(
        (failure) async {
          state = state.copyWith(
            status: UserDetailsStatus.error,
            errorMessage: 'Profile picture upload failed: ${failure.errorMessage}',
          );
        },
        (url) async {
          profilePicUrl = url;
          uploadSuccess = true;
        },
      );
      if (!uploadSuccess) return false;
    }

    final result = await _userController.updateUserDetails(
      userId: userId,
      fullName: fullName,
      dob: dob,
      address: address,
      profilePicUrl: profilePicUrl,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: UserDetailsStatus.error,
          errorMessage: failure.errorMessage,
        );
        return false;
      },
      (_) {
        state = state.copyWith(
          status: UserDetailsStatus.success,
          currentStep: 1,
        );
        return true;
      },
    );
  }

  /// Uploads selected documents and saves URLs to the users table.
  Future<bool> submitDocuments(String userId) async {
    state = state.copyWith(status: UserDetailsStatus.loading, errorMessage: null);

    try {
      if (state.documentType == DocumentType.citizenship) {
        final file = state.citizenshipFile;
        if (file == null) {
          state = state.copyWith(
            status: UserDetailsStatus.error,
            errorMessage: 'Please select your citizenship document.',
          );
          return false;
        }
        final uploadResult = await _userController.uploadDocument(
          userId: userId,
          file: File(file.path),
          fileName: 'citizenship.${file.path.split('.').last}',
        );
        final urlResult = await uploadResult.fold(
          (failure) async {
            state = state.copyWith(
              status: UserDetailsStatus.error,
              errorMessage: failure.errorMessage,
            );
            return false;
          },
          (url) async {
            final saveResult = await _userController.saveDocumentUrl(
              userId: userId,
              column: 'citizenship_url',
              url: url,
            );
            return saveResult.fold((_) => false, (_) => true);
          },
        );
        if (!urlResult) return false;
      } else {
        // National ID — requires both front and back
        final front = state.nationalIdFrontFile;
        final back = state.nationalIdBackFile;

        if (front == null || back == null) {
          state = state.copyWith(
            status: UserDetailsStatus.error,
            errorMessage: 'Please select both front and back of your National ID.',
          );
          return false;
        }

        // Upload front
        final frontUpload = await _userController.uploadDocument(
          userId: userId,
          file: File(front.path),
          fileName: 'national_id_front.${front.path.split('.').last}',
        );
        bool frontOk = false;
        await frontUpload.fold(
          (failure) async {
            state = state.copyWith(
              status: UserDetailsStatus.error,
              errorMessage: failure.errorMessage,
            );
          },
          (url) async {
            final save = await _userController.saveDocumentUrl(
              userId: userId,
              column: 'national_id_front_url',
              url: url,
            );
            save.fold((_) => null, (_) => frontOk = true);
          },
        );
        if (!frontOk) return false;

        // Upload back
        final backUpload = await _userController.uploadDocument(
          userId: userId,
          file: File(back.path),
          fileName: 'national_id_back.${back.path.split('.').last}',
        );
        bool backOk = false;
        await backUpload.fold(
          (failure) async {
            state = state.copyWith(
              status: UserDetailsStatus.error,
              errorMessage: failure.errorMessage,
            );
          },
          (url) async {
            final save = await _userController.saveDocumentUrl(
              userId: userId,
              column: 'national_id_back_url',
              url: url,
            );
            save.fold((_) => null, (_) => backOk = true);
          },
        );
        if (!backOk) return false;
      }

      state = state.copyWith(status: UserDetailsStatus.success);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: UserDetailsStatus.error,
        errorMessage: 'An unexpected error occurred: $e',
      );
      return false;
    }
  }

  void resetStatus() {
    state = state.copyWith(
      status: UserDetailsStatus.initial,
      errorMessage: null,
    );
  }
}
