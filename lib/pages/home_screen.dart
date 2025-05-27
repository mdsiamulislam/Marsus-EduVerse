import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:marsuseduverse/widget/BlogTab.dart';
import 'package:marsuseduverse/widget/LectureTab.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upgrader/upgrader.dart';

import '../utils/data_manager.dart';
import '../widget/book_library_tab.dart';
import '../widget/no_internet_tab.dart';
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

  List<Widget> _tabs = [const BookLibraryTab(hasInternet: false)]; // Default fallback tab
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _initializeTabs();
    _setupConnectivityListener();
    _checkNewUser();
  }

  void _setupConnectivityListener() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      final newInternetStatus = result != ConnectivityResult.none;
      if (newInternetStatus != _hasInternet) {
        _handleConnectivityChange(newInternetStatus);
      }
    });
  }

  Future<void> _handleConnectivityChange(bool newInternetStatus) async {
    setState(() {
      _hasInternet = newInternetStatus;
    });
    await _initializeTabs();

    // If internet is restored, refresh data
    if (newInternetStatus) {
      await DataManager.loadDataFromDevice(context);
    }
  }

  Future<void> _initializeTabs() async {
    final tabs = [
      BookLibraryTab(hasInternet: _hasInternet),
      if (_hasInternet) const LectureTab(),
      if (_hasInternet) const Blogtab(),
      if (!_hasInternet) const NoInternetTab(),
    ];

    if (mounted) {
      setState(() {
        _tabs = tabs;
        // Reset to first tab if current index is invalid after tab change
        if (_currentIndex >= tabs.length) {
          _currentIndex = 0;
        }
      });
    }
  }

  Future<void> _checkNewUser() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final isNewUser = prefs.getBool('newUser') ?? true;

      if (isNewUser) {
        await DataManager.updateData(context);
        await prefs.setBool('newUser', false);
      }
    } catch (e) {
      debugPrint('Error checking new user: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }



  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
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
          leading: IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();  // This clears all data in SharedPreferences
              _checkNewUser();
              print('All SharedPreferences data cleared!');
            },

          ),
        ),
        body: RefreshIndicator(
          onRefresh: () {
            return DataManager.updateData(context);
          },
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : IndexedStack(
            index: _currentIndex,
            children: _tabs,
          ),
        ),
        bottomNavigationBar: _buildBottomNavBar(),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
          if (index < _tabs.length) {
            setState(() => _currentIndex = index);
          }
        },
        items: _hasInternet
            ? const [
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
            : const [
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_rounded),
            label: 'Reading',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.wifi_off),
            label: 'Offline',
          ),
        ],
      ),
    );
  }
}