// Offline queue manager (FR-7.2)
import '../../../core/services/local_storage_service.dart';
import '../../../core/services/api_service.dart';

class OfflineQueueManager {
  final _storage = LocalStorageService.instance;
  final _api = ApiService.instance;

  Future<void> syncIssues() async {
    final pending = await _storage.getPendingIssues();
    for (final data in pending) {
      try {
        await _api.post('/issues', data);
        if (data['_offlineId'] != null) {
          await _storage.markIssueSynced(data['_offlineId'].toString());
        }
      } catch (_) {}
    }
  }

  Future<void> syncEvidence() async {
    final pending = await _storage.getPendingEvidence();
    for (final data in pending) {
      try {
        await _api.post('/evidence', data);
        if (data['_offlineId'] != null) {
          await _storage.markEvidenceSynced(data['_offlineId'].toString());
        }
      } catch (_) {}
    }
  }

  Future<void> syncAll() async {
    await syncIssues();
    await syncEvidence();
  }
}
