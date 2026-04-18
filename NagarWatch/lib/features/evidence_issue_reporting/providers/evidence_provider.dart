import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/models/evidence_model.dart';
import '../repository/evidence_repository.dart';

class EvidenceProvider extends ChangeNotifier {
  final _repo = EvidenceRepository();

  List<EvidenceModel> _items = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<EvidenceModel>>? _sub;

  List<EvidenceModel> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void streamEvidence({String? wardId}) {
    _setLoading(true);
    _sub?.cancel();
    _sub = _repo.streamEvidence(wardId: wardId).listen(
      (items) {
        _items = items;
        _error = null;
        _setLoading(false);
      },
      onError: (e) {
        _error = e.toString();
        _setLoading(false);
      },
    );
  }

  Future<bool> addEvidence({
    required String projectId,
    String? projectName,
    String? description,
    required String uploadedBy,
    required String uploaderName,
    String? wardId,
    required XFile imageFile,
    double? latitude,
    double? longitude,
  }) async {
    _setLoading(true);
    try {
      final created = await _repo.create(
        projectId: projectId,
        projectName: projectName,
        description: description,
        uploadedBy: uploadedBy,
        uploaderName: uploaderName,
        wardId: wardId,
        imageFile: imageFile,
        latitude: latitude,
        longitude: longitude,
      );

      _items = [created, ..._items];
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateStatus(String id, String status, {String? reason}) async {
    try {
      await _repo.updateStatus(id, status, reason: reason);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
