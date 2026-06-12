class MonthProjection {
  final int monthNumber;
  final String monthLabel;
  final String objectives;
  final String goals;
  final String initiative;
  const MonthProjection({
    required this.monthNumber,
    required this.monthLabel,
    this.objectives = '',
    this.goals = '',
    this.initiative = '',
  });
  MonthProjection copyWith({
    int? monthNumber,
    String? monthLabel,
    String? objectives,
    String? goals,
    String? initiative,
  }) {
    return MonthProjection(
      monthNumber: monthNumber ?? this.monthNumber,
      monthLabel: monthLabel ?? this.monthLabel,
      objectives: objectives ?? this.objectives,
      goals: goals ?? this.goals,
      initiative: initiative ?? this.initiative,
    );
  }

  factory MonthProjection.fromJson(Map<String, dynamic> json) {
    return MonthProjection(
      monthNumber: json['month_number'] as int,
      monthLabel: json['month_label'] as String,
      objectives: json['objectives'] as String? ?? '',
      goals: json['goals'] as String? ?? '',
      initiative: json['initiative'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month_number': monthNumber,
      'month_label': monthLabel,
      'objectives': objectives,
      'goals': goals,
      'initiative': initiative,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MonthProjection && other.monthNumber == monthNumber;
  }

  @override
  int get hashCode => monthNumber.hashCode;
}

class CampaignModel {
  // ── Identity ──
  final String? id;
  final String? userId;

  // ── Screen 1: Introductions ──
  final String startupName;
  final String shortTagline;
  final String industry;

  // ── Screen 1: Vision & 3 month projection ──
  final List<MonthProjection> monthProjections;

  // ── Screen 2: Tell us more ──
  final String description;
  final String problemStatement;
  final String solution;
  final String targetAudience;
  final String uniqueSellingPoint;

  // ── Screen 3: Documents ──
  final String? companyRegistrationUrl;
  final String? panUrl;
  final String? moaAoaUrl;

  // ── Screen 4: Target amount ──
  final double targetAmount;
  final bool agreedToTerms;

  // ── Media ──
  final String? logoUrl;
  final String? coverImageUrl;
  final List<String> galleryImageUrls;
  final String? pitchVideoUrl;

  // ── Funding & Investment ──
  final double currentFunding;
  final List<String> investors;
  final int totalInvestors;
  final double equityOffered;
  final double minimumInvestment;

  // ── Status & Metadata ──
  final String status; // 'draft', 'pending', 'verified', 'active', 'completed', 'rejected'
  final bool isVerified;
  final bool isFeatured;
  final String? rejectionReason;
  final String? category;
  final List<String> tags;

  // ── Social & Engagement ──
  final int viewsCount;
  final int likesCount;
  final List<String> likedBy;

  // ── Team ──
  final String? founderName;
  final String? founderEmail;
  final String? founderPhone;
  final List<String> teamMembers;

  // ── Location ──
  final String? city;
  final String? country;

  // ── Timestamps ──
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? startDate;
  final DateTime? endDate;

  const CampaignModel({
    // Identity
    this.id,
    this.userId,

    // Screen 1
    this.startupName = '',
    this.shortTagline = '',
    this.industry = '',
    this.monthProjections = const [],

    // Screen 2
    this.description = '',
    this.problemStatement = '',
    this.solution = '',
    this.targetAudience = '',
    this.uniqueSellingPoint = '',

    // Screen 3
    this.companyRegistrationUrl,
    this.panUrl,
    this.moaAoaUrl,

    // Screen 4
    this.targetAmount = 0.0,
    this.agreedToTerms = false,

    // Media
    this.logoUrl,
    this.coverImageUrl,
    this.galleryImageUrls = const [],
    this.pitchVideoUrl,

    // Funding & Investment
    this.currentFunding = 0.0,
    this.investors = const [],
    this.totalInvestors = 0,
    this.equityOffered = 0.0,
    this.minimumInvestment = 0.0,

    // Status & Metadata
    this.status = 'draft',
    this.isVerified = false,
    this.isFeatured = false,
    this.rejectionReason,
    this.category,
    this.tags = const [],

    // Social & Engagement
    this.viewsCount = 0,
    this.likesCount = 0,
    this.likedBy = const [],

    // Team
    this.founderName,
    this.founderEmail,
    this.founderPhone,
    this.teamMembers = const [],

    // Location
    this.city,
    this.country,

    // Timestamps
    this.createdAt,
    this.updatedAt,
    this.startDate,
    this.endDate,
  });

  CampaignModel copyWith({
    String? id,
    String? userId,
    String? startupName,
    String? shortTagline,
    String? industry,
    List<MonthProjection>? monthProjections,
    String? description,
    String? problemStatement,
    String? solution,
    String? targetAudience,
    String? uniqueSellingPoint,
    String? companyRegistrationUrl,
    String? panUrl,
    String? moaAoaUrl,
    double? targetAmount,
    bool? agreedToTerms,
    String? logoUrl,
    String? coverImageUrl,
    List<String>? galleryImageUrls,
    String? pitchVideoUrl,
    double? currentFunding,
    List<String>? investors,
    int? totalInvestors,
    double? equityOffered,
    double? minimumInvestment,
    String? status,
    bool? isVerified,
    bool? isFeatured,
    String? rejectionReason,
    String? category,
    List<String>? tags,
    int? viewsCount,
    int? likesCount,
    List<String>? likedBy,
    String? founderName,
    String? founderEmail,
    String? founderPhone,
    List<String>? teamMembers,
    String? city,
    String? country,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return CampaignModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      startupName: startupName ?? this.startupName,
      shortTagline: shortTagline ?? this.shortTagline,
      industry: industry ?? this.industry,
      monthProjections: monthProjections ?? this.monthProjections,
      description: description ?? this.description,
      problemStatement: problemStatement ?? this.problemStatement,
      solution: solution ?? this.solution,
      targetAudience: targetAudience ?? this.targetAudience,
      uniqueSellingPoint: uniqueSellingPoint ?? this.uniqueSellingPoint,
      companyRegistrationUrl: companyRegistrationUrl ?? this.companyRegistrationUrl,
      panUrl: panUrl ?? this.panUrl,
      moaAoaUrl: moaAoaUrl ?? this.moaAoaUrl,
      targetAmount: targetAmount ?? this.targetAmount,
      agreedToTerms: agreedToTerms ?? this.agreedToTerms,
      logoUrl: logoUrl ?? this.logoUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      galleryImageUrls: galleryImageUrls ?? this.galleryImageUrls,
      pitchVideoUrl: pitchVideoUrl ?? this.pitchVideoUrl,
      currentFunding: currentFunding ?? this.currentFunding,
      investors: investors ?? this.investors,
      totalInvestors: totalInvestors ?? this.totalInvestors,
      equityOffered: equityOffered ?? this.equityOffered,
      minimumInvestment: minimumInvestment ?? this.minimumInvestment,
      status: status ?? this.status,
      isVerified: isVerified ?? this.isVerified,
      isFeatured: isFeatured ?? this.isFeatured,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      viewsCount: viewsCount ?? this.viewsCount,
      likesCount: likesCount ?? this.likesCount,
      likedBy: likedBy ?? this.likedBy,
      founderName: founderName ?? this.founderName,
      founderEmail: founderEmail ?? this.founderEmail,
      founderPhone: founderPhone ?? this.founderPhone,
      teamMembers: teamMembers ?? this.teamMembers,
      city: city ?? this.city,
      country: country ?? this.country,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  factory CampaignModel.fromJson(Map<String, dynamic> json) {
    return CampaignModel(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      startupName: json['startup_name'] as String? ?? '',
      shortTagline: json['short_tagline'] as String? ?? '',
      industry: json['industry'] as String? ?? '',
      monthProjections: (json['month_projections'] as List<dynamic>?)
              ?.map((e) => MonthProjection.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      description: json['description'] as String? ?? '',
      problemStatement: json['problem_statement'] as String? ?? '',
      solution: json['solution'] as String? ?? '',
      targetAudience: json['target_audience'] as String? ?? '',
      uniqueSellingPoint: json['unique_selling_point'] as String? ?? '',
      companyRegistrationUrl: json['company_registration_url'] as String?,
      panUrl: json['pan_url'] as String?,
      moaAoaUrl: json['moa_aoa_url'] as String?,
      targetAmount: (json['target_amount'] as num?)?.toDouble() ?? 0.0,
      agreedToTerms: json['agreed_to_terms'] as bool? ?? false,
      logoUrl: json['logo_url'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      galleryImageUrls: (json['gallery_image_urls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      pitchVideoUrl: json['pitch_video_url'] as String?,
      currentFunding: (json['current_funding'] as num?)?.toDouble() ?? 0.0,
      investors: (json['investors'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      totalInvestors: json['total_investors'] as int? ?? 0,
      equityOffered: (json['equity_offered'] as num?)?.toDouble() ?? 0.0,
      minimumInvestment: (json['minimum_investment'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'draft',
      isVerified: json['is_verified'] as bool? ?? false,
      isFeatured: json['is_featured'] as bool? ?? false,
      rejectionReason: json['rejection_reason'] as String?,
      category: json['category'] as String?,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      viewsCount: json['views_count'] as int? ?? 0,
      likesCount: json['likes_count'] as int? ?? 0,
      likedBy: (json['liked_by'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      founderName: json['founder_name'] as String?,
      founderEmail: json['founder_email'] as String?,
      founderPhone: json['founder_phone'] as String?,
      teamMembers: (json['team_members'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      city: json['city'] as String?,
      country: json['country'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'] as String)
          : null,
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'startup_name': startupName,
      'short_tagline': shortTagline,
      'industry': industry,
      'month_projections': monthProjections.map((e) => e.toJson()).toList(),
      'description': description,
      'problem_statement': problemStatement,
      'solution': solution,
      'target_audience': targetAudience,
      'unique_selling_point': uniqueSellingPoint,
      'company_registration_url': companyRegistrationUrl,
      'pan_url': panUrl,
      'moa_aoa_url': moaAoaUrl,
      'target_amount': targetAmount,
      'agreed_to_terms': agreedToTerms,
      'logo_url': logoUrl,
      'cover_image_url': coverImageUrl,
      'gallery_image_urls': galleryImageUrls,
      'pitch_video_url': pitchVideoUrl,
      'current_funding': currentFunding,
      'investors': investors,
      'total_investors': totalInvestors,
      'equity_offered': equityOffered,
      'minimum_investment': minimumInvestment,
      'status': status,
      'is_verified': isVerified,
      'is_featured': isFeatured,
      'rejection_reason': rejectionReason,
      'category': category,
      'tags': tags,
      'views_count': viewsCount,
      'likes_count': likesCount,
      'liked_by': likedBy,
      'founder_name': founderName,
      'founder_email': founderEmail,
      'founder_phone': founderPhone,
      'team_members': teamMembers,
      'city': city,
      'country': country,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
    };
  }

  /// Calculates funding progress as a percentage (0.0 to 1.0)
  double get fundingProgress =>
      targetAmount > 0 ? (currentFunding / targetAmount).clamp(0.0, 1.0) : 0.0;

  /// Remaining amount to reach target
  double get remainingAmount =>
      (targetAmount - currentFunding).clamp(0.0, targetAmount);

  /// Whether the campaign has reached its funding goal
  bool get isFunded => currentFunding >= targetAmount;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CampaignModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}