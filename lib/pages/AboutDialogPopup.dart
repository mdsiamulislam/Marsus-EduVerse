import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';


class AboutDialogPopup extends StatelessWidget {
  const AboutDialogPopup({super.key});

  Future<void> _resetAppData(BuildContext context) async {
    try {
      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Delete all files from app's document directory
      final dir = await getApplicationDocumentsDirectory();
      if (await dir.exists()) {
        dir.deleteSync(recursive: true);
      }

      // Optional: show confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ App data cleared successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to clear data: $e")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: const [
          Icon(Icons.info_outline, color: Colors.green),
          SizedBox(width: 8),
          Text("About", style: TextStyle(color: Colors.green)),
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
            const Text(
              "📌 How to Use",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text("• Use the Home screen to navigate to Comics, Lectures"),
            const Text("• Use the search bar to quickly find content by keywords or tags."),
            const Text("• All Books and Video are shown dynamically from the cloud.So stay connected with internet ."),
            const Text("• You can also download the book for offline access."),
            const SizedBox(height: 16),
            const Text(
              "🔗 Quick Links",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                launchUrl(Uri.parse("https://marsus.com.bd/videos-2/"));
              },
              child: const Text(
                "✍️ Author: Engr. Khandaker Marsus",
                style: TextStyle(
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () {
                launchUrl(Uri.parse("https://github.com/mdsiamulislam"));
              },
              child: const Text(
                "</> Developer: Md Siamul Islam Soaib",
                style: TextStyle(
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () {
                launchUrl(Uri.parse("http://iom.edu.bd/"));
              },
              child: const Text(
                "🌐 IOM: Islamic Online Madrasah",
                style: TextStyle(
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () {
                launchUrl(Uri.parse("https://marsus.com.bd/marsus-eduverse-privacy-policy"));
              },
              child: const Text(
                "🔏 Privacy & Policy",
                style: TextStyle(
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "© 2025 Marsus EduVerse. All rights reserved.",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
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
          onPressed: (){
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("⚠️ Confirm Reset"),
                content: const Text("Are you sure ? You want to delete all app data?"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _resetAppData(context);
                    },
                    child: const Text("Yes, Reset",
                      style: TextStyle(color: Colors.white),),
                  ),
                ],
              ),
            );
          },
          child: const Text("Hard Reset"),
        ),
        // Hard Reset Button that clear all app data
      ],
    );
  }
}
