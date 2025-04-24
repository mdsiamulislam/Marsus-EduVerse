import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../const/list_of_content.dart';

class LectureTab extends StatefulWidget {
  const LectureTab({super.key});

  @override
  State<LectureTab> createState() => _LectureTabState();
}

class _LectureTabState extends State<LectureTab> with SingleTickerProviderStateMixin {
  late YoutubePlayerController _controller;
  String? currentVideoId;
  bool showPlayer = false;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        mute: false,
      ),
    );
  }

  void playVideo(String videoId) {
    setState(() {
      currentVideoId = videoId;
      showPlayer = true;
      _controller.loadVideoById(videoId: videoId);
    });
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: showPlayer
              ? Container(
            key: ValueKey(currentVideoId),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width * 9 / 16,
            child: YoutubePlayer(
              controller: _controller,
              aspectRatio: 16 / 9,
            ),
          )
              : const SizedBox.shrink(),
        ),

        const SizedBox(height: 12),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: LecturesList.length,
            itemBuilder: (context, index) {
              final lecture = LecturesList[index];
              final videoId = lecture['youtubeId']!;
              final thumbnailUrl = 'https://img.youtube.com/vi/$videoId/0.jpg';

              return GestureDetector(
                onTap: () => playVideo(videoId),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
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
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
