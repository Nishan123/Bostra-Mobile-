import 'package:image_picker/image_picker.dart';

enum UserDetailsStatus { initial, loading, success, error }

enum DocumentType { citizenship, nationalId }

class UserDetailsState {
  final UserDetailsStatus status;
  final int currentStep;
  final DocumentType documentType;
  final String? errorMessage;

  // Citizenship — single full doc
  final XFile? citizenshipFile;

  // National ID — front + back
  final XFile? nationalIdFrontFile;
  final XFile? nationalIdBackFile;

  const UserDetailsState({
    this.status = UserDetailsStatus.initial,
    this.currentStep = 0,
    this.documentType = DocumentType.citizenship,
    this.errorMessage,
    this.citizenshipFile,
    this.nationalIdFrontFile,
    this.nationalIdBackFile,
  });

  UserDetailsState copyWith({
    UserDetailsStatus? status,
    int? currentStep,
    DocumentType? documentType,
    String? errorMessage,
    XFile? citizenshipFile,
    XFile? nationalIdFrontFile,
    XFile? nationalIdBackFile,
  }) {
    return UserDetailsState(
      status: status ?? this.status,
      currentStep: currentStep ?? this.currentStep,
      documentType: documentType ?? this.documentType,
      errorMessage: errorMessage ?? this.errorMessage,
      citizenshipFile: citizenshipFile ?? this.citizenshipFile,
      nationalIdFrontFile: nationalIdFrontFile ?? this.nationalIdFrontFile,
      nationalIdBackFile: nationalIdBackFile ?? this.nationalIdBackFile,
    );
  }
}
