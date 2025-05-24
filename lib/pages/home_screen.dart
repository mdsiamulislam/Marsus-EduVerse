import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart';

import '../utils/data_manager.dart';
import '../widget/book_library_tab.dart';
import '../widget/LectureTab.dart';
import '../widget/BlogTab.dart';
import 'AboutDialogPopup.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _hasInternet = false;

  late List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _loadData();
    checkConnectivityAndSetTabs();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DataManager.updateData(context);
    });
  }

  Future<void> _loadData([bool fresh = false]) async {
    setState(() => _isLoading = true);

    if (fresh) {
      await DataManager.checkAndUpdateData(context);
    }

    await Future.delayed(const Duration(milliseconds: 100));
    setState(() => _isLoading = false);
  }



  Future<void> checkConnectivityAndSetTabs() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    _hasInternet = connectivityResult != ConnectivityResult.none;

    setState(() {
      _tabs = [
        BookLibraryTab(),
        if (_hasInternet) LectureTab(),
        if (_hasInternet) Blogtab(),
        if (!_hasInternet)
          Center(
            child: Text(
              'No Internet Connection',
              style: TextStyle(fontSize: 18, color: Colors.red),
            ),
          ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      dialogStyle: UpgradeDialogStyle.material,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
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
          onRefresh:() async {
            await _loadData(true);
          },
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : IndexedStack(
                  index: _currentIndex,
                  children: _tabs,
          ),
        ),

        bottomNavigationBar: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, -2),
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


              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 12,
              ),
              onTap: (index) {
                if (_currentIndex != index) {
                  setState(() => _currentIndex = index);
                }
              },
              items: _hasInternet
                  ? [
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
              ]
                  : [
                BottomNavigationBarItem(
                  icon: Icon(Icons.menu_book_rounded),
                  label: 'Reading',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.warning_amber_rounded),
                  label: 'No Internet',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


