import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
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

  String _selectedCategory = "Road";
  File? _selectedImage;

  final categories = [
    {"name": "Road", "icon": Icons.construction, "color": Colors.orange},
    {"name": "Drainage", "icon": Icons.water, "color": Colors.blue},
    {"name": "Lighting", "icon": Icons.lightbulb, "color": Colors.green},
    {"name": "Waste", "icon": Icons.delete, "color": Colors.red},
    {"name": "Water", "icon": Icons.opacity, "color": Colors.indigo},
    {"name": "Other", "icon": Icons.more_horiz, "color": Colors.grey},
  ];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _submitIssue() {
    final title = _selectedCategory == "Other"
        ? _otherController.text
        : _selectedCategory;

    context.read<IssueProvider>().addIssue(
      title: title,
      description: _descController.text,
      imageUrl: _selectedImage?.path,
      areaName: _areaController.text,
      roadNumber: _roadController.text,
    );

    widget.onSubmitted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Report Issue")),

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
              "Select category and describe the problem",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            const Text(
              "Category",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,

              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.1,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),

              itemBuilder: (context, index) {
                final item = categories[index];
                final isSelected = _selectedCategory == item["name"];

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = item["name"] as String;
                    });
                  },

                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.grey.shade300,
                        width: 2,
                      ),
                      color: Colors.white,
                    ),

                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundColor: (item["color"] as Color).withOpacity(
                            .15,
                          ),
                          child: Icon(
                            item["icon"] as IconData,
                            color: item["color"] as Color,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          item["name"] as String,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            /// OTHER CATEGORY FIELD
            if (_selectedCategory == "Other") ...[
              const SizedBox(height: 16),

              TextField(
                controller: _otherController,
                decoration: InputDecoration(
                  hintText: "Enter issue type",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),

            const Text(
              "Description",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: _descController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Describe the issue...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Issue Location",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: _areaController,
              decoration: InputDecoration(
                hintText: "Area name",
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
                hintText: "Road number",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Upload Photo",
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
                          Text("Tap to upload image"),
                          Text(
                            "JPG, PNG up to 10MB",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      ),
              ),
            ),

            const SizedBox(height: 30),

            /// SUBMIT BUTTON
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
                    onTap: _submitIssue,

                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            "Submit Report",
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
          ],
        ),
      ),
    );
  }
}
