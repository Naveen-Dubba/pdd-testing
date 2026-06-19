import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../models/analysis_result.dart';
import '../services/analysis_service.dart';
import 'analysis_result_screen.dart';

class AnalyzingScreen extends StatefulWidget {
  final Uint8List imageBytes;
  const AnalyzingScreen({super.key, required this.imageBytes});
  @override
  State<AnalyzingScreen> createState() => _AnalyzingScreenState();
}

class _AnalyzingScreenState extends State<AnalyzingScreen> {
  String _status = 'Reading your features…';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  Future<void> _run() async {
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _status = 'Detecting skin tone & shape…');
    });
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _status = 'Curating your palette…');
    });

    try {
      final result = await AnalysisService().analyzeFace(widget.imageBytes);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => AnalysisResultScreen(result: result)),
      );
    } catch (e) {
      if (!mounted) return;
      _showError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _showError(String msg) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: kDeepBlack,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Analysis Failed', style: kDisplay(18, color: Colors.white)),
        content: Text(msg, style: kBody(14, color: kTextSecondary)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text('Retake', style: kBody(14, color: kTextSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      AnalysisResultScreen(result: AnalysisResult.fallback()),
                ),
              );
            },
            child: Text('Continue anyway',
                style: kBody(14, color: kGold, w: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWrapper(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 60,
                width: 60,
                child: CircularProgressIndicator(
                  strokeWidth: 3.5,
                  valueColor: AlwaysStoppedAnimation<Color>(kElectricBlue),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Analyzing Style Profile',
                style: kDisplay(24, w: FontWeight.w800, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(
                _status,
                style: kBody(14, color: kTextSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
