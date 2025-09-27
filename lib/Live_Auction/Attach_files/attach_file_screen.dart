import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:user_app/Live_Auction/Attach_files/document_submitted.dart';

class attach_file extends StatefulWidget {
  const attach_file({super.key});

  @override
  State<attach_file> createState() => _attach_fileState();
}

class _attach_fileState extends State<attach_file> {
  String? _bankStatementPath;
  String? _aadhaarPath;

  // BANK FUNCTIONS
  Future<void> _pickBankStatement() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg', 'doc', 'docx'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _bankStatementPath = result.files.single.path!;
      });
    }
  }

  Future<void> _viewBankStatement() async {
    if (_bankStatementPath != null) await OpenFilex.open(_bankStatementPath!);
  }

  void _deleteBankStatement() {
    setState(() {
      _bankStatementPath = null;
    });
  }

  // AADHAAR FUNCTIONS
  Future<void> _pickAadhaar() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg', 'doc', 'docx'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _aadhaarPath = result.files.single.path!;
      });
    }
  }

  Future<void> _viewAadhaar() async {
    if (_aadhaarPath != null) await OpenFilex.open(_aadhaarPath!);
  }

  void _deleteAadhaar() {
    setState(() {
      _aadhaarPath = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    bool isBankUploaded = _bankStatementPath != null;
    bool isAadhaarUploaded = _aadhaarPath != null;
    bool allUploaded = isBankUploaded && isAadhaarUploaded; // ✅ Check all

    return Scaffold(
      backgroundColor: const Color(0xff000000),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: size.height * 0.02),
                Text(
                  'Attach File',
                  style: GoogleFonts.urbanist(
                    textStyle: const TextStyle(
                      color: Color(0xffE2E2E2),
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.008),
                Text(
                  'Kindly share the requested details for verification.',
                  style: GoogleFonts.urbanist(
                    textStyle: const TextStyle(
                      color: Color(0xff6B6B6B),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.04),

                // BANK STATEMENT
                _buildDocumentRow(
                  size,
                  title: 'Bank Statement',
                  isUploaded: isBankUploaded,
                  onAdd: _pickBankStatement,
                  onView: _viewBankStatement,
                  onDelete: _deleteBankStatement,
                ),

                SizedBox(height: size.height * 0.04),

                // AADHAAR
                _buildDocumentRow(
                  size,
                  title: 'Aadhaar',
                  isUploaded: isAadhaarUploaded,
                  onAdd: _pickAadhaar,
                  onView: _viewAadhaar,
                  onDelete: _deleteAadhaar,
                ),

                // ✅ SINGLE CONTINUE BUTTON AT THE END
                if (allUploaded) _buildContinueButton(context, size),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Reusable Document Row
  Widget _buildDocumentRow(
      Size size, {
        required String title,
        required bool isUploaded,
        required VoidCallback onAdd,
        required VoidCallback onView,
        required VoidCallback onDelete,
      }) {
    return Container(
      width: double.infinity,
      height: 46,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(11),
        color: const Color(0xff171717),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
        child: Row(
          children: [
            Text(
              title,
              style: GoogleFonts.urbanist(
                textStyle: const TextStyle(
                  color: Color(0xffFFFFFF),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Spacer(),
            if (!isUploaded)
              GestureDetector(
                onTap: onAdd,
                child: Image.asset(
                  'assets/images/Live_Auction/add_document.png',
                  width: 20,
                  height: 20,
                ),
              ),
            if (isUploaded) ...[
              GestureDetector(
                onTap: onView,
                child: Image.asset(
                  'assets/images/Live_Auction/view_document.png',
                  width: 20,
                  height: 20,
                ),
              ),
              SizedBox(width: size.width * 0.03),
              GestureDetector(
                onTap: onDelete,
                child: Image.asset(
                  'assets/images/Live_Auction/delete.png',
                  width: 20,
                  height: 20,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Reusable Continue Button
  Widget _buildContinueButton(BuildContext context, Size size) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: size.height * 0.03),
      child: Align(
        alignment: Alignment.centerRight,
        child: SizedBox(
          width: 120,
          height: 37,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff585858),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const document_submited(),
                ),
              );
            },
            child: Text(
              'Continue',
              style: GoogleFonts.urbanist(
                textStyle: const TextStyle(
                  color: Color(0xffFFFFFF),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
