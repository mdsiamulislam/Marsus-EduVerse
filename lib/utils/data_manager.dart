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
  /// 🔹 লোকাল path
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  /// 🔹 লোকাল ফাইল রিটার্ন করে
  static Future<File> _localFile(String filename) async {
    final path = await _localPath;
    return File('$path/$filename');
  }

  /// 🔹 লোকাল ফাইল ডিলিট করে
  static Future<void> deleteLocalFile(String filename) async {
    if (filename.isEmpty) return;
    try {
      final file = await _localFile(filename);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error deleting file $filename: $e');
    }
  }

  /// 🔹 ফাইল ডাউনলোড করে লোকাল পাথে সেভ করে
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

  /// 🔹 পুরনো ও নতুন লিস্ট একি কিনা যাচাই করে
  static bool _isSameData(List<Map<String, dynamic>> oldList, List<Map<String, dynamic>> newList) {
    return jsonEncode(oldList) == jsonEncode(newList);
  }

  /// 🔹 নতুন ও পুরাতন লিস্টের ভিত্তিতে ইমেজ প্রসেস করে
  static Future<void> _processImages(
      List<Map<String, dynamic>> newList,
      List<Map<String, dynamic>> oldList,
      ) async {
    for (var item in newList) {
      final imageUrl = item['image'];
      if (imageUrl == null) continue;

      final fileName = imageUrl.split('/').last;

      final oldItem = oldList.firstWhere(
            (e) => e['link'] == item['link'],
        orElse: () => <String, dynamic>{},
      );

      bool shouldDownload = true;

      if (oldItem['image'] == imageUrl) {
        final file = await _localFile(fileName);
        if (await file.exists()) {
          item['image'] = file.path;
          shouldDownload = false;
        }
      } else if (oldItem['image'] != null && oldItem['image'].toString().contains('/')) {
        final oldFileName = oldItem['image'].toString().split('/').last;
        await deleteLocalFile(oldFileName);
      }

      if (shouldDownload) {
        final localPath = await downloadAndSaveFile(imageUrl, fileName);
        if (localPath != null) {
          item['image'] = localPath;
        }
      }
    }
  }

  /// 🔹 লোকাল ডেটা লোড
  static Future<void> loadDataFromDevice(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    BookList = _loadLocalData(prefs, 'book_list', fallbackBookList);
    LecturesList = _loadLocalData(prefs, 'lecture_list', fallbackLecturesList);
    BlogList = _loadLocalData(prefs, 'blog_list', fallbackBlogList);

    print('✅ Local data loaded');

    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      print('📴 No internet connection');
    }
  }

  /// 🔹 লোকাল ডেটা হেল্পার
  static List<Map<String, dynamic>> _loadLocalData(
      SharedPreferences prefs,
      String key,
      List<Map<String, dynamic>> fallback,
      ) {
    try {
      if (prefs.containsKey(key)) {
        final decoded = jsonDecode(prefs.getString(key)!);
        if (decoded is List) {
          return List<Map<String, dynamic>>.from(decoded);
        }
      }
    } catch (e) {
      print('❌ Failed to load $key from prefs: $e');
    }
    return fallback;
  }

  /// 🔹 পুরোনো item গুলোর পুরনো ফাইল ডিলিট করে যদি আপডেট থাকে
  static Future<void> _processListUpdates(
      List<Map<String, dynamic>> oldList,
      List<Map<String, dynamic>> newList,
      ) async {
    for (final oldItem in oldList) {
      final newItem = newList.firstWhere(
            (e) => e['link'] == oldItem['link'],
        orElse: () => <String, dynamic>{},
      );

      if (newItem.isNotEmpty) {
        if (newItem['image'] != oldItem['image']) {
          final oldImage = oldItem['image'];
          if (oldImage != null && oldImage.toString().contains('/')) {
            final fileName = oldImage.split('/').last;
            await deleteLocalFile(fileName);
          }
        }

        if (newItem['link'] != oldItem['link']) {
          final oldPdf = oldItem['link'];
          if (oldPdf != null && oldPdf.toString().contains('/')) {
            final fileName = oldPdf.split('/').last;
            await deleteLocalFile(fileName);
          }
        }
      }
    }
  }

  /// 🔹 অনলাইন থেকে ফেচ করে লোকাল এবং র্যাম এ আপডেট করে
  static Future<void> syncData({
    required BuildContext context,
    bool loadLocalFirst = false,
    bool checkInternet = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (loadLocalFirst) {
      BookList = _loadLocalData(prefs, 'book_list', fallbackBookList);
      LecturesList = _loadLocalData(prefs, 'lecture_list', fallbackLecturesList);
      BlogList = _loadLocalData(prefs, 'blog_list', fallbackBlogList);
      print('✅ Local data loaded');
    }

    if (checkInternet) {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        print('📴 No internet connection');
        return;
      }
    }

    try {
      final response = await http.get(Uri.parse(
        'https://script.google.com/macros/s/AKfycbz24xdGvbElygR1B24k8MQf0DKcrcAtoPn0VMI2VopmUjL7JqM7O38R98ivENqCEtjhJQ/exec',
      ));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final fetchedBookList = List<Map<String, dynamic>>.from(data['BookList']);
        final fetchedLecturesList = List<Map<String, dynamic>>.from(data['LecturesList '] ?? []);
        final fetchedBlogList = List<Map<String, dynamic>>.from(data['BlogList'] ?? []);

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
}