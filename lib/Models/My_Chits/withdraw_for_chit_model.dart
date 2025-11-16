class WithdrawAmountModel {
  final String id;
  final double withdrawAmount;

  WithdrawAmountModel({
    required this.id,
    required this.withdrawAmount,
  });

  factory WithdrawAmountModel.fromJson(Map<String, dynamic> json) {
    return WithdrawAmountModel(
      id: json['id'],
      withdrawAmount: (json['withdrawamount'] ?? 0).toDouble(),
    );
  }
}
