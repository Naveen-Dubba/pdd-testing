import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/app_theme.dart';
import 'preview_screen.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});
  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _picking = false;

  Future<void> _pick(ImageSource source) async {
    if (_picking) return;
    setState(() => _picking = true);
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        imageQuality: 80,
        preferredCameraDevice: CameraDevice.front,
      );
      if (picked == null) return;
      if (!mounted) return;
      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      _goToPreview(bytes);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open camera: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  void _goToPreview(Uint8List bytes) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PreviewScreen(imageBytes: bytes)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Face Analysis'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BackgroundWrapper(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 72),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Expanded(
                child: Center(
                  child: Container(
                    height: 230,
                    width: 230,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [kRoyalPurple.withOpacity(0.2), kElectricBlue.withOpacity(0.2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(color: kElectricBlue, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: kElectricBlue.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: const Icon(Icons.face_2_outlined, size: 96, color: Colors.white),
                  ),
                ),
              ),
              Text(
                'Position Your Face',
                style: kDisplay(24, w: FontWeight.w800, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                'Use a clear, front-facing photo in good lighting for the most accurate AI analysis.',
                textAlign: TextAlign.center,
                style: kBody(14, color: kTextSecondary),
              ),
              const SizedBox(height: 28),
              KPrimaryButton(
                label: 'Take Photo',
                icon: Icons.camera_alt_outlined,
                isGold: true,
                loading: _picking,
                onTap: () => _pick(ImageSource.camera),
              ),
              const SizedBox(height: 12),
              KPrimaryButton(
                label: 'Choose from Gallery',
                icon: Icons.photo_library_outlined,
                onTap: () => _pick(ImageSource.gallery),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}
