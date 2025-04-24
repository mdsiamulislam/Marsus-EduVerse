import 'package:flutter/material.dart';
import '../const/list_of_content.dart';
import '../helper/download_and_open_pdf.dart';

class BookLibraryTab extends StatefulWidget {
  @override
  _BookLibraryTabState createState() => _BookLibraryTabState();
}

class _BookLibraryTabState extends State<BookLibraryTab> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredBooks = BookList.where((book) {
      final title = book['title']!.toLowerCase();
      final author = (book['author'] ?? '').toLowerCase();
      return title.contains(_searchQuery.toLowerCase()) || author.contains(_searchQuery.toLowerCase());
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Search books or authors...',
              prefixIcon: Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Expanded(
          child: filteredBooks.isEmpty
              ? Center(child: Text("No books found.", style: TextStyle(fontSize: 16)))
              : GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredBooks.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemBuilder: (context, index) {
              final book = filteredBooks[index];
              final image = book['image'];
              final title = book['title']!;
              final author = book['author'] ?? 'Unknown Author';
              final pdfUrl = book['link']!;
              final filename = 'book_$index.pdf';

              return Material(
                color: Colors.white,
                elevation: 4,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => downloadAndOpenPdf(context, pdfUrl, filename),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          child: image != null && image.contains('http')
                              ? FadeInImage.assetNetwork(
                            placeholder: 'assets/images/placeholder.png',
                            image: image,
                            fit: BoxFit.cover,
                            imageErrorBuilder: (_, __, ___) => Icon(Icons.broken_image, size: 60),
                          )
                              : image != null
                              ? Image.asset(
                            image,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(Icons.broken_image, size: 60),
                          )
                              : Icon(Icons.broken_image, size: 60),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              author,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
