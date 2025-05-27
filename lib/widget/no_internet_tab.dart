import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class NoInternetTab extends StatefulWidget {
  const NoInternetTab({super.key});

  @override
  State<NoInternetTab> createState() => _NoInternetTabState();
}

class _NoInternetTabState extends State<NoInternetTab> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          Lottie.asset(
          'assets/no_internet.json',
          width: 200,
          height: 200,
        ),
        const SizedBox(height: 20),
        Text(
          'আপনার ইন্টারনেট সংযোগ বিচ্ছিন্ন রয়েছে',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 25),
        Container(
          width: double.infinity,
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Colors.green[50],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ইন্টারনেট ছাড়া আপনি যা যা করতে পারবেন না:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.green[800],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureItem('নতুন আপডেট পাবেন না'),
                  _buildFeatureItem('অনলাইন সার্ভিস ব্যবহার করতে পারবেন না যেমন ব্লগ পড়তে পারবেন না, লেকচার শুনতে পারবেন না, নতুন বই ডাউনলোড করতে পারবেন না'),
                  _buildFeatureItem('কোনো নতুন কন্টেন্ট লোড করতে পারবেন না'),
                  _buildFeatureItem('রিয়েল-টাইম ডাটা দেখতে পারবেন না'),
                ],
              ),
            ),
          ),
        ),
        ]
      ),
      )
    );
  }

  // Helper widget for feature items
  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.close, size: 16, color: Colors.red[400]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}