import 'package:flutter/material.dart';
import 'package:untitled/const/list_of_content.dart';

import '../helper/download_and_open_pdf.dart';

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
            String pdfUrl = BookList[index]['link']!;
            String filename = 'book_$index.pdf';
            downloadAndOpenPdf(context, pdfUrl, filename);
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
