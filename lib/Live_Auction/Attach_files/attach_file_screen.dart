import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:http/http.dart' as http;
import 'package:user_app/Live_Auction/Attach_files/document_submitted.dart';
import '../../Models/Live_Auction/my_document_model.dart';
import '../../Services/secure_storage.dart';

class attach_file extends StatefulWidget {
  const attach_file({super.key});

  @override
  State<attach_file> createState() => _attach_fileState();
}

class _attach_fileState extends State<attach_file> {
  bool _isLoading = true;
  List<MyDocument> _documents = [];

  @override
  void initState() {
    super.initState();
    _fetchDocumentsFromServer();
  }

  /// ✅ Fetch documents list from server (GET)
  Future<void> _fetchDocumentsFromServer() async {
    try {
      final profileId = await SecureStorageService.getProfileId();
      if (profileId == null) {
        print("⚠️ No profileId found in SecureStorage");
        setState(() => _isLoading = false);
        return;
      }

      final url = Uri.parse(
          "https://foxlchits.com/api/Auctionwinner/my-documents/$profileId");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          _documents = data.map((e) => MyDocument.fromJson(e)).toList();
          _isLoading = false;
        });
      } else {
        print("❌ Failed to fetch documents: ${response.statusCode}");
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print("⚠️ Error fetching documents: $e");
      setState(() => _isLoading = false);
    }
  }

  /// ✅ Upload document (POST)
  Future<void> _uploadDocument({
    required String filePath,
    required String documentTypeId,
  }) async {
    final profileId = await SecureStorageService.getProfileId();
    if (profileId == null || profileId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile ID not found")),
      );
      return;
    }

    final file = File(filePath);
    if (!file.existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("File not found")),
      );
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );

    try {
      final url = Uri.parse("https://foxlchits.com/api/Auctionwinner/upload-document");
      final request = http.MultipartRequest('POST', url);

      // Required fields
      request.fields['ProfileId'] = profileId;
      request.fields['DocumentTypeId'] = documentTypeId;

      // Attach file
      request.files.add(await http.MultipartFile.fromPath('File', filePath));

      // Optional headers (multipart handled automatically)
      request.headers.addAll({
        "Accept": "application/json",
      });

      print("📤 Uploading:");
      print("➡️ ProfileId: $profileId");
      print("➡️ DocumentTypeId: $documentTypeId");
      print("➡️ File: ${file.path}");

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print("📥 Server response (${response.statusCode}): $responseBody");

      Navigator.pop(context); // close loader

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ File uploaded successfully")),
        );
        await _fetchDocumentsFromServer(); // refresh data
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "❌ Upload failed (Code: ${response.statusCode})",
            ),
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // close loader
      print("⚠️ Upload error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Upload failed, please try again")),
      );
    }
  }


  /// 🧾 Pick a file and upload for a specific document type
  Future<void> _pickFile(MyDocument doc) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg', 'doc', 'docx'],
    );

    if (result != null && result.files.single.path != null) {
      final filePath = result.files.single.path!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Uploading ${doc.documentType}...")),
      );
      await _uploadDocument(
        filePath: filePath,
        documentTypeId: doc.id,
      );
    }
  }

  /// 👁️ View file if available
  Future<void> _viewFile(MyDocument doc) async {
    if (doc.documentPath != null) {
      final url = "https://foxlchits.com${doc.documentPath}";
      await OpenFilex.open(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No file uploaded for ${doc.documentType}")),
      );
    }
  }

  /// ❌ Delete from UI (optional)
  void _deleteFile(MyDocument doc) {
    setState(() {
      _documents = _documents.map((d) {
        if (d.id == doc.id) {
          return MyDocument(
            id: d.id,
            documentType: d.documentType,
            documentPath: null, // mark deleted
            status: "Pending",
            uploadedAt: d.uploadedAt,
            verifiedAt: d.verifiedAt,
          );
        }
        return d;
      }).toList();
    });
  }


  // ====================== UI (unchanged structure) ======================
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool allUploaded =
        _documents.isNotEmpty && _documents.every((d) => d.documentPath != null);

    return Scaffold(
      backgroundColor: const Color(0xff000000),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : SingleChildScrollView(
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

                // 🔁 Build all document rows dynamically
                ..._documents.map((doc) => Padding(
                  padding: EdgeInsets.only(bottom: size.height * 0.03),
                  child: _buildDocumentRow(
                    size,
                    title: doc.documentType,
                    isUploaded: doc.documentPath != null,
                    onAdd: () => _pickFile(doc),
                    onView: () => _viewFile(doc),
                    onDelete: () => _deleteFile(doc),
                    status: doc.status,
                  ),
                )),

                // Continue button
                if (allUploaded) _buildContinueButton(context, size),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ Reusable document row (UI stays same)
  Widget _buildDocumentRow(
      Size size, {
        required String title,
        required bool isUploaded,
        required VoidCallback onAdd,
        required VoidCallback onView,
        required VoidCallback onDelete,
        String? status,
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
              if (status == "Verified") ...[
                SizedBox(width: size.width * 0.02),
                const Icon(Icons.check_circle, color: Colors.green, size: 18),
              ],
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