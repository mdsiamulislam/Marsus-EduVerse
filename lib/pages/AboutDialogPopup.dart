import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';


class AboutDialogPopup extends StatelessWidget {
  const AboutDialogPopup({super.key});

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
      ],
    );
  }
}
