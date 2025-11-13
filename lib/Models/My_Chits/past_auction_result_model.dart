class PastAuctionResultModel {
  final String userID;
  final bool chitTaken;
  final DateTime chitTakenDate;
  final double amountTaken;
  final bool isActive;
  final String profileId;
  final List<BidHistory> bidHistories;
  final String name;

  PastAuctionResultModel({
    required this.userID,
    required this.chitTaken,
    required this.chitTakenDate,
    required this.amountTaken,
    required this.isActive,
    required this.profileId,
    required this.bidHistories,
    required this.name,
  });

  factory PastAuctionResultModel.fromJson(Map<String, dynamic> json) {
    final dateString = json['chitTakenDate'] as String?; // Cast to nullable String

    return PastAuctionResultModel(
      userID: json['userID'] ?? '',
      chitTaken: json['chitTaken'] ?? false,
      // Fix: Check if dateString is null or empty before parsing
      chitTakenDate: (dateString != null && dateString.isNotEmpty)
          ? DateTime.parse(dateString)
          : DateTime(1970), // Fallback to a default DateTime
      amountTaken: (json['amountTaken'] ?? 0).toDouble(),
      isActive: json['isActive'] ?? false,
      profileId: json['profileId'] ?? '',
      bidHistories: (json['bidHistories'] as List<dynamic>?)
          ?.map((e) => BidHistory.fromJson(e))
          .toList() ??
          [],
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userID': userID,
      'chitTaken': chitTaken,
      'chitTakenDate': chitTakenDate.toIso8601String(),
      'amountTaken': amountTaken,
      'isActive': isActive,
      'profileId': profileId,
      'bidHistories': bidHistories.map((e) => e.toJson()).toList(),
      'name': name,
    };
  }
}

class BidHistory {
  final String id;
  final String chitId;
  final String? chit;
  final String memberId;
  final String userId;
  final String userName;
  final int auctionNumber;
  final double bidValue;
  final DateTime bidTime;

  BidHistory({
    required this.id,
    required this.chitId,
    this.chit,
    required this.memberId,
    required this.userId,
    required this.userName,
    required this.auctionNumber,
    required this.bidValue,
    required this.bidTime,
  });

  factory BidHistory.fromJson(Map<String, dynamic> json) {
    return BidHistory(
      id: json['id'] ?? '',
      chitId: json['chitId'] ?? '',
      chit: json['chit'],
      memberId: json['memberId'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      auctionNumber: json['auctionNumber'] ?? 0,
      bidValue: (json['bidValue'] ?? 0).toDouble(),
      bidTime: DateTime.parse(json['bidTime']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chitId': chitId,
      'chit': chit,
      'memberId': memberId,
      'userId': userId,
      'userName': userName,
      'auctionNumber': auctionNumber,
      'bidValue': bidValue,
      'bidTime': bidTime.toIso8601String(),
    };
  }
}
