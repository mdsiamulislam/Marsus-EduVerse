import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import '../pages/pdf_viewer.dart';


Future<void> downloadAndOpenPdf(BuildContext context, String url, String filename) async {
  final dir = await getApplicationDocumentsDirectory();
  final filePath = '${dir.path}/$filename';
  final file = File(filePath);
  Dio dio = Dio();

  double progress = 0;
  late void Function(void Function()) updateDialog;

  // Show progress dialog
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          updateDialog = setState; // Store setState to call from outside
          return AlertDialog(
            title: Text("📥 Downloading Book..."),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LinearProgressIndicator(value: progress),
                SizedBox(height: 12),
                Text('${(progress * 100).toStringAsFixed(0)}% completed'),
              ],
            ),
          );
        },
      );
    },
  );

  try {
    await dio.download(
      url,
      filePath,
      deleteOnError: true,
      onReceiveProgress: (received, total) {
        if (total != -1) {
          progress = received / total;
          updateDialog(() {}); // Safely update the dialog's UI
        }
      },
    );

    Navigator.pop(context); // Close dialog

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SfPdfViewers(pdfUrl: file.path),
      ),
    );
  } catch (e) {
    Navigator.pop(context); // Close dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("❌ Download failed: ${e.toString()}")),
    );
  }
}
