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

  static Future<void> checkAndUpdateData(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final connectivityResult = await Connectivity().checkConnectivity();
    final isFirstTime = !prefs.containsKey('book_list');

    if (isFirstTime && connectivityResult == ConnectivityResult.none) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("ইন্টারনেট সংযোগ প্রয়োজন"),
          content: const Text("প্রথমবার অ্যাপ ব্যবহারের জন্য ইন্টারনেট সংযোগ আবশ্যক।"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("ঠিক আছে"),
            )
          ],
        ),
      );
      return;
    }

    final localBookList = _loadLocalData(prefs, 'book_list', fallbackBookList);
    final localLecturesList = _loadLocalData(prefs, 'lecture_list', fallbackLecturesList);
    final localBlogList = _loadLocalData(prefs, 'blog_list', fallbackBlogList);

    if (connectivityResult != ConnectivityResult.none) {
      try {
        final response = await http.get(Uri.parse(
          'https://script.google.com/macros/s/AKfycbz24xdGvbElygR1B24k8MQf0DKcrcAtoPn0VMI2VopmUjL7JqM7O38R98ivENqCEtjhJQ/exec',
        ));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final fetchedBookList = List<Map<String, dynamic>>.from(data['BookList']);
          final fetchedLecturesList = List<Map<String, dynamic>>.from(data['LecturesList '] ?? []);
          final fetchedBlogList = List<Map<String, dynamic>>.from(data['BlogList'] ?? []);

          await _processListUpdates(localBookList, fetchedBookList);
          await _processListUpdates(localLecturesList, fetchedLecturesList);
          await _processListUpdates(localBlogList, fetchedBlogList);

          // 🔽 Update image URLs to local paths
          for (var book in fetchedBookList) {
            final imageUrl = book['image'];
            final imageFileName = imageUrl.split('/').last;

            final oldBook = localBookList.firstWhere(
                  (b) => b['id'] == book['id'],
              orElse: () => {},
            );

            bool shouldDownload = true;

            if (oldBook.isNotEmpty && oldBook['image'] != null) {
              final oldImageUrl = oldBook['image'];
              if (oldImageUrl != imageUrl) {
                final oldImageFile = oldImageUrl.split('/').last;
                await deleteLocalFile(oldImageFile);
              } else {
                shouldDownload = false;
                final existingPath = await _localFile(imageFileName);
                if (await existingPath.exists()) {
                  book['image'] = existingPath.path;
                }
              }
            }

            if (shouldDownload) {
              final localPath = await downloadAndSaveFile(imageUrl, imageFileName);
              if (localPath != null) {
                book['image'] = localPath;
              }
            }
          }

          // 🔽 Save and assign updated lists
          BookList = fetchedBookList;
          LecturesList = fetchedLecturesList;
          BlogList = fetchedBlogList;

          await prefs.setString('book_list', jsonEncode(BookList));
          await prefs.setString('lecture_list', jsonEncode(LecturesList));
          await prefs.setString('blog_list', jsonEncode(BlogList));

          print('✅ Data updated successfully from server');
          return;
        }
      } catch (e) {
        print('❌ API fetch error: $e');
      }
    }

    // 🔽 No internet or failed fetch, load from local
    BookList = localBookList;
    LecturesList = localLecturesList;
    BlogList = localBlogList;
    print('ℹ️ Loaded data from local storage');
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

