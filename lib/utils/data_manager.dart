
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import '../const/list_of_content.dart';

Future<void> checkAndUpdateData() async {
  final prefs = await SharedPreferences.getInstance();
  final connectivityResult = await Connectivity().checkConnectivity();

  // If online, try to fetch from API
  if (connectivityResult != ConnectivityResult.none) {
    try {
      final response = await http.get(Uri.parse(
          'https://script.google.com/macros/s/AKfycbz24xdGvbElygR1B24k8MQf0DKcrcAtoPn0VMI2VopmUjL7JqM7O38R98ivENqCEtjhJQ/exec'));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        final fetchedBookList = List<Map<String, dynamic>>.from(jsonData['BookList']);
        final fetchedLecturesList = List<Map<String, dynamic>>.from(jsonData['LecturesList '] ?? []);

        BookList = fetchedBookList;
        LecturesList = fetchedLecturesList;

        // Save locally
        await prefs.setString('book_list', jsonEncode(BookList));
        await prefs.setString('lecture_list', jsonEncode(LecturesList));
      }
    } catch (e) {
      print("API Fetch error: $e");
    }
  }

  // Load from local or fallback
  if (prefs.containsKey('book_list')) {
    BookList = List<Map<String, dynamic>>.from(
        jsonDecode(prefs.getString('book_list')!));
  } else {
    BookList = fallbackBookList;
  }

  if (prefs.containsKey('lecture_list')) {
    LecturesList = List<Map<String, dynamic>>.from(
        jsonDecode(prefs.getString('lecture_list')!));
  } else {
    LecturesList = fallbackLecturesList;
  }
}