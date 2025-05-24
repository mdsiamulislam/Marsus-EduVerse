import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../helper/universal_shimmer.dart';
import '../utils/data_manager.dart';

class LectureTab extends StatefulWidget {
  const LectureTab({super.key});

  @override
  State<LectureTab> createState() => _LectureTabState();
}

class _LectureTabState extends State<LectureTab> {
  late YoutubePlayerController _controller;
  String? currentVideoId;
  bool showPlayer = false;
  String searchQuery = '';
  String selectedTag = 'All';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        playsInline: true,
        enableJavaScript: true,
        mute: false,
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  void playVideo(String videoId) {
    setState(() {
      currentVideoId = videoId;
      showPlayer = true;
      _controller.loadVideoById(videoId: videoId);
    });
  }

  List<Map<String, dynamic>> get filteredLectures {
    return LecturesList.where((lecture) {
      final query = searchQuery.toLowerCase();
      final matchesSearch = (lecture['title'] ?? '').toLowerCase().contains(query) ||
          (lecture['tag'] ?? '').toLowerCase().contains(query) ||
          (lecture['subtitle'] ?? '').toLowerCase().contains(query);
      final matchesTag = selectedTag == 'All' || lecture['tag'] == selectedTag;
      return matchesSearch && matchesTag;
    }).toList();
  }

  List<String> get allTags {
    final tags = LecturesList.map((e) => e['tag']).whereType<String>().toSet().toList();
    tags.sort();
    return ['All', ...tags];
  }

  Widget _buildLectureItem(Map<String, dynamic> lecture) {
    final videoId = lecture['youtubeId']!;
    final thumbnailUrl = 'https://img.youtube.com/vi/$videoId/0.jpg';

    return GestureDetector(
      onTap: () => playVideo(videoId),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
              child: Image.network(
                thumbnailUrl,
                width: 130,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 50),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lecture['title'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lecture['description'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    if (lecture.containsKey('tag'))
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.green, width: 1.5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          lecture['tag']!,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ),
                    if (lecture.containsKey('subtitle'))
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          lecture['subtitle']!,
                          style: const TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchFilterRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search lectures...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (value) => setState(() => searchQuery = value),
            ),
          ),
          const SizedBox(width: 12),
          DropdownButton<String>(
            value: selectedTag,
            borderRadius: BorderRadius.circular(12),
            style: const TextStyle(color: Colors.black),
            items: allTags.map((tag) => DropdownMenuItem(value: tag, child: Text(tag))).toList(),
            onChanged: (value) => setState(() => selectedTag = value!),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLectureItem() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 90,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showPlayer)
          AspectRatio(
            aspectRatio: 16 / 9,
            child: YoutubePlayer(controller: _controller),
          ),

        const SizedBox(height: 12),
        _buildSearchFilterRow(),
        const SizedBox(height: 12),

        Expanded(
          child: UniversalShimmer(
            isLoading: _isLoading,
            shimmerChild: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: 5,
              itemBuilder: (_, __) => _buildShimmerLectureItem(),
            ),
            child: filteredLectures.isEmpty
                ? const Center(child: Text("No lectures found."))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: filteredLectures.length,
              itemBuilder: (_, index) =>
                  _buildLectureItem(filteredLectures[index]),
            ),
          ),
        ),
      ],
    );
  }
}
