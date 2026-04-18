import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/services/api_service.dart';

class AuthorityApprovalRepository {
  static String get _baseUrl => ApiService.baseUrl;

  Future<List<Map<String, dynamic>>> getPendingRequests() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/auth/approval-requests'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List;
        return list.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to fetch requests: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching approval requests: $e');
    }
  }

  Future<void> approveRequest(String requestId) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/auth/approval-requests/$requestId/approve'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw Exception('Failed to approve: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error approving request: $e');
    }
  }

  Future<void> rejectRequest(String requestId, String reason) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/auth/approval-requests/$requestId/reject'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'reason': reason}),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw Exception('Failed to reject: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error rejecting request: $e');
    }
  }
}
