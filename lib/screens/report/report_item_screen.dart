import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/item_service.dart';
import '../../services/storage_service.dart';
import '../../theme/app_theme.dart';

class ReportItemScreen extends StatefulWidget {
  final String initialType; // 'lost' | 'found'

  const ReportItemScreen({super.key, this.initialType = 'lost'});

  @override
  State<ReportItemScreen> createState() => _ReportItemScreenState();
}

class _ReportItemScreenState extends State<ReportItemScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();
  final storageController = TextEditingController();

  final ImagePicker picker = ImagePicker();
  File? selectedImage;

  late String type;
  String category = 'Electronics';
  bool loading = false;

  // Lost-item wizard state
  int currentStep = 0;
  final List<String> stepLabels = const ['Basic Info', 'Details', 'Photos'];

  final List<String> categories = const [
    'Electronics',
    'Keys',
    'Wallet',
    'Books',
    'ID Cards',
    'Clothing',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    type = widget.initialType;
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    storageController.dispose();
    super.dispose();
  }

  Future<void> takePhoto() async {
    final XFile? image = await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (image != null) setState(() => selectedImage = File(image.path));
  }

  Future<void> chooseFromStorage() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image != null) setState(() => selectedImage = File(image.path));
  }

  void _showPickerSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: AppTheme.navy),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(sheetContext);
                takePhoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: AppTheme.navy),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(sheetContext);
                chooseFromStorage();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _error(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  bool _validateBasics() {
    if (titleController.text.trim().isEmpty) {
      _error('Please enter an item name.');
      return false;
    }
    return true;
  }

  bool _validateDetails() {
    if (locationController.text.trim().isEmpty) {
      _error('Please enter the location.');
      return false;
    }
    return true;
  }

  Future<void> submit() async {
    if (titleController.text.trim().isEmpty) {
      _error('Please enter an item name.');
      return;
    }
    if (locationController.text.trim().isEmpty) {
      _error('Please enter the location.');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _error('Please login first.');
      return;
    }

    try {
      setState(() => loading = true);

      String imageUrl = '';
      if (selectedImage != null) {
        imageUrl = await StorageService().uploadItemImage(selectedImage!, user.uid);
      }

      await ItemService().createItem(
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        category: category,
        type: type,
        location: type == 'found' && storageController.text.trim().isNotEmpty
            ? '${locationController.text.trim()} (stored: ${storageController.text.trim()})'
            : locationController.text.trim(),
        imageUrl: imageUrl,
        userId: user.uid,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(type == 'found' ? 'Found item posted!' : 'Lost item reported!')),
      );
      Navigator.pop(context);
    } catch (e) {
      _error(e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return type == 'found' ? _buildFoundForm(context) : _buildLostWizard(context);
  }

  // ---------------------------------------------------------------------
  // "Report Found Item" — single-page form
  // ---------------------------------------------------------------------
  Widget _buildFoundForm(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Found Item')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Help return an item to its owner by providing details below.',
              style: TextStyle(fontSize: 13.5, color: AppTheme.textGrey, height: 1.4),
            ),
            const SizedBox(height: 22),
            const _FieldLabel('PHOTOS'),
            const SizedBox(height: 8),
            _PhotoUploadBox(image: selectedImage, onTap: _showPickerSheet),
            const SizedBox(height: 20),
            const _FieldLabel('WHAT DID YOU FIND?'),
            const SizedBox(height: 8),
            _StyledTextField(
              controller: titleController,
              hint: 'e.g. Silver Laptop, Blue Hydroflask',
              icon: Icons.inventory_2_outlined,
            ),
            const SizedBox(height: 20),
            const _FieldLabel('CATEGORY'),
            const SizedBox(height: 8),
            _CategoryDropdown(
              value: category,
              items: categories,
              onChanged: (v) => setState(() => category = v ?? category),
            ),
            const SizedBox(height: 20),
            const _FieldLabel('WHERE WAS IT FOUND?'),
            const SizedBox(height: 8),
            _StyledTextField(
              controller: locationController,
              hint: 'Campus location, building name, or room',
              icon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 20),
            const _FieldLabel('CURRENT STORAGE LOCATION'),
            const SizedBox(height: 8),
            _StyledTextField(
              controller: storageController,
              hint: 'e.g. Student Union Desk, Library Front',
              icon: Icons.store_mall_directory_outlined,
            ),
            const SizedBox(height: 6),
            const Text(
              'Providing an official lost & found desk location is recommended.',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppTheme.textGrey),
            ),
            const SizedBox(height: 20),
            const _FieldLabel('DESCRIPTION'),
            const SizedBox(height: 8),
            _StyledTextField(
              controller: descriptionController,
              hint: 'Any distinguishing marks or details...',
              maxLines: 4,
            ),
            const SizedBox(height: 20),
            const _LegalDisclaimer(),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: loading ? null : submit,
                icon: loading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.navy),
                      )
                    : const Icon(Icons.send_outlined, size: 18, color: AppTheme.navy),
                label: Text(
                  loading ? 'Posting...' : 'Post Found Item',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.navy),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.orange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // "Report Lost Item" — 3-step wizard: Basic Info -> Details -> Photos
  // ---------------------------------------------------------------------
  Widget _buildLostWizard(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Lost Item')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: _StepIndicator(currentStep: currentStep, labels: stepLabels),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: _buildLostStepContent(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              children: [
                if (currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => currentStep -= 1),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: AppTheme.border),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      ),
                      child: const Text('Back'),
                    ),
                  ),
                if (currentStep > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: loading ? null : _onLostPrimaryAction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.navy,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    ),
                    child: loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(currentStep < 2 ? 'Continue' : 'Post Lost Item'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onLostPrimaryAction() {
    if (currentStep == 0) {
      if (_validateBasics()) setState(() => currentStep = 1);
    } else if (currentStep == 1) {
      if (_validateDetails()) setState(() => currentStep = 2);
    } else {
      submit();
    }
  }

  Widget _buildLostStepContent() {
    switch (currentStep) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _FieldLabel('ITEM NAME'),
            const SizedBox(height: 8),
            _StyledTextField(
              controller: titleController,
              hint: 'e.g. Blue Hydroflask, Apple AirPods',
              icon: Icons.inventory_2_outlined,
            ),
            const SizedBox(height: 20),
            const _FieldLabel('CATEGORY'),
            const SizedBox(height: 8),
            _CategoryDropdown(
              value: category,
              items: categories,
              onChanged: (v) => setState(() => category = v ?? category),
            ),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _FieldLabel('WHERE DID YOU LAST SEE IT?'),
            const SizedBox(height: 8),
            _StyledTextField(
              controller: locationController,
              hint: 'Campus location, building name, or room',
              icon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 20),
            const _FieldLabel('DESCRIPTION'),
            const SizedBox(height: 8),
            _StyledTextField(
              controller: descriptionController,
              hint: 'Color, brand, distinguishing marks...',
              maxLines: 4,
            ),
          ],
        );
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _FieldLabel('PHOTOS (OPTIONAL)'),
            const SizedBox(height: 8),
            _PhotoUploadBox(image: selectedImage, onTap: _showPickerSheet),
            const SizedBox(height: 8),
            const Text(
              'A photo of the item, or a similar one, helps others recognize it.',
              style: TextStyle(fontSize: 12, color: AppTheme.textGrey),
            ),
          ],
        );
    }
  }
}

// ---------------------------------------------------------------------------
// Shared styled sub-widgets
// ---------------------------------------------------------------------------
class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final List<String> labels;
  const _StepIndicator({required this.currentStep, required this.labels});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(labels.length * 2 - 1, (i) {
        if (i.isOdd) {
          final leftStep = i ~/ 2;
          final done = leftStep < currentStep;
          return Expanded(
            child: Container(
              height: 2,
              color: done ? AppTheme.navy : AppTheme.border,
            ),
          );
        }
        final step = i ~/ 2;
        final isActive = step == currentStep;
        final isDone = step < currentStep;
        return Column(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: isActive || isDone ? AppTheme.navy : AppTheme.border,
              child: isDone
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : Text(
                      '${step + 1}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isActive ? Colors.white : AppTheme.textGrey,
                      ),
                    ),
            ),
            const SizedBox(height: 4),
            Text(
              labels[step],
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isActive ? AppTheme.navy : AppTheme.textGrey,
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        color: AppTheme.textGrey,
      ),
    );
  }
}

class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData? icon;
  final int maxLines;

  const _StyledTextField({
    required this.controller,
    required this.hint,
    this.icon,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon, size: 18, color: AppTheme.textGrey) : null,
      ),
    );
  }
}

class _CategoryDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _CategoryDropdown({required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
      onChanged: onChanged,
    );
  }
}

class _PhotoUploadBox extends StatelessWidget {
  final File? image;
  final VoidCallback onTap;
  const _PhotoUploadBox({required this.image, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: image != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(image!, height: 220, width: double.infinity, fit: BoxFit.cover),
            )
          : CustomPaint(
              painter: _DashedBorderPainter(color: AppTheme.border, radius: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(color: AppTheme.paleBlue, shape: BoxShape.circle),
                      child: const Icon(Icons.add_a_photo_outlined, color: AppTheme.navy, size: 22),
                    ),
                    const SizedBox(height: 10),
                    const Text('Add Photos', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.navy)),
                    const SizedBox(height: 6),
                    const Text(
                      'Clear shots of the item help owners identify it',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: AppTheme.textGrey),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double strokeWidth;
  final double dashWidth;
  final double dashGap;

  _DashedBorderPainter({
    required this.color,
    this.radius = 12,
    this.strokeWidth = 1.4,
    this.dashWidth = 6,
    this.dashGap = 4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);

    final dashedPath = Path();
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        dashedPath.addPath(metric.extractPath(distance, next.clamp(0, metric.length)), Offset.zero);
        distance = next + dashGap;
      }
    }
    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LegalDisclaimer extends StatelessWidget {
  const _LegalDisclaimer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppTheme.lightBlue, borderRadius: BorderRadius.circular(14)),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.gavel_outlined, size: 18, color: AppTheme.navy),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LEGAL DISCLAIMER',
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, letterSpacing: 0.4, color: AppTheme.navy),
                ),
                SizedBox(height: 6),
                Text(
                  'By posting this item, you agree to facilitate its return to the '
                  'rightful owner. If you are unable to keep the item safe, please '
                  'surrender it to Campus Security or the nearest administrative '
                  'office immediately.',
                  style: TextStyle(fontSize: 12.5, color: AppTheme.textDark, height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
