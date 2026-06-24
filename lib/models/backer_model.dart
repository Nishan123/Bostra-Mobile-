/// A single backer of a campaign: who they are (name/pic) and how much they
/// have put in. Hydrated from the `get_campaign_backers` RPC, which joins
/// `investments` to `users` and only exposes safe profile fields.
class BackerModel {
  final String investorId;
  final String? fullName;
  final String? profilePicUrl;
  final double amount;

  const BackerModel({
    required this.investorId,
    this.fullName,
    this.profilePicUrl,
    required this.amount,
  });

  factory BackerModel.fromJson(Map<String, dynamic> json) {
    return BackerModel(
      investorId: json['investor_id'] as String,
      fullName: json['full_name'] as String?,
      profilePicUrl: json['profile_pic_url'] as String?,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Name to render in the UI, with a graceful fallback for users who never
  /// completed their profile.
  String get displayName =>
      (fullName != null && fullName!.trim().isNotEmpty)
          ? fullName!.trim()
          : 'Anonymous Backer';

  bool get hasProfilePic =>
      profilePicUrl != null && profilePicUrl!.startsWith('http');
}
