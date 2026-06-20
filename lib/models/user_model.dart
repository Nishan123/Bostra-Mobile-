import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String phone;
  final String? fullName;
  final String? dob;
  final String? address;
  final String? citizenshipUrl;
  final String? nationalIdFrontUrl;
  final String? nationalIdBackUrl;

  const UserModel({
    required this.id,
    required this.phone,
    this.fullName,
    this.dob,
    this.address,
    this.citizenshipUrl,
    this.nationalIdFrontUrl,
    this.nationalIdBackUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      phone: json['phone'] as String,
      fullName: json['full_name'] as String?,
      dob: json['dob'] as String?,
      address: json['address'] as String?,
      citizenshipUrl: json['citizenship_url'] as String?,
      nationalIdFrontUrl: json['national_id_front_url'] as String?,
      nationalIdBackUrl: json['national_id_back_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      if (fullName != null) 'full_name': fullName,
      if (dob != null) 'dob': dob,
      if (address != null) 'address': address,
      if (citizenshipUrl != null) 'citizenship_url': citizenshipUrl,
      if (nationalIdFrontUrl != null) 'national_id_front_url': nationalIdFrontUrl,
      if (nationalIdBackUrl != null) 'national_id_back_url': nationalIdBackUrl,
    };
  }

  UserModel copyWith({
    String? id,
    String? phone,
    String? fullName,
    String? dob,
    String? address,
    String? citizenshipUrl,
    String? nationalIdFrontUrl,
    String? nationalIdBackUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      fullName: fullName ?? this.fullName,
      dob: dob ?? this.dob,
      address: address ?? this.address,
      citizenshipUrl: citizenshipUrl ?? this.citizenshipUrl,
      nationalIdFrontUrl: nationalIdFrontUrl ?? this.nationalIdFrontUrl,
      nationalIdBackUrl: nationalIdBackUrl ?? this.nationalIdBackUrl,
    );
  }

  @override
  List<Object?> get props => [
        id,
        phone,
        fullName,
        dob,
        address,
        citizenshipUrl,
        nationalIdFrontUrl,
        nationalIdBackUrl,
      ];
}
