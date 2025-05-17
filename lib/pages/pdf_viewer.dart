import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class CustomPdfViewerPage extends StatefulWidget {
  final String pdfUrl;
  final String bookName;

  const CustomPdfViewerPage({required this.pdfUrl , required this.bookName});

  @override
  _CustomPdfViewerPageState createState() => _CustomPdfViewerPageState();
}

class _CustomPdfViewerPageState extends State<CustomPdfViewerPage> {
  String? localPath;
  bool fileDownloaded = false;
  bool errorOccurred = false;

  int totalPages = 0;
  int currentPage = 0;
  bool isPDFReady = false;

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
      ),
      body: fileDownloaded && localPath != null
          ? Stack(
        children: [
          PDFView(
            filePath: localPath!,
            autoSpacing: true,
            enableSwipe: true,
            swipeHorizontal: false,
            onViewCreated: (controller) {
            },
            onRender: (_pages) {
              setState(() {
                totalPages = _pages!;
                isPDFReady = true;
              });
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
          // Loading overlay until PDF is ready
          if (!isPDFReady)
            Container(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text("Loading PDF..."),
                  ],
                ),
              ),
            ),
          // Page-specific loading indicator
          if (isPDFReady)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  "Page ${currentPage + 1} of $totalPages",
                  style: TextStyle(color: Colors.black87),
                ),
              ),
            ),
        ],
      )
          : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text("Downloading PDF..."),
          ],
        ),
      ),
    );
  }
}