import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import '../../core/design/app_colors.dart';
import '../../core/navigation/route_names.dart';
import '../../services/courses_service.dart';
import '../../services/token_storage_service.dart';
import '../../services/video_download_service.dart';
import '../../services/youtube_video_service.dart';

class LessonViewerScreen extends StatefulWidget {
  final Map<String, dynamic>? lesson;
  final String? courseId;

  const LessonViewerScreen({super.key, this.lesson, this.courseId});

  @override
  State<LessonViewerScreen> createState() => _LessonViewerScreenState();
}

class _LessonViewerScreenState extends State<LessonViewerScreen> {
  VideoPlayerController? _videoController;
  bool _isVideoLoading = true;
  bool _isLoadingContent = true;
  String? _videoError;
  Map<String, dynamic>? _lessonContent;
  File? _tempVideoFile;
  final VideoDownloadService _downloadService = VideoDownloadService();
  bool _isDownloading = false;
  int _downloadProgress = 0;
  bool _isDownloaded = false;
  bool _showControls = true;
  Timer? _hideControlsTimer;
  bool _isPlaying = false;
  String? _youtubeUrl;
  bool _isFullscreen = false;
  double _playbackSpeed = 1.0;
  static const List<double> _speedOptions = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
  Timer? _positionTimer;

  @override
  void initState() {
    super.initState();
    _initializeDownloadService();
    _loadLessonContent().then((_) {
      _initializeVideo();
      _checkIfDownloaded();
    });
  }

  Future<void> _initializeDownloadService() async {
    try {
      await _downloadService.initialize();
    } on PlatformException catch (e) {
      if (kDebugMode) debugPrint('VideoDownloadService init: ${e.message}');
    } catch (e) {
      if (kDebugMode) debugPrint('VideoDownloadService init error: $e');
    }
  }

  Future<void> _checkIfDownloaded() async {
    final lesson = widget.lesson;
    if (lesson == null) return;
    final lessonId = lesson['id']?.toString();
    if (lessonId == null || lessonId.isEmpty) return;
    final isDownloaded = await _downloadService.isVideoDownloaded(lessonId);
    if (mounted) setState(() => _isDownloaded = isDownloaded);
  }

  Future<void> _loadLessonContent() async {
    final lesson = widget.lesson;
    if (lesson == null) {
      setState(() => _isLoadingContent = false);
      return;
    }

    String? courseId = widget.courseId;
    if (courseId == null || courseId.isEmpty) {
      courseId = lesson['course_id']?.toString() ?? lesson['courseId']?.toString();
    }
    final lessonId = lesson['id']?.toString();

    if (courseId == null || courseId.isEmpty || lessonId == null || lessonId.isEmpty) {
      setState(() => _isLoadingContent = false);
      return;
    }

    try {
      final content = await CoursesService.instance.getLessonContent(courseId, lessonId);
      if (mounted) setState(() { _lessonContent = content; _isLoadingContent = false; });
    } catch (e) {
      if (kDebugMode) print('Error loading lesson content: $e');
      if (mounted) setState(() => _isLoadingContent = false);
    }
  }

  String? _cleanVideoUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    url = url.replaceFirst(RegExp(r'^blob:'), '').trim();
    if (url.contains('blob:')) {
      final blobIndex = url.indexOf('blob:');
      final afterBlob = url.substring(blobIndex + 5).trim();
      if (afterBlob.startsWith('http://') || afterBlob.startsWith('https://')) {
        url = afterBlob;
      } else {
        url = url.substring(0, blobIndex).trim() + afterBlob;
      }
    }
    if (!url.startsWith('http://') && !url.startsWith('https://')) return null;
    return url.trim();
  }

  bool _isYouTubeUrl(String url) {
    return url.contains('youtube.com') || url.contains('youtu.be');
  }

  Future<void> _initializeVideo() async {
    final lesson = widget.lesson;
    if (lesson == null) {
      setState(() => _isVideoLoading = false);
      return;
    }

    final videoData = _lessonContent?['video'] ?? lesson['video'];
    String? videoId;
    String? videoUrl;

    videoUrl = _cleanVideoUrl(lesson['video_url']?.toString());

    if (videoUrl == null && videoData is Map) {
      videoId = videoData['youtube_id']?.toString();
      videoUrl = _cleanVideoUrl(videoData['url']?.toString());
    }

    if (videoUrl == null && lesson['video'] is Map) {
      videoId = lesson['video']?['youtube_id']?.toString();
      videoUrl = _cleanVideoUrl(lesson['video']?['url']?.toString());
    }

    videoId = videoId ?? lesson['youtube_id']?.toString();
    videoId = videoId ?? lesson['youtubeVideoId']?.toString();

    if (videoId == null || videoId.isEmpty) {
      videoId = lesson['id']?.toString();
    }
    videoId = videoId ?? '';

    if (kDebugMode) {
      print('=== INITIALIZING VIDEO ===');
      print('  Video ID: $videoId');
      print('  Video URL: $videoUrl');
      print('  Lesson: ${lesson['title']}');
    }

    try {
      if (videoUrl != null && videoUrl.isNotEmpty) {
        if (_isYouTubeUrl(videoUrl)) {
          _youtubeUrl = videoUrl;
          await _initializeYouTubeDirectStream(videoUrl);
        } else {
          await _initializeDirectVideo(videoUrl);
        }
      } else if (videoId.isNotEmpty) {
        _youtubeUrl = 'https://www.youtube.com/watch?v=$videoId';
        await _initializeYouTubeDirectStream(_youtubeUrl!);
      } else {
        if (mounted) setState(() { _isVideoLoading = false; _videoError = 'لا يوجد فيديو متاح'; });
      }
    } catch (e) {
      if (kDebugMode) print('Error initializing video: $e');
      if (mounted) setState(() { _isVideoLoading = false; _videoError = 'خطأ في تحميل الفيديو'; });
    }
  }

  Future<void> _initializeYouTubeDirectStream(String youtubeUrl) async {
    try {
      if (kDebugMode) print('Getting direct stream for YouTube: $youtubeUrl');

      final directUrl = await YoutubeVideoService.instance.getStreamUrl(youtubeUrl);

      if (directUrl == null || directUrl.isEmpty) {
        if (mounted) setState(() { _isVideoLoading = false; _videoError = 'لا يمكن تشغيل هذا الفيديو'; });
        return;
      }

      if (kDebugMode) print('Got direct stream URL (${directUrl.length} chars)');

      final controller = VideoPlayerController.networkUrl(
        Uri.parse(directUrl),
        httpHeaders: Platform.isIOS
            ? {'User-Agent': 'com.google.ios.youtube/19.29.1 (iPhone16,2; U; CPU iOS 17_5_1 like Mac OS X;)'}
            : {},
      );

      await controller.initialize();

      if (mounted) {
        setState(() {
          _videoController = controller;
          _isVideoLoading = false;
          _videoError = null;
        });
        controller.addListener(_videoPlayerListener);
        if (kDebugMode) print('YouTube video playing via direct stream');
      }
    } catch (e) {
      if (kDebugMode) print('YouTube direct stream failed: $e');
      if (mounted) {
        setState(() {
          _isVideoLoading = false;
          _videoError = 'خطأ في تحميل فيديو YouTube';
        });
      }
    }
  }

  Future<void> _initializeDirectVideo(String videoUrl) async {
    try {
      final token = await TokenStorageService.instance.getAccessToken();

      String videoUrlWithToken = videoUrl;
      if (token != null && token.isNotEmpty) {
        final uri = Uri.parse(videoUrl);
        videoUrlWithToken = uri.replace(queryParameters: {
          ...uri.queryParameters,
          'token': token,
        }).toString();
      }

      final controller = VideoPlayerController.networkUrl(
        Uri.parse(videoUrlWithToken),
        httpHeaders: token != null ? {'Authorization': 'Bearer $token'} : {},
      );

      await controller.initialize();

      if (mounted) {
        setState(() {
          _videoController = controller;
          _isVideoLoading = false;
          _videoError = null;
        });
        controller.addListener(_videoPlayerListener);
      }
    } catch (e) {
      if (kDebugMode) print('Direct video failed: $e');
      if (mounted) {
        setState(() {
          _isVideoLoading = false;
          _videoError = 'خطأ في تحميل الفيديو';
        });
      }
    }
  }

  void _videoPlayerListener() {
    if (_videoController == null || !mounted) return;
    final isPlaying = _videoController!.value.isPlaying;
    if (isPlaying != _isPlaying) {
      setState(() => _isPlaying = isPlaying);
      if (isPlaying) {
        _positionTimer?.cancel();
        _positionTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
          if (mounted && _videoController != null) setState(() {});
        });
      } else {
        _positionTimer?.cancel();
        _positionTimer = null;
      }
    }
  }

  void _togglePlayPause() {
    if (_videoController == null) return;
    if (_videoController!.value.isPlaying) {
      _videoController!.pause();
    } else {
      _videoController!.play();
    }
  }

  Future<void> _openInYouTubeApp() async {
    if (_youtubeUrl == null) return;
    final uri = Uri.parse(_youtubeUrl!);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('لا يمكن فتح YouTube', style: GoogleFonts.cairo()), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) print('Open YouTube failed: $e');
    }
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) _startHideControlsTimer();
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _isPlaying) setState(() => _showControls = false);
    });
  }

  void _skipForward() {
    if (_videoController == null) return;
    final pos = _videoController!.value.position;
    final dur = _videoController!.value.duration;
    final target = pos + const Duration(seconds: 10);
    _videoController!.seekTo(target > dur ? dur : target);
    _startHideControlsTimer();
  }

  void _skipBackward() {
    if (_videoController == null) return;
    final pos = _videoController!.value.position;
    final target = pos - const Duration(seconds: 10);
    _videoController!.seekTo(target < Duration.zero ? Duration.zero : target);
    _startHideControlsTimer();
  }

  void _changeSpeed(double speed) {
    if (_videoController == null) return;
    _videoController!.setPlaybackSpeed(speed);
    setState(() => _playbackSpeed = speed);
    _startHideControlsTimer();
  }

  void _showSpeedPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text('سرعة التشغيل', style: GoogleFonts.cairo(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ..._speedOptions.map((speed) => ListTile(
              title: Text(
                speed == 1.0 ? 'عادي (1x)' : '${speed}x',
                style: GoogleFonts.cairo(
                  color: _playbackSpeed == speed ? AppColors.purple : Colors.white70,
                  fontWeight: _playbackSpeed == speed ? FontWeight.bold : FontWeight.normal,
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
              ),
              trailing: _playbackSpeed == speed
                  ? const Icon(Icons.check_circle, color: AppColors.purple, size: 20)
                  : null,
              onTap: () {
                _changeSpeed(speed);
                Navigator.pop(context);
              },
            )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _toggleFullscreen() {
    setState(() => _isFullscreen = !_isFullscreen);
    if (_isFullscreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    _startHideControlsTimer();
  }

  @override
  void dispose() {
    _positionTimer?.cancel();
    _hideControlsTimer?.cancel();
    _videoController?.removeListener(_videoPlayerListener);
    _videoController?.dispose();
    _videoController = null;
    if (_tempVideoFile != null) {
      try { _tempVideoFile!.deleteSync(); } catch (_) {}
    }
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    final lesson = widget.lesson;
    if (lesson == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F0F1A),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.white54),
              const SizedBox(height: 16),
              Text('لا يوجد درس', style: GoogleFonts.cairo(color: Colors.white, fontSize: 18)),
            ],
          ),
        ),
      );
    }

    if (_isFullscreen) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: _buildFullscreenVideoPlayer(),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildVideoSection(lesson),
            Expanded(child: _buildLessonInfo(lesson)),
          ],
        ),
      ),
    );
  }

  Widget _buildFullscreenVideoPlayer() {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return Container(color: Colors.black, child: const Center(child: CircularProgressIndicator(color: AppColors.purple)));
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _toggleControls,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: VideoPlayer(_videoController!),
            ),
          ),
          if (_showControls) Positioned.fill(child: _buildControlsOverlay(isFullscreen: true)),
        ],
      ),
    );
  }

  Widget _buildNativeVideoPlayer() {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(child: CircularProgressIndicator(color: AppColors.purple)),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _toggleControls,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: VideoPlayer(_videoController!),
            ),
          ),
          if (_showControls) Positioned.fill(child: _buildControlsOverlay(isFullscreen: false)),
        ],
      ),
    );
  }

  Widget _buildControlsOverlay({required bool isFullscreen}) {
    return Container(
      color: Colors.black45,
      child: Column(
        children: [
          // Top bar: speed + fullscreen
          Padding(
            padding: EdgeInsets.only(
              top: isFullscreen ? MediaQuery.of(context).padding.top + 8 : 4,
              left: 12, right: 12,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Speed button
                GestureDetector(
                  onTap: _showSpeedPicker,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.speed, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          _playbackSpeed == 1.0 ? '1x' : '${_playbackSpeed}x',
                          style: GoogleFonts.cairo(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                // Fullscreen button
                GestureDetector(
                  onTap: _toggleFullscreen,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isFullscreen ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded,
                      color: Colors.white, size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Center: skip back, play/pause, skip forward
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Skip backward 10s
                GestureDetector(
                  onTap: _skipBackward,
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.replay_10_rounded, color: Colors.white, size: 28),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 32),
                // Play/Pause
                GestureDetector(
                  onTap: _togglePlayPause,
                  child: Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.purple.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Icon(
                      _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.white, size: 36,
                    ),
                  ),
                ),
                const SizedBox(width: 32),
                // Skip forward 10s
                GestureDetector(
                  onTap: _skipForward,
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.forward_10_rounded, color: Colors.white, size: 28),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom: progress bar + time
          Padding(
            padding: EdgeInsets.only(
              left: 16, right: 16,
              bottom: isFullscreen ? MediaQuery.of(context).padding.bottom + 8 : 8,
            ),
            child: Row(
              children: [
                Text(_formatDuration(_videoController!.value.position),
                    style: GoogleFonts.cairo(color: Colors.white, fontSize: 12)),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: VideoProgressIndicator(
                      _videoController!,
                      allowScrubbing: true,
                      colors: const VideoProgressColors(
                        playedColor: AppColors.purple,
                        bufferedColor: Colors.white30,
                        backgroundColor: Colors.white10,
                      ),
                    ),
                  ),
                ),
                Text(_formatDuration(_videoController!.value.duration),
                    style: GoogleFonts.cairo(color: Colors.white, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return d.inHours > 0 ? '${d.inHours}:$m:$s' : '$m:$s';
  }

  Widget _buildVideoSection(Map<String, dynamic> lesson) {
    return Container(
      color: Colors.black,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16, right: 16, bottom: 8,
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lesson['title'] as String? ?? 'عنوان الدرس',
                        style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'المدة: ${lesson['duration'] ?? 'غير محدد'}',
                        style: GoogleFonts.cairo(fontSize: 12, color: Colors.white60),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 220,
            child: _isVideoLoading
                ? Container(
                    color: Colors.black,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(color: AppColors.purple),
                          const SizedBox(height: 12),
                          Text('جاري تحميل الفيديو...', style: GoogleFonts.cairo(color: Colors.white54, fontSize: 13)),
                        ],
                      ),
                    ),
                  )
                : _videoController != null && _videoController!.value.isInitialized
                    ? _buildNativeVideoPlayer()
                    : Container(
                        color: Colors.black,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, color: Colors.white54, size: 48),
                              const SizedBox(height: 12),
                              Text(
                                _videoError ?? 'لا يمكن تحميل الفيديو',
                                style: GoogleFonts.cairo(color: Colors.white54, fontSize: 14),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() { _isVideoLoading = true; _videoError = null; });
                                      _initializeVideo();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: AppColors.purple,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text('إعادة المحاولة', style: GoogleFonts.cairo(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                  if (_youtubeUrl != null) ...[
                                    const SizedBox(width: 12),
                                    GestureDetector(
                                      onTap: _openInYouTubeApp,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.play_circle_fill, color: Colors.white, size: 18),
                                            const SizedBox(width: 6),
                                            Text('YouTube', style: GoogleFonts.cairo(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonInfo(Map<String, dynamic> lesson) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 20),
            Text(lesson['title'] as String? ?? 'عنوان الدرس',
                style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.foreground)),
            const SizedBox(height: 12),
            Row(children: [_buildStatBadge(Icons.access_time_rounded, lesson['duration'] ?? '0')]),
            const SizedBox(height: 24),
            _buildCard(
              icon: Icons.description_rounded,
              iconColor: AppColors.purple,
              title: 'وصف الدرس',
              child: _isLoadingContent
                  ? const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: AppColors.purple)))
                  : Text(
                      _lessonContent?['description'] as String? ?? 'لا يوجد وصف متاح',
                      style: GoogleFonts.cairo(fontSize: 14, color: AppColors.mutedForeground, height: 1.7),
                    ),
            ),
            const SizedBox(height: 20),
            _buildCard(
              icon: Icons.download_rounded,
              iconColor: AppColors.purple,
              title: 'تحميل للعرض بدون إنترنت',
              child: _isDownloading
                  ? Column(children: [
                      LinearProgressIndicator(value: _downloadProgress / 100, backgroundColor: Colors.grey[200],
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.purple)),
                      const SizedBox(height: 8),
                      Text('جاري التحميل: $_downloadProgress%', style: GoogleFonts.cairo(fontSize: 14, color: AppColors.mutedForeground)),
                    ])
                  : _isDownloaded
                      ? Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(12)),
                          child: Row(children: [
                            Icon(Icons.check_circle, color: Colors.green[600], size: 20),
                            const SizedBox(width: 8),
                            Text('تم تحميل الفيديو', style: GoogleFonts.cairo(fontSize: 14, color: Colors.green[700], fontWeight: FontWeight.bold)),
                          ]),
                        )
                      : ElevatedButton.icon(
                          onPressed: _handleDownload,
                          icon: const Icon(Icons.download, color: Colors.white),
                          label: Text('تحميل للعرض بدون إنترنت', style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.purple,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
            ),
            const SizedBox(height: 20),
            _buildCard(
              icon: Icons.folder_rounded,
              iconColor: Colors.orange,
              title: 'ملفات الدرس',
              child: _isLoadingContent
                  ? const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: AppColors.purple)))
                  : _buildResourcesList(),
            ),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(child: _buildNavButton('الدرس السابق', Icons.arrow_forward_rounded, false, () => context.pop())),
              const SizedBox(width: 12),
              Expanded(child: _buildNavButton('الدرس التالي', Icons.arrow_back_rounded, true, () => context.pop())),
            ]),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required IconData icon, required Color iconColor, required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Text(title, style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.foreground)),
          ]),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildStatBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: AppColors.purple),
        const SizedBox(width: 6),
        Text(text, style: GoogleFonts.cairo(fontSize: 12, color: AppColors.foreground)),
      ]),
    );
  }

  Widget _buildResourcesList() {
    final resources = _lessonContent?['resources'] as List?;
    final contentPdf = _lessonContent?['content_pdf'] as String?;
    final List<Map<String, dynamic>> resourceList = [];

    if (contentPdf != null && contentPdf.isNotEmpty) {
      resourceList.add({'title': 'ملف PDF - ملخص الدرس', 'url': contentPdf, 'type': 'pdf', 'icon': Icons.picture_as_pdf});
    }
    if (resources != null && resources.isNotEmpty) {
      for (var resource in resources) {
        if (resource is Map<String, dynamic>) {
          final title = resource['title']?.toString() ?? resource['name']?.toString() ?? 'ملف مرفق';
          final url = resource['url']?.toString() ?? resource['file']?.toString() ?? '';
          final type = (resource['type']?.toString() ?? resource['file_type']?.toString() ?? '').toLowerCase();
          IconData icon = Icons.insert_drive_file;
          if (type.contains('pdf')) icon = Icons.picture_as_pdf;
          else if (type.contains('zip') || type.contains('rar')) icon = Icons.folder_zip;
          else if (type.contains('image')) icon = Icons.image;
          else if (type.contains('video')) icon = Icons.video_file;
          resourceList.add({'title': title, 'url': url, 'type': type, 'icon': icon, 'size': resource['size']?.toString() ?? ''});
        }
      }
    }

    if (resourceList.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Center(child: Text('لا توجد ملفات متاحة', style: GoogleFonts.cairo(fontSize: 14, color: AppColors.mutedForeground))),
      );
    }

    return Column(
      children: resourceList.asMap().entries.map((entry) {
        final r = entry.value;
        return Column(children: [
          _buildResourceItem(r['title'] as String, r['size'] as String? ?? '', r['icon'] as IconData, r['url'] as String? ?? ''),
          if (entry.key < resourceList.length - 1) const SizedBox(height: 10),
        ]);
      }).toList(),
    );
  }

  Future<void> _handleDownload() async {
    final lesson = widget.lesson;
    if (lesson == null) return;
    final lessonId = lesson['id']?.toString();
    final courseId = widget.courseId ?? lesson['course_id']?.toString();
    final title = lesson['title']?.toString() ?? 'فيديو';
    final description = lesson['description']?.toString() ?? '';

    if (lessonId == null || courseId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('لا يمكن تحميل هذا الفيديو', style: GoogleFonts.cairo()), backgroundColor: Colors.red));
      return;
    }

    final hasPermission = await _downloadService.hasStoragePermission();
    if (!hasPermission) {
      final granted = await _downloadService.requestPermission();
      if (!granted) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('يجب منح صلاحيات التخزين', style: GoogleFonts.cairo()), backgroundColor: Colors.orange));
        return;
      }
    }

    String? rawVideoUrl = _lessonContent?['video']?['url']?.toString() ??
        lesson['video_url']?.toString() ?? lesson['video']?['url']?.toString();
    final videoUrl = _cleanVideoUrl(rawVideoUrl);

    if (videoUrl == null || videoUrl.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('لا يوجد رابط فيديو', style: GoogleFonts.cairo()), backgroundColor: Colors.red));
      return;
    }

    setState(() { _isDownloading = true; _downloadProgress = 0; });

    try {
      String? courseTitle;
      try {
        final courseDetails = await CoursesService.instance.getCourseDetails(courseId);
        courseTitle = courseDetails['title']?.toString();
      } catch (_) {}

      if (_isYouTubeUrl(videoUrl)) {
        final safeCourseTitle = (courseTitle ?? 'course_$courseId').replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
        final safeLessonTitle = title.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
        final fileName = '${safeCourseTitle}_${safeLessonTitle}_${DateTime.now().millisecondsSinceEpoch}.mp4';

        final localPath = await YoutubeVideoService.instance.downloadYoutubeVideo(
          videoUrl, fileName: fileName,
          onProgress: (progress) { if (mounted) setState(() => _downloadProgress = progress); },
        );

        if (localPath != null) {
          final videoId = await _downloadService.saveDownloadedVideoRecord(
            lessonId: lessonId, courseId: courseId, title: courseTitle ?? title,
            videoUrl: videoUrl, localPath: localPath, courseTitle: courseTitle ?? 'كورس $courseId',
            description: description.isNotEmpty ? description : title,
            durationText: lesson['duration']?.toString(), videoSource: 'youtube',
          );
          if (kDebugMode && videoId != null) log('YouTube video saved: $videoId');
          if (mounted) {
            setState(() { _isDownloading = false; _isDownloaded = true; _downloadProgress = 0; });
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم تحميل الفيديو', style: GoogleFonts.cairo()), backgroundColor: Colors.green));
          }
        } else {
          throw Exception('فشل تحميل الفيديو');
        }
        return;
      }

      final videoId = await _downloadService.downloadVideoWithManager(
        videoUrl: videoUrl, lessonId: lessonId, courseId: courseId, title: title,
        courseTitle: courseTitle, description: description,
        onProgress: (progress) { if (mounted) setState(() => _downloadProgress = progress); },
      );

      if (videoId != null) {
        if (mounted) {
          setState(() { _isDownloading = false; _isDownloaded = true; _downloadProgress = 0; });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم تحميل الفيديو', style: GoogleFonts.cairo()), backgroundColor: Colors.green));
        }
      } else {
        throw Exception('فشل تحميل الفيديو');
      }
    } catch (e) {
      if (mounted) {
        setState(() { _isDownloading = false; _downloadProgress = 0; });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('خطأ: ${e.toString().replaceFirst('Exception: ', '')}', style: GoogleFonts.cairo()), backgroundColor: Colors.red,
        ));
      }
    }
  }

  Widget _buildResourceItem(String title, String size, IconData icon, String url) {
    final isPdf = url.toLowerCase().contains('.pdf') || title.toLowerCase().contains('pdf') || icon == Icons.picture_as_pdf;
    return GestureDetector(
      onTap: url.isNotEmpty ? () { if (isPdf) context.push(RouteNames.pdfViewer, extra: {'pdfUrl': url, 'title': title}); } : null,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: const Color(0xFFF8F9FC), borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: Colors.red, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.foreground)),
              if (size.isNotEmpty) Text(size, style: GoogleFonts.cairo(fontSize: 11, color: AppColors.mutedForeground)),
            ]),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.purple.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(isPdf ? Icons.preview_rounded : Icons.download_rounded, color: AppColors.purple, size: 18),
          ),
        ]),
      ),
    );
  }

  Widget _buildNavButton(String text, IconData icon, bool isPrimary, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: isPrimary ? const LinearGradient(colors: [Color(0xFFD42535), Color(0xFFB01E2D)]) : null,
          color: isPrimary ? null : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isPrimary ? null : Border.all(color: Colors.grey[200]!),
          boxShadow: isPrimary ? [BoxShadow(color: AppColors.purple.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))] : null,
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (!isPrimary) Icon(icon, size: 18, color: AppColors.foreground),
          if (!isPrimary) const SizedBox(width: 8),
          Text(text, style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold, color: isPrimary ? Colors.white : AppColors.foreground)),
          if (isPrimary) const SizedBox(width: 8),
          if (isPrimary) Icon(icon, size: 18, color: Colors.white),
        ]),
      ),
    );
  }
}
