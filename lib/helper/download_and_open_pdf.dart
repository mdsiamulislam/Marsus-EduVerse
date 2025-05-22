import 'dart:io';
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

  // ✅ যদি ফাইল থাকে এবং URL পরিবর্তিত হয়
  if (await file.exists()) {
    if (savedUrl != null && savedUrl != url) {
      await file.delete();
    }
  }

  // ✅ আবার চেক করো ফাইল এখনো আছে কিনা (ডিলিট না হলে)
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
      await prefs.setString(storedUrlKey, url); // 🔐 নতুন URL সংরক্ষণ করো
      Navigator.pop(context);
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
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Download failed: ${e.toString()}")),
      );
    }
  }
}
