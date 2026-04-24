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
  });

  final bool isAr;
  final HomeBannerMediaType mediaType;
  final String mediaPath;
  final bool isAsset;
  final double height;
  final VoidCallback? onTap;

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
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFD42535), Color(0xFF8C1722)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
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
            Positioned(
              left: widget.isAr ? null : 20,
              right: widget.isAr ? 20 : null,
              top: 0,
              bottom: 0,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'MEDEX',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.isAr
                          ? 'منتجات طب أسنان\nمتميزة'
                          : 'Premium Dental\nProducts',
                      style: GoogleFonts.cairo(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.isAr
                          ? 'أفضل المنتجات من إيطاليا وتركيا وكوريا'
                          : 'Top products from Italy, Turkey & Korea',
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        widget.isAr ? 'تسوق الآن' : 'Shop Now',
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
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
