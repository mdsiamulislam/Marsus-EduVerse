import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import '../pages/pdf_viewer.dart';

Future<void> downloadAndOpenPdf(BuildContext context, String url, String filename, String title) async {
  final dir = await getApplicationDocumentsDirectory();
  final filePath = '${dir.path}/$filename';
  final file = File(filePath);
  final dio = Dio();

  // Check if already downloaded
  if (await file.exists()) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CustomPdfViewerPage(
          pdfUrl: file.path,
        bookName: title,
      )),
    );
    return;
  }

  double progress = 0;
  bool isCancelled = false;
  late CancelToken cancelToken;
  late void Function(void Function()) updateDialog;

  cancelToken = CancelToken();

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          updateDialog = setState;
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
            actions: [
              TextButton(
                onPressed: () {
                  isCancelled = true;
                  cancelToken.cancel();
                  Navigator.of(context).pop(); // Close dialog
                },
                child: Text("Cancel"),
              )
            ],
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
      cancelToken: cancelToken,
      onReceiveProgress: (received, total) {
        if (total != -1) {
          progress = received / total;
          updateDialog(() {});
        }
      },
    );

    if (!isCancelled) {
      Navigator.pop(context); // Close dialog
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CustomPdfViewerPage(pdfUrl: file.path,
            bookName: title,
        )),
      );
    }
  } catch (e) {
    if (!isCancelled) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Download failed: ${e.toString()}")),
      );
    }
  }
}
