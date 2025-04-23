import 'dart:io';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class SfPdfViewers extends StatefulWidget {
  final String pdfUrl;

  const SfPdfViewers({required this.pdfUrl});

  @override
  State<SfPdfViewers> createState() => _SfPdfViewersState();
}

class _SfPdfViewersState extends State<SfPdfViewers> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 300), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLocal = widget.pdfUrl.startsWith('/');

    return Scaffold(
      appBar: AppBar(title: Text('📖 PDF Viewer')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : isLocal
          ? SfPdfViewer.file(File(widget.pdfUrl))
          : SfPdfViewer.network(widget.pdfUrl),
    );
  }
}
