import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../core/services/download_manager.dart';

class YoutubeVideoService {
  YoutubeVideoService._();
  static final instance = YoutubeVideoService._();
  final YoutubeExplode _yt = YoutubeExplode();

  /// Get direct stream URL for playback (no YouTube UI).
  /// On iOS, filters for MP4 container only (H.264 + AAC) for AVPlayer compatibility.
  /// Returns null if unavailable.
  Future<String?> getStreamUrl(String youtubeUrl) async {
    try {
      if (kDebugMode) print('🎬 [getStreamUrl] Fetching video info: $youtubeUrl');
      final video = await _yt.videos.get(youtubeUrl);
      if (kDebugMode) print('🎬 [getStreamUrl] Got video id: ${video.id}');

      final manifest = await _yt.videos.streamsClient.getManifest(
        video.id,
        ytClients: Platform.isIOS
            ? [YoutubeApiClient.ios, YoutubeApiClient.android]
            : null,
      );

      final muxedList = manifest.muxed.toList();
      if (kDebugMode) {
        print('🎬 [getStreamUrl] Muxed streams: ${muxedList.length}');
        for (final s in muxedList) {
          print('   → ${s.qualityLabel} | ${s.container.name} | ${s.bitrate}');
        }
      }

      if (muxedList.isNotEmpty) {
        if (Platform.isIOS) {
          final mp4Streams = muxedList
              .where((s) => s.container == StreamContainer.mp4)
              .toList()
            ..sort((a, b) => b.bitrate.compareTo(a.bitrate));

          if (mp4Streams.isNotEmpty) {
            final stream = mp4Streams.first;
            if (kDebugMode) print('✅ [getStreamUrl] iOS MP4: ${stream.qualityLabel}');
            return stream.url.toString();
          }

          if (kDebugMode) print('⚠️ [getStreamUrl] No MP4 muxed for iOS, trying any muxed...');
        }

        final best = muxedList.withHighestBitrate();
        if (kDebugMode) print('✅ [getStreamUrl] Muxed: ${best.qualityLabel} (${best.container.name})');
        return best.url.toString();
      }

      if (kDebugMode) print('❌ [getStreamUrl] No muxed streams found');
      return null;
    } catch (e, st) {
      if (kDebugMode) {
        print('❌ [getStreamUrl] Error: $e');
        print('❌ [getStreamUrl] Stack: $st');
      }
      return null;
    }
  }

  /// Extract a YouTube video ID from a URL. Returns null if not a valid YouTube URL.
  String? extractVideoId(String url) {
    try {
      return VideoId(url).value;
    } catch (_) {
      return null;
    }
  }

  /// Download YouTube video and return local file path (or null on fail)
  Future<String?> downloadYoutubeVideo(
    String youtubeUrl, {
    required Function(int progress) onProgress,
    String? fileName,
  }) async {
    try {
      final video = await _yt.videos.get(youtubeUrl);
      final manifest = await _yt.videos.streamsClient.getManifest(video.id);

      final streamInfo = manifest.muxed.withHighestBitrate();
      final directUrl = streamInfo.url.toString();
      if (kDebugMode) print('🎥 YouTube direct stream URL: $directUrl');

      final localPath = await DownloadManager.download(
        directUrl,
        name: fileName ?? 'yt_${video.id}.mp4',
        onDownload: onProgress,
        isOpen: false,
      );

      return localPath;
    } catch (e) {
      if (kDebugMode) print('❌ Error downloading YouTube video: $e');
      return null;
    }
  }

  Future<void> dispose() async {
    _yt.close();
  }
}
