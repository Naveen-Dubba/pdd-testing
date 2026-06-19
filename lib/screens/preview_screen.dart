import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import 'analyzing_screen.dart';

class PreviewScreen extends StatelessWidget {
  final Uint8List imageBytes;
  const PreviewScreen({super.key, required this.imageBytes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Confirm Photo'),
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
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: kBorderColor, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: kRoyalPurple.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(26),
                      child: Image.memory(imageBytes, fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Looks Good?',
                style: kDisplay(22, w: FontWeight.w800, color: Colors.white),
              ),
              const SizedBox(height: 6),
              Text(
                'Make sure your face is clearly visible and well-lit.',
                style: kBody(13, color: kTextSecondary),
              ),
              const SizedBox(height: 24),
              KPrimaryButton(
                label: 'Analyze Style',
                icon: Icons.auto_awesome,
                isGold: true,
                onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (_) => AnalyzingScreen(imageBytes: imageBytes)),
                ),
              ),
              const SizedBox(height: 12),
              KPrimaryButton(
                label: 'Retake Photo',
                icon: Icons.refresh,
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
