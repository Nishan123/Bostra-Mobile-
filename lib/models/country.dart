class Country {
  final String phoneCode;
  final String countryCode;
  final String prefixImage;

  const Country({
    required this.phoneCode,
    required this.countryCode,
    required this.prefixImage,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Country && other.countryCode == countryCode;
  }

  @override
  int get hashCode => countryCode.hashCode;
}
