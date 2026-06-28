import 'package:equatable/equatable.dart';

/// A company registered by a user. Campaigns are launched under a company, and
/// a company has one owner (the registrant) plus invited founders.
class CompanyModel extends Equatable {
  final String? id;
  final String? ownerId;
  final String name;
  final String? tagline;
  final String? description;
  final String? industry;
  final String? registrationNumber;
  final String? logoUrl;
  final String? website;
  final String? email;
  final String? city;
  final String? country;
  final bool isVerified;
  final DateTime? verifiedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Aggregates returned by the `get_my_companies` RPC (null elsewhere).
  final int? founderCount;
  final int? campaignCount;

  /// The current viewer's role in this company: 'owner' or 'founder'.
  final String? myRole;

  const CompanyModel({
    this.id,
    this.ownerId,
    this.name = '',
    this.tagline,
    this.description,
    this.industry,
    this.registrationNumber,
    this.logoUrl,
    this.website,
    this.email,
    this.city,
    this.country,
    this.isVerified = false,
    this.verifiedAt,
    this.createdAt,
    this.updatedAt,
    this.founderCount,
    this.campaignCount,
    this.myRole,
  });

  bool get isOwner => myRole == 'owner';

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id'] as String?,
      ownerId: json['owner_id'] as String?,
      name: json['name'] as String? ?? '',
      tagline: json['tagline'] as String?,
      description: json['description'] as String?,
      industry: json['industry'] as String?,
      registrationNumber: json['registration_number'] as String?,
      logoUrl: json['logo_url'] as String?,
      website: json['website'] as String?,
      email: json['email'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      verifiedAt: json['verified_at'] != null
          ? DateTime.parse(json['verified_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      founderCount: (json['founder_count'] as num?)?.toInt(),
      campaignCount: (json['campaign_count'] as num?)?.toInt(),
      myRole: json['my_role'] as String?,
    );
  }

  /// JSON for inserting/updating the `companies` table. Null and aggregate-only
  /// fields are omitted so the database can apply its own defaults.
  Map<String, dynamic> toInsertJson() {
    return {
      if (ownerId != null) 'owner_id': ownerId,
      'name': name,
      if (tagline != null) 'tagline': tagline,
      if (description != null) 'description': description,
      if (industry != null) 'industry': industry,
      if (registrationNumber != null) 'registration_number': registrationNumber,
      if (logoUrl != null) 'logo_url': logoUrl,
      if (website != null) 'website': website,
      if (email != null) 'email': email,
      if (city != null) 'city': city,
      if (country != null) 'country': country,
    };
  }

  CompanyModel copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? tagline,
    String? description,
    String? industry,
    String? registrationNumber,
    String? logoUrl,
    String? website,
    String? email,
    String? city,
    String? country,
    bool? isVerified,
    DateTime? verifiedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? founderCount,
    int? campaignCount,
    String? myRole,
  }) {
    return CompanyModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      tagline: tagline ?? this.tagline,
      description: description ?? this.description,
      industry: industry ?? this.industry,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      logoUrl: logoUrl ?? this.logoUrl,
      website: website ?? this.website,
      email: email ?? this.email,
      city: city ?? this.city,
      country: country ?? this.country,
      isVerified: isVerified ?? this.isVerified,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      founderCount: founderCount ?? this.founderCount,
      campaignCount: campaignCount ?? this.campaignCount,
      myRole: myRole ?? this.myRole,
    );
  }

  @override
  List<Object?> get props => [
        id,
        ownerId,
        name,
        tagline,
        description,
        industry,
        registrationNumber,
        logoUrl,
        website,
        email,
        city,
        country,
        isVerified,
        verifiedAt,
        createdAt,
        updatedAt,
        founderCount,
        campaignCount,
        myRole,
      ];
}
