import 'dart:io';

import 'package:flutter/material.dart';
import '../helper/download_and_open_pdf.dart';
import '../utils/data_manager.dart';

class BookLibraryTab extends StatefulWidget {
  const BookLibraryTab({super.key});

  @override
  _BookLibraryTabState createState() => _BookLibraryTabState();
}

class _BookLibraryTabState extends State<BookLibraryTab> {
  String _searchQuery = '';
  bool _isLoading = true;
  List<Map<String, dynamic>> _filteredBooks = [];


  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    setState(() => _isLoading = true);
    await DataManager.checkAndUpdateData(context);
    await Future.delayed(const Duration(milliseconds: 200));
    _updateFilteredBooks();
    setState(() => _isLoading = false);
  }

  void _updateFilteredBooks() {
    final query = _searchQuery.toLowerCase();
    _filteredBooks = BookList.where((book) {
      final title = (book['title'] ?? '').toString().toLowerCase();
      final author = (book['author'] ?? '').toString().toLowerCase();
      return title.contains(query) || author.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(),
        Expanded(
          // UniversalShimmer বাদ দেওয়া হয়েছে
          child: _isLoading
              ? Center(child: CircularProgressIndicator()) // লোডিং ইন্ডিকেটর
              : _filteredBooks.isEmpty
              ? _buildEmptyState()
              : _buildBookGrid(_filteredBooks),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
            _updateFilteredBooks();
          });
        },
        decoration: InputDecoration(
          hintText: 'Search books or authors...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Text(
          'No books found.\nTry searching with a different keyword.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ),
    );
  }


  Widget _buildBookGrid(List<Map<String, dynamic>> books) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: books.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemBuilder: (context, index) {
        final book = books[index];
        return Material(
          color: Colors.white,
          elevation: 4,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => downloadAndOpenPdf(
              context,
              book['link'] ?? '',
              'book_$index.pdf',
              book['title'] ?? 'Book',
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _buildBookImage(book['image'])),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book['title'] ?? 'Untitled',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        book['author'] ?? 'Unknown Author',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBookImage(String? url) {
    if (url == null || url.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: const Icon(Icons.book, size: 64, color: Colors.grey),
      );
    }

    final isNetworkImage = url.startsWith('http');

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: isNetworkImage
          ? Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: Colors.grey[200],
          child: const Icon(Icons.broken_image, size: 64, color: Colors.grey),
        ),
      )
          : Image.file(
        File(url),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: Colors.grey[200],
          child: const Icon(Icons.broken_image, size: 64, color: Colors.grey),
        ),
      ),
    );
  }

}
