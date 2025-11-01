import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class CustomPdfViewerPage extends StatefulWidget {
  final String pdfUrl;
  final String bookName;

  const CustomPdfViewerPage({
    required this.pdfUrl,
    required this.bookName,
    super.key,
  });

  @override
  _CustomPdfViewerPageState createState() => _CustomPdfViewerPageState();
}

class _CustomPdfViewerPageState extends State<CustomPdfViewerPage> {
  String? localPath;
  bool fileDownloaded = false;
  bool errorOccurred = false;
  bool isPDFReady = false;

  int totalPages = 0;
  int currentPage = 0;
  late PDFViewController pdfController;

  @override
  void initState() {
    super.initState();
    loadPdf();
  }

  @override
  void dispose() {
    super.dispose();
  }


  /// Download or load cached PDF
  Future<void> loadPdf() async {
    try {
      final filename = widget.pdfUrl.split('/').last;
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$filename');

      if (await file.exists()) {
        setState(() {
          localPath = file.path;
          fileDownloaded = true;
        });
      } else {
        final response = await Dio().download(widget.pdfUrl, file.path);
        if (response.statusCode == 200) {
          setState(() {
            localPath = file.path;
            fileDownloaded = true;
          });
        } else {
          throw Exception("Download failed");
        }
      }
    } catch (e) {
      print('PDF Load Error: $e');
      setState(() => errorOccurred = true);
    }
  }

  /// Jump to a specific page
  void _showJumpToPageDialog() {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Jump to Page"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: "Enter page number (1 - $totalPages)",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              int? page = int.tryParse(controller.text);
              if (page != null && page > 0 && page <= totalPages) {
                Navigator.of(context).pop();
                await pdfController.setPage(page - 1);
                setState(() => currentPage = page - 1);
              }
            },
            child: const Text("Go"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (errorOccurred) {
      return const Scaffold(
        body: Center(child: Text('❌ Failed to load PDF')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bookName),
        centerTitle: true,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.find_in_page,
                color: Colors.green),
            onPressed: _showJumpToPageDialog,
          ),
        ],
      ),
      body: fileDownloaded && localPath != null
          ? Stack(
        children: [
          /// The PDF Viewer
          PDFView(
            filePath: localPath!,
            enableSwipe: true,
            swipeHorizontal: true, // horizontal scroll
            autoSpacing: true, // smoother scroll
            pageSnap: false, // continuous scrolling
            fitEachPage: true,
            onRender: (_pages) {
              setState(() {
                totalPages = _pages!;
                isPDFReady = true;
              });
            },
            onViewCreated: (controller) => pdfController = controller,
            onPageChanged: (current, total) {
              setState(() => currentPage = current!);
            },
            onError: (error) {
              print("PDF Render Error: $error");
              setState(() => errorOccurred = true);
            },
          ),

          /// Loading overlay
          if (!isPDFReady)
            Container(
              color: Colors.white,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),

          /// Bottom overlay controls
          if (isPDFReady)
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: Column(
                children: [
                  Slider(
                    value: currentPage.toDouble(),
                    min: 0,
                    max: (totalPages - 1).toDouble(),
                    activeColor: Colors.green,
                    onChanged: (value) async {
                      await pdfController.setPage(value.toInt());
                      setState(() => currentPage = value.toInt());
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Page ${currentPage + 1} of $totalPages",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                    ],
                  ),
                ],
              ),
            ),
        ],
      )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
