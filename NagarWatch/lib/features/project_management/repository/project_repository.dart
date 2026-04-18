import 'dart:math' show sin, cos, sqrt, atan2;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/project_model.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/services/local_cache_service.dart';

class ProjectRepository {
  final _firestore = FirestoreService.instance;
  final _cache = LocalCacheService.instance;

  static const String _collection = 'projects';
  static const String _cacheKey = 'projects_cache';
  static const int _cacheTTLMinutes = 30;

  /// Real-time stream of all projects
  Stream<List<ProjectModel>> streamAllProjects() {
    return _firestore.streamCollection<ProjectModel>(
      _collection,
      fromJson: (data, id) => ProjectModel.fromMap({...data, 'id': id}),
      orderBy: 'createdAt',
      descending: true,
    );
  }

  /// Real-time stream of projects by ward
  Stream<List<ProjectModel>> streamProjectsByWard(String wardId) {
    return _firestore.streamCollection<ProjectModel>(
      _collection,
      fromJson: (data, id) => ProjectModel.fromMap({...data, 'id': id}),
      where: [
        QueryConstraint(
          field: 'wardId',
          value: wardId,
          operator: '==',
        ),
      ],
      orderBy: 'createdAt',
      descending: true,
    );
  }

  /// Real-time stream of projects by status
  Stream<List<ProjectModel>> streamProjectsByStatus(String wardId, ProjectStatus status) {
    return _firestore.streamCollection<ProjectModel>(
      _collection,
      fromJson: (data, id) => ProjectModel.fromMap({...data, 'id': id}),
      where: [
        QueryConstraint(
          field: 'wardId',
          value: wardId,
          operator: '==',
        ),
        QueryConstraint(
          field: 'status',
          value: status.name,
          operator: '==',
        ),
      ],
      orderBy: 'createdAt',
      descending: true,
    );
  }

  /// Fetch all projects (one-time fetch with caching)
  Future<List<ProjectModel>> fetchAll() async {
    try {
      // Try cache first
      if (_cache.hasValidCache(_cacheKey)) {
        return _cache.getCache<List<ProjectModel>>(
          _cacheKey,
          fromJson: (data) {
            return (data as List)
                .map((e) => ProjectModel.fromMap(e as Map<String, dynamic>))
                .toList();
          },
        ) ?? [];
      }

      // Fetch from Firestore
      final projects = await _firestore.fetchCollection<ProjectModel>(
        _collection,
        fromJson: (data, id) => ProjectModel.fromMap({...data, 'id': id}),
        orderBy: 'createdAt',
        descending: true,
      );

      // Cache the results
      await _cache.setCache(
        _cacheKey,
        projects.map((p) => p.toMap()).toList(),
        ttlMinutes: _cacheTTLMinutes,
      );

      return projects;
    } catch (e) {
      print('Error fetching projects: $e');
      // Fallback to cache even if expired
      return _cache.getCache<List<ProjectModel>>(
            _cacheKey,
            fromJson: (data) {
              return (data as List)
                  .map((e) => ProjectModel.fromMap(e as Map<String, dynamic>))
                  .toList();
            },
          ) ??
          [];
    }
  }

  /// Fetch projects by ward (one-time fetch with caching)
  Future<List<ProjectModel>> fetchByWard(String wardId) async {
    try {
      final cacheKey = '${_cacheKey}_ward_$wardId';

      // Try cache first
      if (_cache.hasValidCache(cacheKey)) {
        return _cache.getCache<List<ProjectModel>>(
          cacheKey,
          fromJson: (data) {
            return (data as List)
                .map((e) => ProjectModel.fromMap(e as Map<String, dynamic>))
                .toList();
          },
        ) ?? [];
      }

      // Fetch from Firestore
      final projects = await _firestore.fetchCollection<ProjectModel>(
        _collection,
        fromJson: (data, id) => ProjectModel.fromMap({...data, 'id': id}),
        where: [
          QueryConstraint(
            field: 'wardId',
            value: wardId,
            operator: '==',
          ),
        ],
        orderBy: 'createdAt',
        descending: true,
      );

      // Cache the results
      await _cache.setCache(
        cacheKey,
        projects.map((p) => p.toMap()).toList(),
        ttlMinutes: _cacheTTLMinutes,
      );

      return projects;
    } catch (e) {
      print('Error fetching projects by ward: $e');
      return [];
    }
  }

  /// Fetch nearby projects (for geofencing)
  Future<List<ProjectModel>> fetchNearby(double lat, double lng,
      {double radiusKm = 5}) async {
    try {
      // Note: Firestore doesn't support geographic queries directly
      // Fetch all projects and filter client-side
      final projects = await _firestore.fetchCollection<ProjectModel>(
        _collection,
        fromJson: (data, id) => ProjectModel.fromMap({...data, 'id': id}),
      );

      return projects.where((p) {
        if (p.longitude == null) return false;
        final distance = _calculateDistance(lat, lng, p.latitude, p.longitude);
        return distance <= radiusKm;
      }).toList();
    } catch (e) {
      print('Error fetching nearby projects: $e');
      return [];
    }
  }

  /// Create project
  Future<ProjectModel> create(ProjectModel project) async {
    try {
      final docRef = await FirebaseFirestore.instance
          .collection(_collection)
          .add(project.toMap());

      // Clear cache
      await _cache.removeCache(_cacheKey);
      await _cache.removeCache('${_cacheKey}_ward_${project.wardId}');

      return ProjectModel.fromMap({...project.toMap(), 'id': docRef.id});
    } catch (e) {
      print('Error creating project: $e');
      rethrow;
    }
  }

  /// Update project
  Future<ProjectModel> update(String id, Map<String, dynamic> updates) async {
    try {
      await FirebaseFirestore.instance
          .collection(_collection)
          .doc(id)
          .update({...updates, 'updatedAt': DateTime.now().toIso8601String()});

      // Clear cache
      await _cache.removeCache(_cacheKey);

      // Fetch updated project
      final doc = await FirebaseFirestore.instance
          .collection(_collection)
          .doc(id)
          .get();
      return ProjectModel.fromMap({...doc.data() ?? {}, 'id': doc.id});
    } catch (e) {
      print('Error updating project: $e');
      rethrow;
    }
  }

  /// Delete project
  Future<void> delete(String id) async {
    try {
      await FirebaseFirestore.instance.collection(_collection).doc(id).delete();

      // Clear cache
      await _cache.removeCache(_cacheKey);
    } catch (e) {
      print('Error deleting project: $e');
      rethrow;
    }
  }

  /// Calculate distance between two coordinates (in km)
  double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371; // km
    final double dLat = _toRadians(lat2 - lat1);
    final double dLng = _toRadians(lng2 - lng1);
    final double a = (sin(dLat / 2) * sin(dLat / 2)) +
        (cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLng / 2) *
            sin(dLng / 2));
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degrees) => degrees * (3.14159265359 / 180);
}
