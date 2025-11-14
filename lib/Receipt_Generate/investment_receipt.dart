import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

Future<void> InvestmentReceiptPDF(
    BuildContext context,
    Map<String, dynamic> data,
    ) async {
  final pageWidth =
      PdfPageFormat.a4.width - 2 * 18; // A4 width minus horizontal padding
  final pdf = pw.Document();

  final bookingConfirmedImage = pw.MemoryImage(
    (await rootBundle.load(
      'assets/images/Investments/booking_confirmed.png',
    )).buffer.asUint8List(),
  );
  final alert = pw.MemoryImage(
    (await rootBundle.load(
      'assets/images/Investments/alert_2.png',
    )).buffer.asUint8List(),
  );

  // Load fonts
  final regularFont = pw.Font.ttf(
    await rootBundle.load('assets/fonts/Urbanist-Regular.ttf'),
  );
  final boldFont = pw.Font.ttf(
    await rootBundle.load('assets/fonts/Urbanist-Bold.ttf'),
  );

  final blueBox = PdfColor.fromHex('#F5FAFF');
  final beigeBox = PdfColor.fromHex('#E9FAF2');
  final textcolor = PdfColor.fromHex('#B8B8B8');

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Container(
          padding: const pw.EdgeInsets.all(18),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [

              pw.SizedBox(height:50),

              // Customer Information Card
              pw.Container(
                width: 480,
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: blueBox,
                  borderRadius: pw.BorderRadius.circular(11),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "Customer Information",
                      style: pw.TextStyle(
                        font: boldFont,
                        fontSize: 15,
                        color: PdfColor.fromHex('#676767'),
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              "Customer Name",
                              style: pw.TextStyle(
                                font: regularFont,
                                fontSize: 11,
                                color: PdfColor.fromHex('#808080'),
                              ),
                            ),
                            pw.Text(
                              data['customerName'],
                              style: pw.TextStyle(
                                font: boldFont,
                                fontSize: 12,
                                color: PdfColor.fromHex('#454040'),
                              ),
                            ),
                            pw.SizedBox(height: 6),
                            pw.Text(
                              "Contact Number",
                              style: pw.TextStyle(
                                font: regularFont,
                                fontSize: 11,
                                color: PdfColor.fromHex('#808080'),
                              ),
                            ),
                            pw.Text(
                              data['contactNumber'],
                              style: pw.TextStyle(
                                font: boldFont,
                                fontSize: 12,
                                color: PdfColor.fromHex('#454040'),
                              ),
                            ),
                          ],
                        ),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              "Customer Id",
                              style: pw.TextStyle(
                                font: regularFont,
                                fontSize: 11,
                                color: PdfColor.fromHex('#808080'),
                              ),
                            ),
                            pw.Text(
                              data['customerId'],
                              style: pw.TextStyle(
                                font: boldFont,
                                fontSize: 12,
                                color: PdfColor.fromHex('#454040'),
                              ),
                            ),
                            pw.SizedBox(height: 6),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Delivery Confirmation Section
              pw.Container(
                width: 480,
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: beigeBox,
                  borderRadius: pw.BorderRadius.circular(11),
                ),
                child: pw.Column(
                  children: [
                    pw.Container(
                      width: pageWidth - 60, // safer dynamic width
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            "Payment Successful",
                            style: pw.TextStyle(
                              font: boldFont,
                              fontSize: 13,
                              color: PdfColor.fromHex('#07C66A'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      "Your payment has been received and processed successfully. Thank you for your transaction.",
                      style: pw.TextStyle(
                        color: PdfColor.fromHex('#808080'),
                        font: regularFont,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Collection Details
              pw.Text(
                "Transaction Details",
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 14,
                  color: PdfColors.brown,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Divider(color: PdfColor.fromHex('#C5C5C5'), height: 0.5),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [

                      pw.SizedBox(height: 15),
                      _detailRow(
                        "ROI Percentage",
                        data['ROI Percentage'],
                        boldFont,
                      ),
                      pw.SizedBox(height: 15),
                      _detailRow(
                        "Time",
                        data['transactionTime'],
                        boldFont,
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _detailRowEnd("Minimum Duration", data['Minimumduration'], boldFont),
                      pw.SizedBox(height: 15),
                      _detailRowEnd("Date", data['transactionDate'], boldFont),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 50),
              pw.Row(
                  mainAxisAlignment:pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.all(20),
                      width: 200,
                      decoration: pw.BoxDecoration(
                          color: PdfColor.fromHex('#EDF6FF'),
                          borderRadius: pw.BorderRadius.circular(11)
                      ),
                      child:pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              "Total Amount Paid",
                              style: pw.TextStyle(
                                font: regularFont,
                                fontSize: 10,
                                color: PdfColor.fromHex('#808080'),
                              ),
                            ),
                            pw.SizedBox(height: 5,),
                            pw.Text(
                              data['amount'],
                              style: pw.TextStyle(
                                font: regularFont,
                                fontSize: 16,
                                color: PdfColor.fromHex('#07C66A'),
                              ),
                            ),
                            pw.SizedBox(height: 30,),
                            pw.Text(
                              data['TotalAmountPaidWords'],
                              style: pw.TextStyle(
                                font: regularFont,
                                fontSize: 10,
                                color: PdfColor.fromHex('#808080'),
                              ),
                            ),
                          ]
                      ),

                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(20),
                      width: 200,
                      decoration: pw.BoxDecoration(
                          color: PdfColor.fromHex('#EDF6FF'),
                          borderRadius: pw.BorderRadius.circular(11)
                      ),
                      child:pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              "Name/Property Type",
                              style: pw.TextStyle(
                                font: regularFont,
                                fontSize: 10,
                                color: PdfColor.fromHex('#808080'),
                              ),
                            ),
                            pw.SizedBox(height: 5,),
                            pw.Text(
                              "${data['investmentName']}/${data['propertytype']}",
                              style: pw.TextStyle(
                                font: regularFont,
                                fontSize: 12,
                                color: PdfColor.fromHex('#454040'),
                              ),
                            ),
                            pw.SizedBox(height: 15,),
                            pw.Text(
                              "Maturity Date",
                              style: pw.TextStyle(
                                font: regularFont,
                                fontSize: 10,
                                color: PdfColor.fromHex('#808080'),
                              ),
                            ),
                            pw.SizedBox(height: 5,),
                            pw.Text(
                              data['maturitydate'],
                              style: pw.TextStyle(
                                font: regularFont,
                                fontSize: 12,
                                color: PdfColor.fromHex('#454040'),
                              ),
                            ),
                          ]
                      ),

                    )
                  ]
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Image(alert, width: 15, height: 15),
                  pw.SizedBox(width: 10),
                  pw.Container(
                    width: pageWidth - 50,
                    child: pw.Text(
                      "You can view the Confirmation Receipt in the Receipts section in Investment Menu. This is an\nelectronically generated receipt and does not require a signature.",
                      style: pw.TextStyle(font: regularFont, fontSize: 10),
                    ),
                  ),
                ],
              ),
              pw.Spacer(),
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      "Foxl Chits and Funds Private Limited – Official Receipt",
                      style: pw.TextStyle(
                        color: PdfColor.fromHex('#808080'),
                        font: regularFont,
                        fontSize: 10,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      "For any queries, please contact support at 00000000",
                      style: pw.TextStyle(
                        color: PdfColor.fromHex('#808080'),
                        font: regularFont,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ),
  );

  final bytes = await pdf.save();

  // Save file
  Directory directory;
  if (Platform.isAndroid) {
    directory = (await getExternalStorageDirectory())!;
  } else {
    directory = await getApplicationDocumentsDirectory();
  }
  final file = File('${directory.path}/Investment_Receipt_${data['bookingId']}.pdf');
  await file.writeAsBytes(bytes);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text("✅ Investment receipt saved to ${directory.path}"),
      backgroundColor: Colors.green,
    ),
  );

  await OpenFilex.open(file.path);
}

// Helper for displaying detail rows
pw.Widget _detailRow(String label, String value, pw.Font boldFont) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(label, style: pw.TextStyle(fontSize: 10)),
      pw.Text(value, style: pw.TextStyle(fontSize: 11, font: boldFont)),
    ],
  );
}
pw.Widget _detailRowEnd(String label, String value, pw.Font boldFont) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.end,
    children: [
      pw.Text(label, style: pw.TextStyle(fontSize: 10)),
      pw.Text(value, style: pw.TextStyle(fontSize: 11, font: boldFont)),
    ],
  );
}
