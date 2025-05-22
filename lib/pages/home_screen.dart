import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart';

import '../widget/BookLibraryTab.dart';
import '../widget/LectureTab.dart';
import '../widget/BlogTab.dart';
import 'AboutDialogPopup.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  bool _isLoading = true;

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    // Simulate network delay or data fetching
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);
  }


  @override
  void initState() {
    super.initState();
    _loadData();
  }

  List<Widget> _buildTabs() => [
    BookLibraryTab(),
    LectureTab(),
    Blogtab()
  ];

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      dialogStyle: UpgradeDialogStyle.material,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Marsus EduVerse',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.green,
          elevation: 6,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.white),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const AboutDialogPopup(),
                );
              },
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _loadData,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            child: _buildTabs()[_currentIndex],
          ),
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, -1),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            selectedItemColor: Colors.green,
            unselectedItemColor: Colors.grey,
            backgroundColor: Colors.white,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
            onTap: (index) {
              if (_currentIndex != index) {
                setState(() => _currentIndex = index);
              }
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.menu_book_rounded),
                label: 'Reading',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.play_circle_fill_rounded),
                label: 'Lectures',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.article_rounded),
                label: 'Blogs',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
