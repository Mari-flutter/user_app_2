import 'package:flutter/material.dart';

import 'Receipt_Generate/chit_receipt.dart';

class button extends StatefulWidget {
  const button({super.key});

  @override
  State<button> createState() => _buttonState();
}

class _buttonState extends State<button> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(onPressed:  () async {
          await ChitReceiptPDF(context, {
          'bookingId': '#GOLD4257',
          'customerName': 'Thanish Prakash',
          'customerId': '#FOX65432',
          'contactNumber': '+91 98765 43210',
          'TransactionID': 'TXN2025110100123',
          'Time': '2:30 PM IST',
            'transactionDate' : '11 November 2025',
          'Date': '11 November 2025',
          'status': 'Success',
          'storeContact': '+91 80 6789 5432',
            'TotalAmountPaid': '10,000',
            'TotalAmountPaidWords': 'Ten Thousand Rupees Only',
            'ChitIdName': '#F938373 - 10L Chit Scheme',
            'Installment': '04 0f 12',
          });
          },child: Text('download')),
      ),
    );
  }
}
