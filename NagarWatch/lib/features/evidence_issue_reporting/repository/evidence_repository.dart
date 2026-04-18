import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../../core/models/evidence_model.dart';
import '../../../core/services/firestore_service.dart';

class EvidenceRepository {
  static const String _imgbbKey = '199aafbe7664b42caaf65189b5eb08cd';
  static const String _collection = 'evidence';

  final _firestore = FirestoreService.instance;

  Stream<List<EvidenceModel>> streamEvidence({String? wardId}) {
    return _firestore
        .streamCollection<EvidenceModel>(
          _collection,
          fromJson: (data, id) => EvidenceModel.fromJson({...data, '_id': id, 'id': id}),
          where: (wardId != null && wardId.isNotEmpty)
              ? [
                  QueryConstraint(
                    field: 'wardId',
                    value: wardId,
                    operator: '==',
                  ),
                ]
              : null,
        )
        .map((items) {
          items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return items;
        });
  }

  Future<EvidenceModel> create({
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
    final imageUrl = await _uploadImage(imageFile);
    final now = DateTime.now().toIso8601String();

    final payload = {
      'projectId': projectId,
      if (projectName != null) 'projectName': projectName,
      if (description != null) 'description': description,
      'uploadedBy': uploadedBy,
      'uploaderName': uploaderName,
      if (wardId != null) 'wardId': wardId,
      'imageUrl': imageUrl,
      'latitude': latitude ?? 0.0,
      'longitude': longitude ?? 0.0,
      'timestamp': now,
      'status': 'pending',
      'createdAt': now,
      'updatedAt': now,
    };

    final docRef = await FirebaseFirestore.instance.collection(_collection).add(payload);
    return EvidenceModel.fromJson({...payload, '_id': docRef.id, 'id': docRef.id});
  }

  Future<void> updateStatus(String id, String status, {String? reason}) async {
    await FirebaseFirestore.instance.collection(_collection).doc(id).update({
      'status': status,
      if (reason != null && reason.isNotEmpty) 'rejectionReason': reason,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

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

    if (res.statusCode != 200) {
      throw Exception('ImgBB upload failed');
    }

    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    final url = (decoded['data'] as Map?)?['url']?.toString();
    if (url == null) {
      throw Exception('ImgBB did not return URL');
    }

    return url;
  }
}
