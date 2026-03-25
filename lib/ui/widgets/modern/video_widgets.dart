import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

/// Video player widget with controls for hostel tours
class VideoTourPlayer extends StatefulWidget {
  final String videoUrl;
  final double? aspectRatio;
  final bool autoPlay;
  final bool looping;

  const VideoTourPlayer({
    super.key,
    required this.videoUrl,
    this.aspectRatio = 16 / 9,
    this.autoPlay = false,
    this.looping = false,
  });

  @override
  State<VideoTourPlayer> createState() => _VideoTourPlayerState();
}

class _VideoTourPlayerState extends State<VideoTourPlayer> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isInitialized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      // Determine if the URL is a network URL or asset
      if (widget.videoUrl.startsWith('http://') || widget.videoUrl.startsWith('https://')) {
        _videoPlayerController = VideoPlayerController.networkUrl(
          Uri.parse(widget.videoUrl),
        );
      } else {
        // Assume it's an asset if not a network URL
        _videoPlayerController = VideoPlayerController.asset(widget.videoUrl);
      }

      await _videoPlayerController.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        aspectRatio: widget.aspectRatio ?? _videoPlayerController.value.aspectRatio,
        autoPlay: widget.autoPlay,
        looping: widget.looping,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.blue,
          handleColor: Colors.blueAccent,
          backgroundColor: Colors.grey[300]!,
          bufferedColor: Colors.grey[400]!,
        ),
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 48.w,
                ),
                SizedBox(height: 16.h),
                Text(
                  'Error loading video',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  errorMessage,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      );

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('VideoTourPlayer error: $e');
      debugPrint('Video URL was: ${widget.videoUrl}');
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Container(
        height: 160.h,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.videocam_off_outlined,
                size: 36.w,
                color: Colors.grey[600],
              ),
              SizedBox(height: 8.h),
              Text(
                'Video unavailable',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 6.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.w),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 10.sp,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 8.h),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _errorMessage = null;
                    _isInitialized = false;
                  });
                  _initializePlayer();
                },
                icon: Icon(Icons.refresh, size: 16.w),
                label: Text('Retry', style: TextStyle(fontSize: 12.sp)),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized || _chewieController == null) {
      return Container(
        height: 160.h,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: AspectRatio(
        aspectRatio: widget.aspectRatio ?? 16 / 9,
        child: Chewie(
          controller: _chewieController!,
        ),
      ),
    );
  }
}

/// Compact video tour card for hostel details page
class VideoTourCard extends StatelessWidget {
  final String videoUrl;
  final String title;
  final String? description;

  const VideoTourCard({
    super.key,
    required this.videoUrl,
    this.title = 'Virtual Tour',
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.play_circle_outline,
                      color: theme.colorScheme.primary,
                      size: 20.w,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                if (description != null) ...[
                  SizedBox(height: 6.h),
                  Text(
                    description!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          VideoTourPlayer(
            videoUrl: videoUrl,
            autoPlay: false,
            looping: false,
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }
}

/// YouTube-style embed player (for YouTube URLs)
class YouTubeVideoPlayer extends StatelessWidget {
  final String videoUrl;

  const YouTubeVideoPlayer({
    super.key,
    required this.videoUrl,
  });

  String? _extractYouTubeVideoId(String url) {
    // Extract video ID from various YouTube URL formats
    final regExp = RegExp(
      r'(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(url);
    return match?.group(1);
  }

  @override
  Widget build(BuildContext context) {
    final videoId = _extractYouTubeVideoId(videoUrl);

    if (videoId == null) {
      // Fallback to regular video player
      return VideoTourPlayer(videoUrl: videoUrl);
    }

    // For YouTube videos, use the standard video player with the video URL
    // Note: For production, consider using youtube_player_flutter package
    return VideoTourPlayer(videoUrl: videoUrl);
  }
}
