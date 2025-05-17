import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../const/list_of_content.dart';

Future<void> checkAndUpdateData({required VoidCallback onUpdate}) async {
  final prefs = await SharedPreferences.getInstance();

  // প্রথমে লোকাল ডেটা লোড করো
  final localBooks = prefs.getString('BookList');
  final localLectures = prefs.getString('LecturesList');

  if (localBooks != null) {
    BookList = List<Map<String, dynamic>>.from(jsonDecode(localBooks));
  }
  if (localLectures != null) {
    LecturesList = List<Map<String, dynamic>>.from(jsonDecode(localLectures));
  }

  // এখন ইন্টারনেট থাকলে API থেকে নতুন ডেটা ফেচ করো
  final connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult == ConnectivityResult.none) {
    debugPrint("No internet connection. Loaded local data.");
    return;
  }

  try {
    final response = await http.get(Uri.parse(
        'https://script.google.com/macros/s/AKfycbz24xdGvbElygR1B24k8MQf0DKcrcAtoPn0VMI2VopmUjL7JqM7O38R98ivENqCEtjhJQ/exec'));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final fetchedBookList =
      List<Map<String, dynamic>>.from(jsonData['BookList']);
      final fetchedLecturesList =
      List<Map<String, dynamic>>.from(jsonData['LecturesList ']);

      bool isBookListDifferent =
          jsonEncode(BookList) != jsonEncode(fetchedBookList);
      bool isLectureListDifferent =
          jsonEncode(LecturesList) != jsonEncode(fetchedLecturesList);

      if (isBookListDifferent) {
        BookList = fetchedBookList;
        await prefs.setString('BookList', jsonEncode(fetchedBookList));
        debugPrint("BookList updated and saved locally.");
      }

      if (isLectureListDifferent) {
        LecturesList = fetchedLecturesList;
        await prefs.setString('LecturesList', jsonEncode(fetchedLecturesList));
        debugPrint("LecturesList updated and saved locally.");
      }

      onUpdate(); // UI update
    } else {
      debugPrint("API fetch failed: ${response.statusCode}");
    }
  } catch (e) {
    debugPrint("Error fetching or saving data: $e");
  }
}
