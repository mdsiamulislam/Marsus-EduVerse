import 'dart:io';
import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/pdf_viewer.dart';

Future<void> downloadAndOpenPdf(
    BuildContext context, String url, String filename, String title) async {
  final dir = await getApplicationDocumentsDirectory();
  final filePath = '${dir.path}/$filename';
  final file = File(filePath);
  final dio = Dio();
  final prefs = await SharedPreferences.getInstance();
  final storedUrlKey = 'pdf_url_$filename';

  final savedUrl = prefs.getString(storedUrlKey);

  // If file exists but URL has changed, delete the file
  if (await file.exists()) {
    if (savedUrl != null && savedUrl != url) {
      await file.delete();
    }
  }

  // If file still exists, open it directly
  if (await file.exists()) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CustomPdfViewerPage(
          pdfUrl: file.path,
          bookName: title,
        ),
      ),
    );
    return;
  }

  double progress = 0;
  bool isCancelled = false;
  late CancelToken cancelToken;
  late void Function(void Function()) updateDialog;

  cancelToken = CancelToken();

  // Show downloading dialog with progress
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          updateDialog = setState;
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.download_outlined, color: Colors.blue), // your icon
                SizedBox(width: 8),
                Text("Downloading..."),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LinearProgressIndicator(value: progress),
                SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.cloud_download_outlined,
                      color: Colors.blue,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      "${(progress * 100).toStringAsFixed(0)}%",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                )
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  isCancelled = true;
                  cancelToken.cancel();
                  Navigator.of(context).pop();
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
      await prefs.setString(storedUrlKey, url); // Save new URL
      Navigator.pop(context); // Close download dialog
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CustomPdfViewerPage(
            pdfUrl: file.path,
            bookName: title,
          ),
        ),
      );
    }
  } catch (e) {
    if (!isCancelled) {
      Navigator.pop(context); // Close download dialog on error

      // Log error for developer
      print("❌ Download failed: ${e.toString()}");

      // Show floating error snackbar to user
      AnimatedSnackBar.material(
        'This file is not available for download. Please try again later.',
        type: AnimatedSnackBarType.error,
        duration: Duration(seconds: 6),
        mobileSnackBarPosition: MobileSnackBarPosition.bottom,
      ).show(context);
    }
  }
}
