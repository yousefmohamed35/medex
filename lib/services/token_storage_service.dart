import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for storing and retrieving authentication tokens.
/// Uses file fallback on iOS when SharedPreferences channel fails so session persists after app restart.
class TokenStorageService {
  TokenStorageService._();

  static final TokenStorageService instance = TokenStorageService._();

  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUser = 'user_data';
  static const String _keyUserRole = 'user_role';

  static const String _authFileName = '.auth_tokens';

  /// In-memory cache; when prefs fail we also persist to file.
  static final Map<String, String> _memory = {};

  static bool _fileLoaded = false;

  static bool _isChannelError(PlatformException e) =>
      e.code == 'channel-error' &&
      (e.message?.contains('shared_preferences') == true ||
          e.message?.contains('LegacyUserDefaults') == true);

  static Future<File> _authFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_authFileName');
  }

  /// Load tokens from file into _memory (once per session).
  static Future<void> _loadFromFileIfNeeded() async {
    if (_fileLoaded) return;
    _fileLoaded = true;
    try {
      final file = await _authFile();
      if (!await file.exists()) return;
      final content = await file.readAsString();
      if (content.isEmpty) return;
      final map = jsonDecode(content) as Map<String, dynamic>?;
      if (map == null) return;
      for (final e in map.entries) {
        if (e.value is String) _memory[e.key] = e.value as String;
      }
      if (kDebugMode && _memory[_keyAccessToken] != null) {
        print('🔑 Loaded tokens from file (session restored)');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Could not load auth file: $e');
      }
    }
  }

  /// Persist _memory to file (when prefs unavailable).
  static Future<void> _persistMemoryToFile() async {
    try {
      final file = await _authFile();
      final map = <String, String>{};
      for (final k in [_keyAccessToken, _keyRefreshToken, _keyUser, _keyUserRole]) {
        final v = _memory[k];
        if (v != null && v.isNotEmpty) map[k] = v;
      }
      if (map.isEmpty) {
        if (await file.exists()) await file.delete();
        return;
      }
      await file.writeAsString(jsonEncode(map));
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Could not persist auth to file: $e');
      }
    }
  }

  /// Save to prefs; on channel-error save to memory + file so session persists.
  static Future<void> _saveWithFallback(String key, String value) async {
    for (int attempt = 0; attempt < 2; attempt++) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(key, value);
        _memory[key] = value;
        return;
      } on PlatformException catch (e) {
        if (_isChannelError(e) && attempt == 0) {
          await Future.delayed(const Duration(milliseconds: 400));
          continue;
        }
        if (_isChannelError(e)) {
          _memory[key] = value;
          await _persistMemoryToFile();
          if (kDebugMode) {
            print('⚠️ Tokens saved to file (session will persist after restart)');
          }
          return;
        }
        rethrow;
      }
    }
  }

  Future<void> saveAccessToken(String token) async {
    await _saveWithFallback(_keyAccessToken, token);
  }

  Future<String?> getAccessToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString(_keyAccessToken) ?? _memory[_keyAccessToken];
      if (token == null) {
        await _loadFromFileIfNeeded();
        token = _memory[_keyAccessToken];
      }
      if (kDebugMode && token != null) {
        print('🔑 Retrieved token from storage (length: ${token.length})');
      } else if (kDebugMode) {
        print('🔑 No token found in storage');
      }
      return token;
    } on PlatformException catch (e) {
      if (_isChannelError(e)) {
        await _loadFromFileIfNeeded();
        return _memory[_keyAccessToken];
      }
      rethrow;
    }
  }

  Future<void> saveRefreshToken(String token) async {
    await _saveWithFallback(_keyRefreshToken, token);
  }

  Future<String?> getRefreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString(_keyRefreshToken) ?? _memory[_keyRefreshToken];
      if (token == null) {
        await _loadFromFileIfNeeded();
        token = _memory[_keyRefreshToken];
      }
      return token;
    } on PlatformException catch (e) {
      if (_isChannelError(e)) {
        await _loadFromFileIfNeeded();
        return _memory[_keyRefreshToken];
      }
      rethrow;
    }
  }

  /// Save tokens (to prefs or, on iOS channel-error, to memory + file so session persists).
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    if (kDebugMode) {
      print('💾 TokenStorageService.saveTokens called');
      print('  accessToken length: ${accessToken.length}');
      print('  refreshToken length: ${refreshToken.length}');
    }

    if (accessToken.isEmpty) {
      throw Exception('Access token cannot be empty');
    }

    await _saveWithFallback(_keyAccessToken, accessToken);
    await _saveWithFallback(_keyRefreshToken, refreshToken);

    final saved = await getAccessToken();
    if (kDebugMode) {
      if (saved != null && saved == accessToken) {
        print('✅ Token saved successfully');
      } else {
        print('⚠️ Token verification: ${saved != null ? "ok" : "failed"}');
      }
    }
  }

  Future<void> saveUserRole(String role) async {
    await _saveWithFallback(_keyUserRole, role);
  }

  Future<String?> getUserRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var role = prefs.getString(_keyUserRole) ?? _memory[_keyUserRole];
      if (role == null) {
        await _loadFromFileIfNeeded();
        role = _memory[_keyUserRole];
      }
      return role;
    } on PlatformException catch (e) {
      if (_isChannelError(e)) {
        await _loadFromFileIfNeeded();
        return _memory[_keyUserRole];
      }
      rethrow;
    }
  }

  Future<void> clearTokens() async {
    _memory.remove(_keyAccessToken);
    _memory.remove(_keyRefreshToken);
    _memory.remove(_keyUser);
    _memory.remove(_keyUserRole);
    _fileLoaded = true;
    try {
      final file = await _authFile();
      if (await file.exists()) await file.delete();
    } catch (_) {}
    try {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.remove(_keyAccessToken),
        prefs.remove(_keyRefreshToken),
        prefs.remove(_keyUser),
        prefs.remove(_keyUserRole),
      ]);
    } on PlatformException catch (_) {
      // ignore when channel fails
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
