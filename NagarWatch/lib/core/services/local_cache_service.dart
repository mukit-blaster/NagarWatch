import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalCacheService {
  static LocalCacheService? _instance;
  static LocalCacheService get instance =>
      _instance ??= LocalCacheService._();
  LocalCacheService._();

  late SharedPreferences _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Cache data with optional TTL in minutes
  Future<void> setCache(String key, dynamic data, {int? ttlMinutes}) async {
    try {
      final json = jsonEncode(data);
      await _prefs.setString(key, json);

      if (ttlMinutes != null) {
        final expirationTime =
            DateTime.now().add(Duration(minutes: ttlMinutes));
        await _prefs.setString(
          '${key}_expiration',
          expirationTime.toIso8601String(),
        );
      }
    } catch (e) {
      print('Error caching data: $e');
    }
  }

  /// Get cached data
  T? getCache<T>(String key, {required T Function(dynamic) fromJson}) {
    try {
      // Check if cache has expired
      final expirationStr = _prefs.getString('${key}_expiration');
      if (expirationStr != null) {
        final expiration = DateTime.parse(expirationStr);
        if (DateTime.now().isAfter(expiration)) {
          removeCache(key);
          return null;
        }
      }

      final json = _prefs.getString(key);
      if (json == null) return null;

      final decoded = jsonDecode(json);
      return fromJson(decoded);
    } catch (e) {
      print('Error retrieving cache: $e');
      return null;
    }
  }

  /// Check if cache exists and is valid
  bool hasValidCache(String key) {
    try {
      final expirationStr = _prefs.getString('${key}_expiration');
      if (expirationStr != null) {
        final expiration = DateTime.parse(expirationStr);
        if (DateTime.now().isAfter(expiration)) {
          return false;
        }
      }
      return _prefs.containsKey(key);
    } catch (e) {
      return false;
    }
  }

  /// Remove cache entry
  Future<void> removeCache(String key) async {
    try {
      await _prefs.remove(key);
      await _prefs.remove('${key}_expiration');
    } catch (e) {
      print('Error removing cache: $e');
    }
  }

  /// Clear all cache
  Future<void> clearAll() async {
    try {
      await _prefs.clear();
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  /// Queue item for offline submission
  Future<void> queueOfflineItem(String queue, String id, Map<String, dynamic> data) async {
    try {
      final List<String> queueList = _prefs.getStringList('queue_$queue') ?? [];
      final item = {
        'id': id,
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
      };
      queueList.add(jsonEncode(item));
      await _prefs.setStringList('queue_$queue', queueList);
    } catch (e) {
      print('Error queuing offline item: $e');
    }
  }

  /// Get offline queue items
  List<Map<String, dynamic>> getOfflineQueue(String queue) {
    try {
      final List<String> queueList = _prefs.getStringList('queue_$queue') ?? [];
      return queueList.map((item) {
        return jsonDecode(item) as Map<String, dynamic>;
      }).toList();
    } catch (e) {
      print('Error retrieving offline queue: $e');
      return [];
    }
  }

  /// Mark offline item as synced and remove from queue
  Future<void> markItemSynced(String queue, String itemId) async {
    try {
      final List<String> queueList = _prefs.getStringList('queue_$queue') ?? [];
      final filteredList = queueList.where((item) {
        final data = jsonDecode(item) as Map<String, dynamic>;
        return data['id'] != itemId;
      }).toList();
      await _prefs.setStringList('queue_$queue', filteredList);
    } catch (e) {
      print('Error marking item as synced: $e');
    }
  }

  /// Clear offline queue
  Future<void> clearOfflineQueue(String queue) async {
    try {
      await _prefs.remove('queue_$queue');
    } catch (e) {
      print('Error clearing offline queue: $e');
    }
  }

  /// Check if there are pending offline items
  bool hasPendingItems(String queue) {
    try {
      final List<String> queueList = _prefs.getStringList('queue_$queue') ?? [];
      return queueList.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
