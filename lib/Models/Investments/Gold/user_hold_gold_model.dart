class GoldHoldings {
  final String profileId;
  final double userGold;
  final double userInvestment;

  GoldHoldings({
    required this.profileId,
    required this.userGold,
    required this.userInvestment,
  });

  factory GoldHoldings.fromJson(Map<String, dynamic> json) {
    return GoldHoldings(
      profileId: json['profileId'] ?? '',
      userGold: (json['userGold'] ?? 0).toDouble(),
      userInvestment: (json['userInvestment'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profileId': profileId,
      'userGold': userGold,
      'userInvestment': userInvestment,
    };
  }
}
