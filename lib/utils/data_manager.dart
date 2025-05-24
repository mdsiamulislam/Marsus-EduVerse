import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../const/list_of_content.dart';

List<Map<String, dynamic>> BookList = [];
List<Map<String, dynamic>> LecturesList = [];
List<Map<String, dynamic>> BlogList = [];

class DataManager {
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> _localFile(String filename) async {
    final path = await _localPath;
    return File('$path/$filename');
  }

  static Future<void> deleteLocalFile(String filename) async {
    if (filename.isEmpty) return;
    try {
      final file = await _localFile(filename);
      if (await file.exists()) {
        await file.delete();
        print('Deleted file: $filename');
      }
    } catch (e) {
      print('Error deleting file $filename: $e');
    }
  }

  static Future<String?> downloadAndSaveFile(String url, String filename) async {
    try {
      final file = await _localFile(filename);
      if (await file.exists()) return file.path;

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        return file.path;
      }
    } catch (e) {
      print('Error downloading file: $e');
    }
    return null;
  }

  static bool _isSameData(List<Map<String, dynamic>> oldList, List<Map<String, dynamic>> newList) {
    return jsonEncode(oldList) == jsonEncode(newList);
  }

  static Future<void> _processImages(
      List<Map<String, dynamic>> newList,
      List<Map<String, dynamic>> oldList,
      ) async {
    for (var item in newList) {
      final imageUrl = item['image'];
      final fileName = imageUrl.split('/').last;

      final oldItem = oldList.firstWhere((e) => e['id'] == item['id'], orElse: () => {});
      bool shouldDownload = true;

      if (oldItem.isNotEmpty && oldItem['image'] != null) {
        if (oldItem['image'] == imageUrl) {
          shouldDownload = false;
          final existingPath = await _localFile(fileName);
          if (await existingPath.exists()) {
            item['image'] = existingPath.path;
          }
        } else {
          final oldImageFile = oldItem['image']?.split('/').last ?? '';
          await deleteLocalFile(oldImageFile);
        }
      }

      if (shouldDownload) {
        final localPath = await downloadAndSaveFile(imageUrl, fileName);
        if (localPath != null) {
          item['image'] = localPath;
        }
      }
    }
  }



  static Future<void> checkAndUpdateData(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final connectivityResult = await Connectivity().checkConnectivity();

    // 🔹 Step 1: Load local data first and show instantly
    BookList = _loadLocalData(prefs, 'book_list', fallbackBookList);
    LecturesList = _loadLocalData(prefs, 'lecture_list', fallbackLecturesList);
    BlogList = _loadLocalData(prefs, 'blog_list', fallbackBlogList);
    print('✅ Local data loaded');

    // 🔹 Step 2: If no internet, stop here silently
    if (connectivityResult == ConnectivityResult.none) {
      return;
    }

    // 🔹 Step 3: Fetch from server in background
    try {
      final response = await http.get(Uri.parse(
        'https://script.google.com/macros/s/AKfycbz24xdGvbElygR1B24k8MQf0DKcrcAtoPn0VMI2VopmUjL7JqM7O38R98ivENqCEtjhJQ/exec',
      ));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final fetchedBookList = List<Map<String, dynamic>>.from(data['BookList']);
        final fetchedLecturesList = List<Map<String, dynamic>>.from(data['LecturesList '] ?? []);
        final fetchedBlogList = List<Map<String, dynamic>>.from(data['BlogList'] ?? []);

        // 🔹 Step 4: Only update if data has changed
        if (!_isSameData(BookList, fetchedBookList)) {
          await _processListUpdates(BookList, fetchedBookList);
          await _processImages(fetchedBookList, BookList);
          BookList = fetchedBookList;
          await prefs.setString('book_list', jsonEncode(BookList));
          print('📘 BookList updated');
        }

        if (!_isSameData(LecturesList, fetchedLecturesList)) {
          await _processListUpdates(LecturesList, fetchedLecturesList);
          LecturesList = fetchedLecturesList;
          await prefs.setString('lecture_list', jsonEncode(LecturesList));
          print('📺 Lectures updated');
        }

        if (!_isSameData(BlogList, fetchedBlogList)) {
          await _processListUpdates(BlogList, fetchedBlogList);
          BlogList = fetchedBlogList;
          await prefs.setString('blog_list', jsonEncode(BlogList));
          print('📰 Blogs updated');
        }
      }
    } catch (e) {
      print('❌ Failed to fetch from API: $e');
    }
  }


  static List<Map<String, dynamic>> _loadLocalData(
      SharedPreferences prefs,
      String key,
      List<Map<String, dynamic>> fallback,
      ) {
    return prefs.containsKey(key)
        ? List<Map<String, dynamic>>.from(jsonDecode(prefs.getString(key)!))
        : fallback;
  }

  static Future<void> _processListUpdates(
      List<Map<String, dynamic>> oldList,
      List<Map<String, dynamic>> newList,
      ) async {
    for (var oldItem in oldList) {
      final newItem = newList.firstWhere(
            (e) => e['id'] == oldItem['id'],
        orElse: () => {},
      );

      if (newItem.isNotEmpty) {
        if (newItem['image'] != oldItem['image']) {
          final oldImage = oldItem['image']?.split('/').last ?? '';
          await deleteLocalFile(oldImage);
        }
        if (newItem['pdf'] != oldItem['pdf']) {
          final oldPdf = oldItem['pdf']?.split('/').last ?? '';
          await deleteLocalFile(oldPdf);
        }
      }
    }
  }
}

