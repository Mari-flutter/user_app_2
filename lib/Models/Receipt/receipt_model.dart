class ReceiptModel {
  final String type;       // buy, sell, physical, scheme, re
  final String title;      // Gold Buy, Gold Sell…
  final double amount;
  final double? grams;
  final DateTime date;
  final String? bookingId;
  final String? description;     // default message
  final String? referenceName;
  final double? GoldRate;// NEW FIELD (RE, GoldScheme)

  ReceiptModel({
    required this.type,
    required this.title,
    required this.amount,
    this.grams,
    required this.date,
    this.bookingId,
    this.description,
    this.referenceName,
    this.GoldRate
  });
}
