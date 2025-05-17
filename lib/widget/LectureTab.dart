import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../const/list_of_content.dart';

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
    final tags = LecturesList.map((e) => e['tag']).toSet().toList();
    tags.removeWhere((tag) => tag == null);
    tags.sort();
    return ['All', ...tags.cast<String>()];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showPlayer)
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width * 9 / 16,
            child: YoutubePlayer(
              controller: _controller,
              aspectRatio: 16 / 9,
            ),
          ),

        const SizedBox(height: 12),

        // Search + Tag Sort UI
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search lectures...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              DropdownButton<String>(
                value: selectedTag,
                items: allTags.map((tag) {
                  return DropdownMenuItem(
                    value: tag,
                    child: Text(tag),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedTag = value;
                    });
                  }
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        Expanded(
          child: filteredLectures.isEmpty
              ? const Center(
            child: Text("No lectures found."),
          )
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: filteredLectures.length,
            itemBuilder: (context, index) {
              final lecture = filteredLectures[index];
              final videoId = lecture['youtubeId']!;
              final thumbnailUrl =
                  'https://img.youtube.com/vi/$videoId/0.jpg';

              return GestureDetector(
                onTap: () => playVideo(videoId),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                        child: Image.network(
                          thumbnailUrl,
                          width: 130,
                          height: 90,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, size: 50),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lecture['title']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                lecture['description']!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Design for tag
                              if (lecture.containsKey('tag'))
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.green,
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    lecture['tag']!,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              if (lecture.containsKey('subtitle'))
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    lecture['subtitle']!,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
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
            },
          ),
        ),
      ],
    );
  }
}
