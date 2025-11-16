import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

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
      final Token = await SecureStorageService.getToken();
      final url = Uri.parse(
        "https://foxlchits.com/api/Auctionwinner/my-documents/$profileId",
      );
      print(url);
      final response = await http.get(url,headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $Token",
      },);

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        // ✅ Convert API data into model list
        final docs = data.map((e) => MyDocument.fromJson(e)).toList();

        // ✅ Normalize empty strings to null for safety
        // ✅ Normalize empty strings to null for safety (immutable model fix)
        final normalizedDocs = docs.map((d) {
          final normalizedPath = (d.documentPath != null && d.documentPath!.trim().isEmpty)
              ? null
              : d.documentPath;

          return MyDocument(
            id: d.id,
            documentTypeId: d.documentTypeId,
            documentType: d.documentType,
            documentPath: normalizedPath,
            status: d.status,
            uploadedAt: d.uploadedAt,
            verifiedAt: d.verifiedAt,
            approvals: d.approvals,   // ✅ KEEP ORIGINAL APPROVALS
          );
        }).toList();

        setState(() {
          _documents = normalizedDocs;
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
      builder: (_) =>
      const Center(child: CircularProgressIndicator(color: Colors.white)),
    );
    final Token = await SecureStorageService.getToken();
    try {
      final url = Uri.parse(
        "https://foxlchits.com/api/Auctionwinner/upload-document",
      );
      final request = http.MultipartRequest('POST', url,);

      request.fields['ProfileId'] = profileId;
      request.fields['DocumentTypeId'] = documentTypeId;
      request.files.add(await http.MultipartFile.fromPath('File', filePath));
      request.headers.addAll({
        "Authorization": "Bearer $Token",
      });

      final response = await request.send();
      Navigator.pop(context);

      final responseBody = await response.stream.bytesToString();
      print("📥 Upload Response (${response.statusCode}): $responseBody");

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ File uploaded successfully")),
        );
        await _fetchDocumentsFromServer(); // refresh
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Upload failed: ${response.statusCode}"),
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      print("⚠️ Upload error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Upload failed, please try again")),
      );
    }
  }

  /// 🧾 Pick file and upload
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
        documentTypeId: doc.documentTypeId,
      );
    }
  }

  /// 👁️ View uploaded file
  Future<void> _viewFile(MyDocument doc) async {
    if (doc.documentPath != null && doc.documentPath!.isNotEmpty) {
      try {
        final Token = await SecureStorageService.getToken();
        final url = "https://foxlchits.com${doc.documentPath}";
        final uri = Uri.parse(url);
        final response = await http.get(uri,headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $Token",
        },);

        if (response.statusCode == 200) {
          final dir = await getTemporaryDirectory();
          final fileName = path.basename(uri.path);
          final file = File("${dir.path}/$fileName");
          await file.writeAsBytes(response.bodyBytes);
          await OpenFilex.open(file.path);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to open file.")),
          );
        }
      } catch (e) {
        print("⚠️ View file error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error opening file.")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No file for ${doc.documentType}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    // ✅ Continue button only when all docs uploaded
    bool allUploaded = _documents.isNotEmpty &&
        _documents.every((d) => d.documentPath != null && d.documentPath!.isNotEmpty);

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
                    color: const Color(0xffE2E2E2),
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: size.height * 0.008),
                Text(
                  'Kindly share the requested details for verification.',
                  style: GoogleFonts.urbanist(
                    color: const Color(0xff6B6B6B),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: size.height * 0.04),

                // 🔁 Build document rows
                ..._documents.map((doc) {
                  final isUploaded = doc.documentPath != null && doc.documentPath!.isNotEmpty;
                  return Padding(
                    padding: EdgeInsets.only(bottom: size.height * 0.03),
                    child: _buildDocumentRow(
                      size,
                      title: doc.documentType,
                      isUploaded: isUploaded,
                      onAdd: () => _pickFile(doc),
                      onView: () => _viewFile(doc),
                      status: doc.approvals.any((a) => a.isApproved) ? "Verified" : doc.status,
                    ),
                  );
                }).toList(),

                if (allUploaded) _buildContinueButton(context, size),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentRow(
      Size size, {
        required String title,
        required bool isUploaded,
        required VoidCallback onAdd,
        required VoidCallback onView,
        String? status,
      }) {
    return Container(
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
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
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
            if (isUploaded)
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
              MaterialPageRoute(builder: (_) => const document_submited()),
            );
          },
          child: Text(
            'Continue',
            style: GoogleFonts.urbanist(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
