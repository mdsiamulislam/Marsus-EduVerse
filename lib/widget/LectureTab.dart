import 'package:flutter/material.dart';
import 'package:untitled/const/list_of_content.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

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
        // 🎬 Animated player section
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          width: MediaQuery.of(context).size.width,
          height: showPlayer ? MediaQuery.of(context).size.width * 9 / 16 : 0,
          child: showPlayer
              ? YoutubePlayer(
            controller: _controller,
            aspectRatio: 16 / 9,
          )
              : null,
        ),

        const SizedBox(height: 12),

        // 🎞️ List of lectures with thumbnails
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: LecturesList.length,
            itemBuilder: (context, index) {
              final lecture = LecturesList[index];
              final videoId = lecture['youtubeId']!;
              final thumbnailUrl = 'https://img.youtube.com/vi/$videoId/0.jpg';

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(8),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      thumbnailUrl,
                      width: 100,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    lecture['title']!,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () => playVideo(videoId),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
