import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class SfPdfViewers extends StatefulWidget {
  final String pdfUrl;

  const SfPdfViewers({super.key, required this.pdfUrl});

  @override
  State<SfPdfViewers> createState() => _SfPdfViewersState();
}

class _SfPdfViewersState extends State<SfPdfViewers> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // You can preload or setup here if needed
  }

  void _reloadPdf() {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📖 PDF Reader'),
        centerTitle: true,
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reloadPdf,
            tooltip: "Reload PDF",
          ),
          IconButton(
            icon: const Icon(Icons.zoom_in),
            tooltip: "Zoom to page 2",
            onPressed: () {
              // _pdfViewerKey.currentState?.jumpToPage(2);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _reloadPdf();
        },
        child: Stack(
          children: [
            if (!_hasError)
              SfPdfViewer.network(
                widget.pdfUrl,
                key: _pdfViewerKey,
                onDocumentLoaded: (details) {
                  setState(() {
                    _isLoading = false;
                  });
                },
                onDocumentLoadFailed: (error) {
                  setState(() {
                    _isLoading = false;
                    _hasError = true;
                    _errorMessage = error.description;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to load PDF: ${error.description}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
              ),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(color: Colors.green),
              ),
            if (_hasError && _errorMessage != null)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 60),
                    const SizedBox(height: 16),
                    Text(
                      'Oops! Couldn\'t load the PDF.',
                      style: TextStyle(color: Colors.grey[700], fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.redAccent),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _reloadPdf,
                      icon: const Icon(Icons.refresh),
                      label: const Text("Try Again"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    )
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
