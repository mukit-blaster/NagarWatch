import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/location_service.dart';
import '../../authentication/providers/auth_provider.dart';
import '../providers/evidence_provider.dart';

class EvidenceUploadScreen extends StatefulWidget {
  final String projectId;
  final String projectName;
  const EvidenceUploadScreen({super.key, required this.projectId, required this.projectName});
  @override State<EvidenceUploadScreen> createState() => _State();
}

class _State extends State<EvidenceUploadScreen> {
  XFile? _image;
  final _desc = TextEditingController();
  bool _loading = false;
  double? _lat, _lng;
  DateTime _timestamp = DateTime.now();

  Future<void> _pickImage(ImageSource src) async {
    final img = await ImagePicker().pickImage(source: src, imageQuality: 80);
    if (img != null) {
      setState(() { _image = img; _timestamp = DateTime.now(); });
      final pos = await LocationService.getCurrentPosition();
      if (pos != null) setState(() { _lat = pos.latitude; _lng = pos.longitude; });
    }
  }

  Future<void> _submit() async {
    if (_image == null) { _snack('Please select a photo first.'); return; }
    setState(() => _loading = true);
    final auth = context.read<AuthProvider>();
    final ok = await context.read<EvidenceProvider>().addEvidence(
      projectId: widget.projectId,
      projectName: widget.projectName,
      description: _desc.text.isEmpty ? 'Photo evidence for ${widget.projectName}' : _desc.text,
      uploadedBy: auth.user?.email ?? 'unknown@user',
      uploaderName: auth.user?.name ?? 'Citizen',
      latitude: _lat,
      longitude: _lng,
      imageFile: _image!,
      wardId: context.read<AuthProvider>().user?.wardId,
    );
    if (mounted) {
      setState(() => _loading = false);
      if (ok) { _snack('Evidence uploaded successfully!'); Navigator.pop(context); }
      else {
        _snack(context.read<EvidenceProvider>().error ?? 'Upload failed');
      }
    }
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.bg,
    appBar: AppBar(title: const Text('Upload Evidence'), backgroundColor: Colors.white, foregroundColor: AppColors.textPrimary, elevation: 0),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.primary50, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.primary200)),
        child: Row(children: [const Icon(Icons.info_outline, color: AppColors.primary, size: 18), const SizedBox(width: 10), Expanded(child: Text('Project: ${widget.projectName}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)))]),
      ),
      const SizedBox(height: 20),
      const Text('Photo Evidence', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      const SizedBox(height: 10),
      GestureDetector(
        onTap: () => _showPicker(),
        child: Container(
          height: 180, width: double.infinity,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: _image != null ? AppColors.accent : AppColors.border, width: _image != null ? 2 : 1.5), color: AppColors.card),
          child: _image == null
            ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_photo_alternate_outlined, size: 48, color: AppColors.textTertiary), SizedBox(height: 8), Text('Tap to select photo', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500)), Text('Photo is auto-tagged with GPS & timestamp', style: TextStyle(color: AppColors.textTertiary, fontSize: 12))])
            : ClipRRect(borderRadius: BorderRadius.circular(14), child: kIsWeb
                ? const Center(child: Icon(Icons.check_circle_rounded, color: AppColors.accent, size: 48))
                : Image.file(File(_image!.path), fit: BoxFit.cover, width: double.infinity)),
        ),
      ),
      if (_image != null) ...[
        const SizedBox(height: 10),
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.accent50, borderRadius: BorderRadius.circular(12)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Row(children: [Icon(Icons.check_circle_rounded, color: AppColors.accentDark, size: 16), SizedBox(width: 6), Text('Evidence metadata attached:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.accentDark))]),
            const SizedBox(height: 6),
            Text('📅 ${_timestamp.toLocal().toString().substring(0, 19)}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            if (_lat != null) Text('📍 ${_lat!.toStringAsFixed(5)}, ${_lng!.toStringAsFixed(5)}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ]),
        ),
      ],
      const SizedBox(height: 20),
      const Text('Description (optional)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      const SizedBox(height: 8),
      TextField(controller: _desc, maxLines: 3, decoration: const InputDecoration(hintText: 'Describe what the photo shows…')),
      const SizedBox(height: 32),
      ElevatedButton.icon(
        onPressed: _loading ? null : _submit,
        icon: _loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.cloud_upload_outlined, color: Colors.white, size: 20),
        label: Text(_loading ? 'Uploading…' : 'Upload Evidence', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
      ),
      const SizedBox(height: 20),
    ]),
  );

  void _showPicker() => showModalBottomSheet(context: context, builder: (_) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
    ListTile(leading: const Icon(Icons.camera_alt_outlined), title: const Text('Camera'), onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); }),
    ListTile(leading: const Icon(Icons.photo_library_outlined), title: const Text('Gallery'), onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); }),
  ])));
}
