import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:open_file/open_file.dart';

class CustomPdfViewerPage extends StatefulWidget {
  final String pdfUrl;
  final String bookName;

  const CustomPdfViewerPage({required this.pdfUrl, required this.bookName});

  @override
  _CustomPdfViewerPageState createState() => _CustomPdfViewerPageState();
}

class _CustomPdfViewerPageState extends State<CustomPdfViewerPage> {
  String? localPath;
  bool fileDownloaded = false;
  bool errorOccurred = false;
  bool isPDFReady = false;
  bool isDarkMode = false;

  int totalPages = 0;
  int currentPage = 0;
  late PDFViewController pdfController;

  @override
  void initState() {
    super.initState();
    loadPdf();
  }

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
      setState(() {
        errorOccurred = true;
      });
    }
  }

  void _showJumpToPageDialog() {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Jump to Page"),
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
                setState(() {
                  currentPage = page - 1;
                });
              }
            },
            child: Text("Go"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (errorOccurred) {
      return Scaffold(
        appBar: AppBar(title: Text('Error')),
        body: Center(child: Text('❌ Failed to load PDF')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bookName),
        actions: [
          IconButton(
            icon: Icon(Icons.find_in_page), // Jump to Page
            tooltip: "Jump to Page",
            onPressed: _showJumpToPageDialog,
          ),
        ],
      ),
      body: fileDownloaded && localPath != null
          ? Stack(
        children: [
          PDFView(
            filePath: localPath!,
            enableSwipe: true,
            swipeHorizontal: false,
            autoSpacing: false, // reduce margin
            pageSnap: true,
            fitEachPage: false,
            nightMode: isDarkMode,
            onRender: (_pages) {
              setState(() {
                totalPages = _pages!;
                isPDFReady = true;
              });
            },
            onViewCreated: (controller) {
              pdfController = controller;
            },
            onPageChanged: (current, total) {
              setState(() {
                currentPage = current!;
              });
            },
            onError: (error) {
              print("PDF Render Error: $error");
              setState(() {
                errorOccurred = true;
              });
            },
          ),
          if (!isPDFReady)
            Container(
              color: Colors.white,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          if (isPDFReady)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                children: [
                  Slider(
                    value: currentPage.toDouble(),
                    min: 0,
                    max: (totalPages - 1).toDouble(),
                    onChanged: (value) async {
                      await pdfController.setPage(value.toInt());
                      setState(() {
                        currentPage = value.toInt();
                      });
                    },
                  ),
                  Text(
                    "Page ${currentPage + 1} of $totalPages",
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
