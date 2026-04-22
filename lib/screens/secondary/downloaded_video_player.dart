import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/design/app_colors.dart';

class DownloadedVideoPlayer extends StatefulWidget {
  final String videoPath;
  final String videoTitle;

  const DownloadedVideoPlayer({
    super.key,
    required this.videoPath,
    required this.videoTitle,
  });

  @override
  State<DownloadedVideoPlayer> createState() => _DownloadedVideoPlayerState();
}

class _DownloadedVideoPlayerState extends State<DownloadedVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isLoading = true;
  bool _isPlaying = false;
  bool _showControls = true;
  Timer? _hideControlsTimer;
  Timer? _positionTimer;
  bool _isFullscreen = false;
  double _playbackSpeed = 1.0;
  static const List<double> _speedOptions = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() {
    final file = File(widget.videoPath);
    if (!file.existsSync()) {
      if (kDebugMode) print('Video file does not exist: ${widget.videoPath}');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ملف الفيديو غير موجود', style: GoogleFonts.cairo()),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (kDebugMode) {
      try {
        final fileSize = file.lengthSync();
        final ext = widget.videoPath.split('.').last.toLowerCase();
        print('Local video file -> size: $fileSize bytes, ext: .$ext');
      } catch (e) {
        print('Error reading video file info: $e');
      }
    }

    _controller = VideoPlayerController.file(file);
    _controller!.initialize().then((_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isPlaying = false;
        });
        _controller!.addListener(_videoPlayerListener);
      }
    }).catchError((error) {
      if (kDebugMode) print('Error initializing video controller: $error');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحميل الفيديو', style: GoogleFonts.cairo()),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  void _videoPlayerListener() {
    if (_controller == null || !mounted) return;
    final isPlaying = _controller!.value.isPlaying;
    if (isPlaying != _isPlaying) {
      setState(() => _isPlaying = isPlaying);
      if (isPlaying) {
        _positionTimer?.cancel();
        _positionTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
          if (mounted && _controller != null) setState(() {});
        });
      } else {
        _positionTimer?.cancel();
        _positionTimer = null;
      }
    }
  }

  void _togglePlayPause() {
    if (_controller == null) return;
    if (_controller!.value.isPlaying) {
      _controller!.pause();
    } else {
      _controller!.play();
    }
    _startHideControlsTimer();
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
    if (_controller == null) return;
    final pos = _controller!.value.position;
    final dur = _controller!.value.duration;
    final target = pos + const Duration(seconds: 10);
    _controller!.seekTo(target > dur ? dur : target);
    _startHideControlsTimer();
  }

  void _skipBackward() {
    if (_controller == null) return;
    final pos = _controller!.value.position;
    final target = pos - const Duration(seconds: 10);
    _controller!.seekTo(target < Duration.zero ? Duration.zero : target);
    _startHideControlsTimer();
  }

  void _changeSpeed(double speed) {
    if (_controller == null) return;
    _controller!.setPlaybackSpeed(speed);
    setState(() => _playbackSpeed = speed);
    _startHideControlsTimer();
  }

  void _showSpeedPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
            ),
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

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return d.inHours > 0 ? '${d.inHours}:$m:$s' : '$m:$s';
  }

  @override
  void dispose() {
    _positionTimer?.cancel();
    _hideControlsTimer?.cancel();
    _controller?.removeListener(_videoPlayerListener);
    _controller?.dispose();
    _controller = null;
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

    if (_isFullscreen) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: _buildVideoPlayer(isFullscreen: true),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Header
            Container(
              color: Colors.black,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                left: 16, right: 16, bottom: 8,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
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
                    child: Text(
                      widget.videoTitle,
                      style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            // Video
            Expanded(
              child: Container(
                color: Colors.black,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.purple))
                    : _controller != null && _controller!.value.isInitialized
                        ? _buildVideoPlayer(isFullscreen: false)
                        : _buildErrorState(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer({required bool isFullscreen}) {
    if (_controller == null || !_controller!.value.isInitialized) {
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
              aspectRatio: _controller!.value.aspectRatio,
              child: VideoPlayer(_controller!),
            ),
          ),
          if (_showControls)
            Positioned.fill(child: _buildControlsOverlay(isFullscreen: isFullscreen)),
        ],
      ),
    );
  }

  Widget _buildControlsOverlay({required bool isFullscreen}) {
    return Container(
      color: Colors.black45,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: isFullscreen ? MediaQuery.of(context).padding.top + 8 : 4,
              left: 12, right: 12,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _skipBackward,
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Center(
                      child: Icon(Icons.replay_10_rounded, color: Colors.white, size: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 32),
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
                GestureDetector(
                  onTap: _skipForward,
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Center(
                      child: Icon(Icons.forward_10_rounded, color: Colors.white, size: 28),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 16, right: 16,
              bottom: isFullscreen ? MediaQuery.of(context).padding.bottom + 8 : 8,
            ),
            child: Row(
              children: [
                Text(_formatDuration(_controller!.value.position),
                    style: GoogleFonts.cairo(color: Colors.white, fontSize: 12)),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: VideoProgressIndicator(
                      _controller!,
                      allowScrubbing: true,
                      colors: const VideoProgressColors(
                        playedColor: AppColors.purple,
                        bufferedColor: Colors.white30,
                        backgroundColor: Colors.white10,
                      ),
                    ),
                  ),
                ),
                Text(_formatDuration(_controller!.value.duration),
                    style: GoogleFonts.cairo(color: Colors.white, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.white54, size: 64),
          const SizedBox(height: 16),
          Text(
            'خطأ في تحميل الفيديو',
            style: GoogleFonts.cairo(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.purple,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('رجوع', style: GoogleFonts.cairo(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
