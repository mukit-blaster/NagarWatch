import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../../core/models/issue_model.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/services/local_cache_service.dart';

class IssueRepository {
  static const String _imgbbKey = '199aafbe7664b42caaf65189b5eb08cd';
  static const String _collection = 'issues';
  static const String _cacheKey = 'issues_cache';
  static const String _offlineQueue = 'issues_queue';
  static const int _cacheTTLMinutes = 15;

  final _firestore = FirestoreService.instance;
  final _cache = LocalCacheService.instance;

  /// Real-time stream of all issues
  Stream<List<IssueModel>> streamAllIssues() {
    return _firestore.streamCollection<IssueModel>(
      _collection,
      fromJson: (data, id) => IssueModel.fromJson({...data, '_id': id, 'id': id}),
      orderBy: 'createdAt',
      descending: true,
    );
  }

  /// Real-time stream of issues by ward
  Stream<List<IssueModel>> streamIssuesByWard(String wardId) {
    return _firestore.streamCollection<IssueModel>(
      _collection,
      fromJson: (data, id) => IssueModel.fromJson({...data, '_id': id, 'id': id}),
      where: [
        QueryConstraint(
          field: 'wardId',
          value: wardId,
          operator: '==',
        ),
      ],
    ).map((issues) {
      issues.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return issues;
    });
  }

  /// Real-time stream of issues by status
  Stream<List<IssueModel>> streamIssuesByStatus(String wardId, IssueStatus status) {
    return _firestore.streamCollection<IssueModel>(
      _collection,
      fromJson: (data, id) => IssueModel.fromJson({...data, '_id': id, 'id': id}),
      where: [
        QueryConstraint(
          field: 'wardId',
          value: wardId,
          operator: '==',
        ),
      ],
    ).map((issues) {
      final filtered = issues.where((i) => i.status == status).toList();
      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return filtered;
    });
  }

  /// Fetch all issues (one-time fetch with caching)
  Future<List<IssueModel>> fetchAll({String? wardId}) async {
    try {
      final cacheKey = wardId != null ? '${_cacheKey}_ward_$wardId' : _cacheKey;

      // Try cache first
      if (_cache.hasValidCache(cacheKey)) {
        return _cache.getCache<List<IssueModel>>(
          cacheKey,
          fromJson: (data) {
            return (data as List)
                .map((e) => IssueModel.fromJson(e as Map<String, dynamic>))
                .toList();
          },
        ) ?? [];
      }

      // Fetch from Firestore
      List<IssueModel> issues;
      if (wardId != null) {
        issues = await _firestore.fetchCollection<IssueModel>(
          _collection,
          fromJson: (data, id) => IssueModel.fromJson({...data, '_id': id, 'id': id}),
          where: [
            QueryConstraint(
              field: 'wardId',
              value: wardId,
              operator: '==',
            ),
          ],
        );
        issues.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      } else {
        issues = await _firestore.fetchCollection<IssueModel>(
          _collection,
          fromJson: (data, id) => IssueModel.fromJson({...data, '_id': id, 'id': id}),
          orderBy: 'createdAt',
          descending: true,
        );
      }

      // Cache the results
      await _cache.setCache(
        cacheKey,
        issues.map((i) => i.toJson()).toList(),
        ttlMinutes: _cacheTTLMinutes,
      );

      return issues;
    } catch (e) {
      print('Error fetching issues: $e');
      // Fallback to cache even if expired
      final cacheKey = wardId != null ? '${_cacheKey}_ward_$wardId' : _cacheKey;
      return _cache.getCache<List<IssueModel>>(
            cacheKey,
            fromJson: (data) {
              return (data as List)
                  .map((e) => IssueModel.fromJson(e as Map<String, dynamic>))
                  .toList();
            },
          ) ??
          [];
    }
  }

  /// Create issue with offline support
  Future<IssueModel> create({
    required String title,
    required String description,
    required String areaName,
    required String roadNumber,
    String? wardId,
    String? wardNumber,
    String? reportedBy,
    double? latitude,
    double? longitude,
    XFile? imageFile,
  }) async {
    String? imageUrl;
    if (imageFile != null) {
      try {
        imageUrl = await _uploadImage(imageFile);
      } catch (e) {
        print('Image upload failed: $e');
        // Continue without image
      }
    }

    final issueData = {
      'title': title,
      'description': description,
      'areaName': areaName,
      'roadNumber': roadNumber,
      if (wardId != null) 'wardId': wardId,
      if (wardNumber != null) 'wardNumber': wardNumber,
      if (reportedBy != null) 'reportedBy': reportedBy,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'status': 'submitted',
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };

    try {
      // Try to create online
      final docRef = await FirebaseFirestore.instance
          .collection(_collection)
          .add(issueData);

      // Clear cache on success
      await _cache.removeCache(_cacheKey);
      if (wardId != null) {
        await _cache.removeCache('${_cacheKey}_ward_$wardId');
      }

      return IssueModel.fromJson({...issueData, '_id': docRef.id, 'id': docRef.id});
    } catch (e) {
      print('Error creating issue online, queuing for offline sync: $e');
      // Queue for offline submission
      final offlineId = 'offline_${DateTime.now().millisecondsSinceEpoch}';
      await _cache.queueOfflineItem(_offlineQueue, offlineId, issueData);

      // Return local issue with offline marker
      return IssueModel.fromJson({
        ...issueData,
        '_id': offlineId,
        'id': offlineId,
        'status': 'pending_offline',
      });
    }
  }

  /// Update issue status
  Future<void> updateStatus(String id, IssueStatus status) async {
    try {
      await FirebaseFirestore.instance.collection(_collection).doc(id).update({
        'status': status.name,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      // Clear cache
      await _cache.removeCache(_cacheKey);
    } catch (e) {
      print('Error updating issue status: $e');
      rethrow;
    }
  }

  /// Update issue
  Future<void> updateIssue(String id, Map<String, dynamic> updates) async {
    try {
      await FirebaseFirestore.instance.collection(_collection).doc(id).update({
        ...updates,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      // Clear cache
      await _cache.removeCache(_cacheKey);
    } catch (e) {
      print('Error updating issue: $e');
      rethrow;
    }
  }

  /// Sync offline queue with Firestore
  Future<void> syncOfflineQueue() async {
    try {
      final pending = _cache.getOfflineQueue(_offlineQueue);
      print('Syncing ${pending.length} offline issues...');

      for (final item in pending) {
        try {
          final issueData = item['data'] as Map<String, dynamic>;
          final itemId = item['id'] as String;

          // Create document in Firestore
          final docRef = await FirebaseFirestore.instance
              .collection(_collection)
              .add(issueData);

          print('✓ Synced offline issue: $itemId -> ${docRef.id}');

          // Mark as synced
          await _cache.markItemSynced(_offlineQueue, itemId);
        } catch (e) {
          print('✗ Failed to sync issue: $e');
        }
      }

      // Clear cache after sync
      await _cache.removeCache(_cacheKey);

      print('✓ Offline queue sync completed');
    } catch (e) {
      print('Error syncing offline queue: $e');
    }
  }

  /// Get pending offline issues count
  int getPendingOfflineCount() {
    return _cache.getOfflineQueue(_offlineQueue).length;
  }

  /// Check if there are pending offline submissions
  bool hasPendingOfflineSubmissions() {
    return _cache.hasPendingItems(_offlineQueue);
  }

  /// Clear offline queue (use with caution)
  Future<void> clearOfflineQueue() async {
    await _cache.clearOfflineQueue(_offlineQueue);
  }

  /// Upload image to ImgBB
  Future<String> _uploadImage(XFile imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final encoded = base64Encode(bytes);
    final res = await http.post(
      Uri.parse('https://api.imgbb.com/1/upload?key=$_imgbbKey'),
      body: {
        'image': encoded,
        if (imageFile.name.isNotEmpty) 'name': imageFile.name,
      },
    );

    if (res.statusCode != 200) throw Exception('ImgBB upload failed');

    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    final url = (decoded['data'] as Map?)?['url']?.toString();
    if (url == null) throw Exception('ImgBB did not return URL');

    return url;
  }
}
