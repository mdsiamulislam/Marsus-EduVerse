import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutDialogPopup extends StatelessWidget {
  const AboutDialogPopup({super.key});

  Future<void> _resetAppData(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      final dir = await getApplicationDocumentsDirectory();
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }

      AnimatedSnackBar.material(
        'App data cleared successfully',
        type: AnimatedSnackBarType.success,
        duration: const Duration(seconds: 3),
        mobileSnackBarPosition: MobileSnackBarPosition.bottom,
      ).show(context);
    } catch (e) {
      AnimatedSnackBar.material(
        "Failed to clear data: $e",
        type: AnimatedSnackBarType.error,
        duration: const Duration(seconds: 4),
        mobileSnackBarPosition: MobileSnackBarPosition.bottom,
      ).show(context);
    }
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      AnimatedSnackBar.material(
        "Invalid URL",
        type: AnimatedSnackBarType.error,
        duration: const Duration(seconds: 3),
        mobileSnackBarPosition: MobileSnackBarPosition.bottom,
      ).show(context);
      return;
    }
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      AnimatedSnackBar.material(
        "Could not launch URL",
        type: AnimatedSnackBarType.error,
        duration: const Duration(seconds: 3),
        mobileSnackBarPosition: MobileSnackBarPosition.bottom,
      ).show(context);
    }
  }

  Widget _linkText(BuildContext context, String text, String url) {
    return GestureDetector(
      onTap: () => _launchUrl(context, url),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.blue,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const titleStyle = TextStyle(color: Colors.green);
    const boldStyle = TextStyle(fontWeight: FontWeight.bold);

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: const [
          Icon(Icons.info_outline, color: Colors.green),
          SizedBox(width: 8),
          Text("About", style: titleStyle),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "This app helps you access Islamic comics and lecture videos, mainly from Marsus Ustad and IOM (Islamic Online Madrasah).",
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            const Text("📌 How to Use", style: boldStyle),
            const SizedBox(height: 8),
            const Text("• Use the Home screen to navigate to Comics, Lectures"),
            const Text("• Use the search bar to quickly find content by keywords or tags."),
            const Text("• All Books and Video are shown dynamically from the cloud. So stay connected with internet."),
            const Text("• You can also download the book for offline access."),
            const SizedBox(height: 16),
            const Text("🔗 Quick Links", style: boldStyle),
            const SizedBox(height: 8),
            _linkText(context, "✍️ Author: Engr. Khandaker Marsus", "https://marsus.com.bd/videos-2/"),
            const SizedBox(height: 4),
            _linkText(context, "</> Developer: Md Siamul Islam Soaib", "https://github.com/mdsiamulislam"),
            const SizedBox(height: 4),
            _linkText(context, "🌐 IOM: Islamic Online Madrasah", "http://iom.edu.bd/"),
            const SizedBox(height: 4),
            _linkText(context, "🔏 Privacy & Policy", "https://marsus.com.bd/marsus-eduverse-privacy-policy"),
            const SizedBox(height: 20),
            const Text(
              "© 2025 Marsus EduVerse. All rights reserved.",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Close"),
        ),
        TextButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Row(
                  children: [
                    const Icon(Icons.warning_amber_outlined, color: Colors.red),
                    const SizedBox(width: 8),
                    const Text("Warning", style: TextStyle(color: Colors.red)),
                  ],
                ),
                content: const Text(
                  "This will delete all your app data. Do you want to proceed?",
                  style: TextStyle(fontSize: 14),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600),
                    onPressed: () async {
                      Navigator.pop(context); // Close warning dialog
                      await _resetAppData(context);
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                    child: const Text(
                      "Yes, Reset",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          },
          child: const Text("Hard Reset"),
        ),
      ],
    );
  }
}
