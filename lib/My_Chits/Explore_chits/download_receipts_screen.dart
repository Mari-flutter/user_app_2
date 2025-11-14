import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user_app/My_Chits/Explore_chits/receipts_screen.dart';

import '../../Receipt_Generate/chit_receipt.dart';

class download_receipts extends StatefulWidget {
  final String userName;
  final String userID;
  final String date;
  final String time;
  final String chitName;
  final String orderId;
  final double amount;
  final String status;
  final String chitID;
  final String? mobilenumber;
  final int timeperiod;
  final int totaltimeperiod;

  const download_receipts({
    super.key,
    required this.userName,
    required this.userID,
    required this.date,
    required this.time,
    required this.chitName,
    required this.orderId,
    required this.amount,
    required this.status,
    required this.chitID,
    required this.mobilenumber,
    required this.timeperiod,
    required this.totaltimeperiod
  });

  @override
  State<download_receipts> createState() => _download_receiptsState();
}

class _download_receiptsState extends State<download_receipts> {
  String convertAmountToWords(int number) {
    if (number == 0) return "Zero Rupees Only";

    final List<String> units = [
      "",
      "One",
      "Two",
      "Three",
      "Four",
      "Five",
      "Six",
      "Seven",
      "Eight",
      "Nine",
      "Ten",
      "Eleven",
      "Twelve",
      "Thirteen",
      "Fourteen",
      "Fifteen",
      "Sixteen",
      "Seventeen",
      "Eighteen",
      "Nineteen"
    ];

    final List<String> tens = [
      "",
      "",
      "Twenty",
      "Thirty",
      "Forty",
      "Fifty",
      "Sixty",
      "Seventy",
      "Eighty",
      "Ninety"
    ];

    String twoDigit(int n) {
      if (n < 20) return units[n];
      return "${tens[n ~/ 10]} ${units[n % 10]}".trim();
    }

    String threeDigit(int n) {
      if (n == 0) return "";
      if (n < 100) return twoDigit(n);
      return "${units[n ~/ 100]} Hundred ${twoDigit(n % 100)}".trim();
    }

    String words = "";

    if ((number ~/ 10000000) > 0) {
      words += "${twoDigit(number ~/ 10000000)} Crore ";
      number %= 10000000;
    }
    if ((number ~/ 100000) > 0) {
      words += "${twoDigit(number ~/ 100000)} Lakh ";
      number %= 100000;
    }
    if ((number ~/ 1000) > 0) {
      words += "${twoDigit(number ~/ 1000)} Thousand ";
      number %= 1000;
    }
    if ((number ~/ 100) > 0) {
      words += "${twoDigit(number ~/ 100)} Hundred ";
      number %= 100;
    }
    if (number > 0) {
      words += twoDigit(number);
    }

    return "${words.trim()} Rupees Only";
  }
  bool isDownloading = false;

  @override
  Widget build(BuildContext context) {
    String amountInWords = convertAmountToWords(widget.amount.toInt());
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: size.height * 0.02),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Image.asset(
                        'assets/images/My_Chits/back_arrow.png',
                        width: 24,
                        height: 24,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Download Receipt",
                        style: GoogleFonts.urbanist(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // 🔹 Grey Info Rectangle
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE2E2E2),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(11),
                      topRight: Radius.circular(11),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Foxl Chit Funds",
                            style: GoogleFonts.urbanist(
                              fontSize: 25,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF333333),
                            ),
                          ),
                          Text(
                            "${widget.userName} (${widget.userID})",
                            textAlign: TextAlign.right,
                            style: GoogleFonts.urbanist(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF333333),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Official Payment Receipt",
                            style: GoogleFonts.urbanist(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF333333),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 467,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                    border: Border.all(
                      color: const Color(0xFF4D4D4D),
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔹 Payment Success Section
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 4,
                            height: 57,
                            decoration: const BoxDecoration(
                              color: Color(0xFF07C66A),
                              borderRadius: BorderRadius.all(
                                Radius.circular(2),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF2E2E2E),
                                borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(8),
                                  topRight: Radius.circular(8),
                                ),
                              ),
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  Container(
                                    width: 33,
                                    height: 33,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFF1C3C38),
                                      border: Border.all(
                                        color: const Color(0xFF07C66A),
                                        width: 1,
                                      ),
                                    ),
                                    child: Center(
                                      child: Image.asset(
                                        'assets/images/My_Chits/chit_starting_date.png',
                                        width: 15,
                                        height: 15,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Payment Successful",
                                          style: GoogleFonts.urbanist(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          "Your payment has been received and processed",
                                          style: GoogleFonts.urbanist(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF07C66A),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // 🔹 Transaction Details Box
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E2E2E),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Transaction Details",
                              style: GoogleFonts.urbanist(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Order Id",
                                      style: GoogleFonts.urbanist(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF6E6E6E),
                                      ),
                                    ),
                                    Text(
                                      "${widget.orderId}",
                                      style: GoogleFonts.urbanist(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF989898),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      "Date",
                                      style: GoogleFonts.urbanist(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF6E6E6E),
                                      ),
                                    ),
                                    Text(
                                      "${widget.date}",
                                      style: GoogleFonts.urbanist(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF989898),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      "Installment",
                                      style: GoogleFonts.urbanist(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF6E6E6E),
                                      ),
                                    ),
                                    Text(
                                      "${widget.totaltimeperiod}/${widget.timeperiod}",
                                      style: GoogleFonts.urbanist(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF989898),
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Payment Method",
                                      style: GoogleFonts.urbanist(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF6E6E6E),
                                      ),
                                    ),
                                    Text(
                                      "UPI",
                                      style: GoogleFonts.urbanist(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF989898),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      "Time",
                                      style: GoogleFonts.urbanist(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF6E6E6E),
                                      ),
                                    ),
                                    Text(
                                      "${widget.time}",
                                      style: GoogleFonts.urbanist(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF989898),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      "Status",
                                      style: GoogleFonts.urbanist(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF6E6E6E),
                                      ),
                                    ),
                                    Text(
                                      "${widget.status}",
                                      style: GoogleFonts.urbanist(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF989898),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 🔹 Total Amount Paid Box
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E2E2E),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Total Amount Paid",
                              style: GoogleFonts.urbanist(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF6E6E6E),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "₹${widget.amount.toStringAsFixed(0)}",
                              style: GoogleFonts.urbanist(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF5B8EF8),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "Amount in words: $amountInWords",
                              style: GoogleFonts.urbanist(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF6E6E6E),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 🔹 Download Receipt Button
                      GestureDetector(
                        onTap: () async {
                          if (isDownloading) return; // Prevent multiple taps

                          setState(() => isDownloading = true);

                          await ChitReceiptPDF(context, {
                            'chitName': widget.chitName,
                            'chitId': widget.chitID,
                            'customerName': widget.userName,
                            'customerId': widget.userID,
                            'contactNumber': widget.mobilenumber ?? "",
                            'transactionDate': widget.date,
                            'transactionTime': widget.time,
                            'installment': "${widget.totaltimeperiod}/${widget.timeperiod}",
                            'orderId': widget.orderId,
                            'paymentStatus': widget.status,
                            'amount': widget.amount.toString(),
                            'TotalAmountPaidWords': amountInWords,
                          });

                          setState(() => isDownloading = false);
                        },
                        child: Container(
                          width: double.infinity,
                          height: 34,
                          decoration: BoxDecoration(
                            color: const Color(0xFF151515),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (!isDownloading) ...[
                                  Image.asset(
                                    'assets/images/My_Chits/download.png',
                                    width: 20,
                                    height: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    "Download Receipt",
                                    style: GoogleFonts.urbanist(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],

                                if (isDownloading) ...[
                                  SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
