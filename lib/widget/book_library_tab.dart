import 'dart:io';
import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:lottie/lottie.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helper/download_and_open_pdf.dart';
import '../utils/data_manager.dart';

class BookLibraryTab extends StatefulWidget {
  final bool hasInternet;
  const BookLibraryTab({super.key, required this.hasInternet});

  @override
  _BookLibraryTabState createState() => _BookLibraryTabState();
}

class _BookLibraryTabState extends State<BookLibraryTab> {
  String _searchQuery = '';
  bool _isLoading = true;
  List<Map<String, dynamic>> _filteredBooks = [];
  late bool _hasInternet;

  @override
  void initState() {
    super.initState();
    _hasInternet = widget.hasInternet;
    _initialize();
  }

  Future<void> _initialize() async {
    await _checkConnectivity();
    await _loadData();
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _hasInternet = connectivityResult != ConnectivityResult.none;
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await DataManager.loadDataFromDevice(context);
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
  void didUpdateWidget(BookLibraryTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hasInternet != widget.hasInternet) {
      // কানেকশন স্টেট চেঞ্জ হলে ডেটা রিলোড করুন
      _hasInternet = widget.hasInternet;
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredBooks.isEmpty
              ? _buildEmptyState(
                  context,
          )
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

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24.0),
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/empty.json', // Replace with your Lottie file
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 20),
            Text(
              'No Books Found',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.green[800],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'We couldn\'t find any books matching your search.\nTry these suggestions:',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.4,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 20),
            _buildSuggestionItem(Icons.search, 'Try different keywords'),
            _buildSuggestionItem(Icons.wifi, 'Check internet connection'),
            _buildSuggestionItem(Icons.refresh, 'Refresh the page'),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // আপনার থিম অনুযায়ী কালার
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                            title: const Text('Confirm Clear Data'),
                            content: const Text('This will erase all app data and reset to initial state. Are you sure?'),
                            actions: [
                            TextButton(
                            onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                    ),
                    TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Confirm', style: TextStyle(color: Colors.red)),
                    ),
                    ]
                    ));

                    if (confirmed == true) {
                      AnimatedSnackBar.material(
                        'Clearing app data...',
                        type: AnimatedSnackBarType.info,
                        duration: const Duration(seconds: 3),
                        mobileSnackBarPosition: MobileSnackBarPosition.bottom,
                      ).show(context);

                    try {
                    // শেয়ার্ড প্রেফারেন্স ক্লিয়ার করুন
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.clear();


                    // অ্যাপ রিস্টার্ট করার পরামর্শ দিন
                    if (mounted) {
                      AnimatedSnackBar.material(
                        'App data cleared. Please restart the app',
                        type: AnimatedSnackBarType.success,
                        duration: const Duration(seconds: 3),
                        mobileSnackBarPosition: MobileSnackBarPosition.bottom,
                      ).show(context);
                    }
                    } catch (e) {
                    if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error clearing data: ${e.toString()}')),
                    );
                    }
                    }
                    }
                  },
                  child: const Text('Clear App Data'),
                ),
                const SizedBox(width: 16),
                // Button for troubleshoot
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green,
                    side: const BorderSide(color: Colors.green),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => _showTroubleshootDialog(context),
                  child: const Text('Troubleshoot'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: Colors.green[600]),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showTroubleshootDialog(BuildContext context) async {
    final packageInfo = await PackageInfo.fromPlatform();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Troubleshooting Guide'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStepItem('1. Check Internet Connection', Icons.wifi),
              const SizedBox(height: 8),
              _buildStepItem('2. Clear App Data', Icons.delete),
              const SizedBox(height: 8),
              _buildStepItem('3. Reinstall App (v${packageInfo.version})', Icons.replay),
              const SizedBox(height: 16),
              const Text(
                'Still having issues ? Contact support at :',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SelectableText('info@iom.edu.bd'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blue),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
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
    final borderRadius = const BorderRadius.vertical(top: Radius.circular(16));

    Widget fallbackIcon(IconData icon) => Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: borderRadius,
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 64, color: Colors.grey),
    );

    if (url == null || url.isEmpty) return fallbackIcon(Icons.book);

    final isNetworkImage = url.startsWith('https') || url.startsWith('http') || url.startsWith('www') || url.startsWith('http://') || url.startsWith('https://') ;

    if (isNetworkImage && _hasInternet) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: Image.network(
          url,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Container(
              color: Colors.grey[100],
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            );
          },
          errorBuilder: (_, __, ___) => fallbackIcon(Icons.broken_image),
        ),
      );
    } else if (!isNetworkImage) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: Image.file(
          File(url),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => fallbackIcon(Icons.broken_image),
        ),
      );
    } else {
      return fallbackIcon(Icons.cloud_off);
    }
  }
}
