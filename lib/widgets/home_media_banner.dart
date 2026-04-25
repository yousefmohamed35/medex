import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import '../core/design/app_colors.dart';

enum HomeBannerMediaType { image, video }

class HomeMediaBanner extends StatefulWidget {
  const HomeMediaBanner({
    super.key,
    required this.isAr,
    required this.mediaType,
    required this.mediaPath,
    this.isAsset = true,
    this.height = 200,
    this.onTap,
    this.badgeText,
    this.titleText,
    this.subtitleText,
    this.primaryButtonText,
    this.playButtonText,
    this.showPlayButton = true,
  });

  final bool isAr;
  final HomeBannerMediaType mediaType;
  final String mediaPath;
  final bool isAsset;
  final double height;
  final VoidCallback? onTap;
  final String? badgeText;
  final String? titleText;
  final String? subtitleText;
  final String? primaryButtonText;
  final String? playButtonText;
  final bool showPlayButton;

  @override
  State<HomeMediaBanner> createState() => _HomeMediaBannerState();
}

class _HomeMediaBannerState extends State<HomeMediaBanner> {
  VideoPlayerController? _videoController;
  bool _isVideoReady = false;
  int _videoInitEpoch = 0;

  @override
  void initState() {
    super.initState();
    if (widget.mediaType == HomeBannerMediaType.video) {
      _initVideo();
    }
  }

  @override
  void didUpdateWidget(covariant HomeMediaBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    final mediaChanged = oldWidget.mediaType != widget.mediaType ||
        oldWidget.mediaPath != widget.mediaPath ||
        oldWidget.isAsset != widget.isAsset;
    if (mediaChanged) {
      _disposeVideo();
      if (widget.mediaType == HomeBannerMediaType.video) {
        _initVideo();
      }
    }
  }

  Future<void> _initVideo() async {
    final initEpoch = ++_videoInitEpoch;
    final controller = widget.isAsset
        ? VideoPlayerController.asset(widget.mediaPath)
        : VideoPlayerController.networkUrl(Uri.parse(widget.mediaPath));
    _videoController = controller;

    try {
      await controller.initialize();
      if (!mounted || initEpoch != _videoInitEpoch) {
        await controller.dispose();
        return;
      }

      await controller.setLooping(true);
      await controller.setVolume(0);
      await controller.play();
      if (!mounted || initEpoch != _videoInitEpoch) return;

      setState(() {
        _isVideoReady = true;
      });
    } catch (e) {
      // Keep Home screen alive even if banner media is invalid/unavailable.
      if (controller == _videoController) {
        _disposeVideo();
      } else {
        await controller.dispose();
      }
      debugPrint('HomeMediaBanner video init failed: $e');
    }
  }

  void _disposeVideo() {
    _videoInitEpoch++;
    _videoController?.dispose();
    _videoController = null;
    _isVideoReady = false;
  }

  @override
  void dispose() {
    _disposeVideo();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        height: widget.height,
        decoration: BoxDecoration(
          color: const Color(0xFF171717),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: _buildMedia(),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF272727).withOpacity(0.72),
                      const Color(0xFF3F0000).withOpacity(0.88),
                    ],
                  ),
                ),
              ),
            ),
            if (widget.showPlayButton)
              const Center(
                child: _CenteredPlayButton(),
              ),
            Positioned(
              left: widget.isAr ? null : 18,
              right: widget.isAr ? 18 : null,
              bottom: 14,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.72,
                child: Column(
                  crossAxisAlignment:
                      widget.isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        (widget.badgeText?.trim().isNotEmpty ?? false)
                            ? widget.badgeText!.trim()
                            : (widget.isAr ? 'مرحبا في ميديكس' : 'WELCOME TO MEDEX'),
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      (widget.titleText?.trim().isNotEmpty ?? false)
                          ? widget.titleText!.trim()
                          : (widget.isAr
                              ? 'أول منصة ذكية\nلزراعة الأسنان'
                              : 'The First Smart Dental Implant Platform'),
                      style: GoogleFonts.cairo(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: widget.isAr ? TextAlign.right : TextAlign.left,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      (widget.subtitleText?.trim().isNotEmpty ?? false)
                          ? widget.subtitleText!.trim()
                          : (widget.isAr ? 'دقيقتان - إنجليزي / عربي' : '2 min · English / Arabic'),
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

  Widget _buildMedia() {
    if (widget.mediaType == HomeBannerMediaType.video) {
      if (_videoController == null || !_isVideoReady) {
        return Container(color: Colors.black.withOpacity(0.15));
      }
      return FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _videoController!.value.size.width,
          height: _videoController!.value.size.height,
          child: VideoPlayer(_videoController!),
        ),
      );
    }

    if (widget.isAsset) {
      return Image.asset(
        widget.mediaPath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(color: Colors.black12),
      );
    }

    return Image.network(
      widget.mediaPath,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(color: Colors.black12),
    );
  }
}

class _CenteredPlayButton extends StatelessWidget {
  const _CenteredPlayButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.play_arrow_rounded,
        color: AppColors.primary,
        size: 34,
      ),
    );
  }
}
