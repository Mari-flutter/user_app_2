class Bid {
  final String type;
  final String chitId;
  final String userId;
  final String userName;
  final int auctionNumber;
  final int amount;

  Bid({
    required this.type,
    required this.chitId,
    required this.userId,
    required this.userName,
    required this.auctionNumber,
    required this.amount,
  });

  // Convert JSON to Bid object
  factory Bid.fromJson(Map<String, dynamic> json) {
    return Bid(
      type: json['type'] as String,
      chitId: json['chitId'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      auctionNumber: (json['auctionNumber'] is int)
          ? json['auctionNumber']
          : int.parse(json['auctionNumber'].toString()),
      amount: (json['amount'] is int)
          ? json['amount']
          : int.parse(json['amount'].toString()),
    );
  }

  // Convert Bid object to JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'chitId': chitId,
      'userId': userId,
      'userName': userName,
      'auctionNumber': auctionNumber,
      'amount': amount,
    };
  }
}
