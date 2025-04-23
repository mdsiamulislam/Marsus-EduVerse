import 'package:flutter/material.dart';
import 'package:untitled/const/list_of_content.dart';

import '../pages/pdf_viewer.dart';

// 📚 বই ট্যাব
class BookLibraryTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(12),
      itemCount: BookList.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            // Create navigation to SfPdfViewers page with the PDF link from BookList
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SfPdfViewers(
                  pdfUrl: BookList[index]['link']!,
                ),
              ),
            );
          },
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                Expanded(
                  child: BookList[index]['image'] != null
                      ? Image.asset(BookList[index]['image']!, fit: BoxFit.cover)
                      : Icon(Icons.broken_image),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    BookList[index]['title']!,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}