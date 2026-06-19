import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/app_theme.dart';
import '../core/last_analysis.dart';
import '../services/match_service.dart';

class MatchCheckerScreen extends StatefulWidget {
  const MatchCheckerScreen({super.key});
  @override
  State<MatchCheckerScreen> createState() => _MatchCheckerScreenState();
}

class _MatchCheckerScreenState extends State<MatchCheckerScreen> {
  final _picker = ImagePicker();
  Uint8List? _imageBytes;
  bool _loading = false;
  DressMatch? _match;
  String? _error;

  Future<void> _pick(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
          source: source, maxWidth: 1000, imageQuality: 85);
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _match = null;
        _error = null;
      });
    } catch (e) {
      setState(() => _error = 'Could not open: $e');
    }
  }

  Future<void> _check() async {
    if (_imageBytes == null) return;
    setState(() {
      _loading = true;
      _error = null;
      _match = null;
    });
    try {
      final res = await MatchService().check(
        _imageBytes!,
        skinTone: LastAnalysis.result?.skinTone,
        gender: LastAnalysis.result?.gender,
      );
      setState(() => _match = res);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Color _scoreColor(int s) {
    if (s >= 75) return const Color(0xFF00E676);
    if (s >= 50) return kGold;
    return const Color(0xFFFF5252);
  }

  @override
  Widget build(BuildContext context) {
    final hasAnalysis = LastAnalysis.result != null;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Will it match me?'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BackgroundWrapper(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 72),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                'Upload a Dress or Outfit',
                style: kDisplay(24, w: FontWeight.w800, color: Colors.white),
              ),
              const SizedBox(height: 6),
              Text(
                hasAnalysis
                    ? 'We\'ll check it against your ${LastAnalysis.result!.skinTone.toLowerCase()} skin tone.'
                    : 'Tip: run a face analysis first for a personalized result.',
                style: kBody(13, color: kTextSecondary),
              ),
              const SizedBox(height: 20),

              // image area
              GestureDetector(
                onTap: () => _pick(ImageSource.gallery),
                child: KGlassCard(
                  padding: EdgeInsets.zero,
                  child: Container(
                    height: 280,
                    width: double.infinity,
                    child: _imageBytes == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add_a_photo_outlined, size: 48, color: kElectricBlue),
                              const SizedBox(height: 12),
                              Text(
                                'Tap to upload garment photo',
                                style: kBody(14, color: kTextSecondary),
                              ),
                            ],
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Image.memory(
                              _imageBytes!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: KPrimaryButton(
                      label: 'Gallery',
                      icon: Icons.photo_library_outlined,
                      onTap: () => _pick(ImageSource.gallery),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: KPrimaryButton(
                      label: 'Camera',
                      icon: Icons.camera_alt_outlined,
                      onTap: () => _pick(ImageSource.camera),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              KPrimaryButton(
                label: 'Analyze Match',
                icon: Icons.auto_awesome,
                isGold: true,
                loading: _loading,
                onTap: _imageBytes == null ? null : _check,
              ),

              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(
                  _error!,
                  style: kBody(13, color: const Color(0xFFFF5252)),
                ),
              ],

              if (_match != null) ...[
                const SizedBox(height: 24),
                KGlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            _match!.verdict,
                            style: kDisplay(22, w: FontWeight.w800, color: _scoreColor(_match!.score)),
                          ),
                          const Spacer(),
                          Text(
                            '${_match!.score}%',
                            style: kDisplay(22, w: FontWeight.w800, color: _scoreColor(_match!.score)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: _match!.score / 100,
                          minHeight: 8,
                          backgroundColor: Colors.white10,
                          valueColor: AlwaysStoppedAnimation<Color>(_scoreColor(_match!.score)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (_match!.reason.isNotEmpty) ...[
                        Text('Why', style: kDisplay(12, color: kElectricBlue, w: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(_match!.reason, style: kBody(14, color: Colors.white)),
                        const SizedBox(height: 16),
                      ],
                      if (_match!.tips.isNotEmpty) ...[
                        Text('Stylist Tip', style: kDisplay(12, color: kGold, w: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(_match!.tips, style: kBody(14, color: Colors.white)),
                      ],
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
