import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../authentication/providers/auth_provider.dart';
import '../providers/issue_provider.dart';

class ReportIssueScreen extends StatefulWidget {
  final VoidCallback onSubmitted;

  const ReportIssueScreen({super.key, required this.onSubmitted});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  final _descController = TextEditingController();
  final _areaController = TextEditingController();
  final _roadController = TextEditingController();
  final _otherController = TextEditingController();

  String _selectedCategory = 'Road';
  XFile? _selectedImage;
  bool _isSubmitting = false;

  final categories = [
    {'name': 'Road', 'icon': Icons.construction, 'color': Colors.orange},
    {'name': 'Drainage', 'icon': Icons.water, 'color': Colors.blue},
    {'name': 'Lighting', 'icon': Icons.lightbulb, 'color': Colors.green},
    {'name': 'Waste', 'icon': Icons.delete, 'color': Colors.red},
    {'name': 'Water', 'icon': Icons.opacity, 'color': Colors.indigo},
    {'name': 'Other', 'icon': Icons.more_horiz, 'color': Colors.grey},
  ];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    _areaController.dispose();
    _roadController.dispose();
    _otherController.dispose();
    super.dispose();
  }

  Future<void> _submitIssue() async {
    if (_isSubmitting) {
      return;
    }

    final title = _selectedCategory == 'Other'
        ? _otherController.text
        : _selectedCategory;

    if (title.trim().isEmpty ||
        _descController.text.trim().isEmpty ||
        _areaController.text.trim().isEmpty ||
        _roadController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final success = await context.read<IssueProvider>().addIssue(
      title: title,
      description: _descController.text,
      imageFile: _selectedImage,
      areaName: _areaController.text,
      roadNumber: _roadController.text,
      wardId: context.read<AuthProvider>().user?.wardId,
      reportedBy: context.read<AuthProvider>().user?.email,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      widget.onSubmitted();
      return;
    }

    final errorMessage =
        context.read<IssueProvider>().errorMessage ??
        'Could not submit the report.';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(errorMessage)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Issue')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "What's the issue?",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Select category and describe the problem',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            const Text(
              'Category',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: categories.map((item) {
                final isSelected = _selectedCategory == item['name'];

                return ChoiceChip(
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      _selectedCategory = item['name'] as String;
                    });
                  },
                  avatar: CircleAvatar(
                    backgroundColor: (item['color'] as Color).withOpacity(.15),
                    child: Icon(
                      item['icon'] as IconData,
                      size: 18,
                      color: item['color'] as Color,
                    ),
                  ),
                  label: Text(item['name'] as String),
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xff334155),
                  ),
                  selectedColor: const Color(0xff2B4EFF),
                  backgroundColor: Colors.white,
                  shape: StadiumBorder(
                    side: BorderSide(
                      color: isSelected
                          ? const Color(0xff2B4EFF)
                          : Colors.grey.shade300,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                );
              }).toList(),
            ),
            if (_selectedCategory == 'Other') ...[
              const SizedBox(height: 16),
              TextField(
                controller: _otherController,
                decoration: InputDecoration(
                  hintText: 'Enter issue type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            const Text(
              'Description',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Describe the issue...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Issue Location',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _areaController,
              decoration: InputDecoration(
                hintText: 'Area name',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _roadController,
              decoration: InputDecoration(
                hintText: 'Road number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Upload Photo',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: _selectedImage == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate, size: 40),
                          SizedBox(height: 6),
                          Text('Tap to upload image'),
                          Text(
                            'JPG, PNG up to 10MB',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      )
                    : Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              size: 40,
                              color: Colors.green,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _selectedImage?.name ?? 'Image selected',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Ready to upload to ImgBB',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xffFF4B4B), Color(0xffFF2E2E)],
                  ),
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(.4),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(40),
                    onTap: _isSubmitting ? null : _submitIssue,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  color: Colors.white,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.send, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    'Submit Report',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
