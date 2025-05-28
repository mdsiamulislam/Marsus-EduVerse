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

  List<Widget> _tabs = [const BookLibraryTab(hasInternet: false)];
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _setupConnectivityListener();
    _checkNewUser();
    _checkNewDay();
  }

  Future<void> _checkNewDay() async {
    final prefs = await SharedPreferences.getInstance();
    final lastVisit = prefs.getString('lastVisitDate');
    final today = DateTime.now().toIso8601String().substring(0, 10);

    if (lastVisit != today) {
      if (_hasInternet) {
        await DataManager.syncData(
          context: context,
          loadLocalFirst: false,
          checkInternet: true,
        );
        await prefs.setString('lastVisitDate', today);
        debugPrint('✅ ডেটা আজকের জন্য সিঙ্ক হয়েছে');
      } else {
        debugPrint('❌ ইন্টারনেট নেই, কিন্তু নতুন দিন শুরু হয়েছে — সিঙ্ক হয়নি');
      }
    } else {
      debugPrint('📆 আজকের ডেটা আগেই সিঙ্ক হয়েছে');
    }
  }



  void _setupConnectivityListener() {
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((result) {
          final newInternetStatus = result != ConnectivityResult.none;
          if (newInternetStatus != _hasInternet) {
            _handleConnectivityChange(newInternetStatus);
          }
        });
  }

  Future<void> _handleConnectivityChange(bool newInternetStatus) async {
    _hasInternet = newInternetStatus;
    await _initializeTabs();

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
        await DataManager.syncData(
          context: context,
          loadLocalFirst: false,
          checkInternet: true,
        );
        await prefs.setBool('newUser', false);
      }

      // Initial internet check
      final connectivityResult = await Connectivity().checkConnectivity();
      _hasInternet = connectivityResult != ConnectivityResult.none;
      await _initializeTabs();
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
              await prefs.clear();
              _checkNewUser();
              debugPrint('All SharedPreferences data cleared!');
            },
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () {
            setState(() => _isLoading = true);
            return DataManager.syncData(
              context: context,
              loadLocalFirst: false,
              checkInternet: true,
            ).then((_) {
              return _initializeTabs();
            }).whenComplete(() {
              if (mounted) {
                setState(() => _isLoading = false);
              }
            });
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
