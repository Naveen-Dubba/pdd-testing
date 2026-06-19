import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../models/analysis_result.dart';
import '../core/last_analysis.dart';
import '../services/color_rules.dart';
import '../services/history_store.dart';
import 'recommended_colors_screen.dart';
import 'shop_screen.dart';

class AnalysisResultScreen extends StatefulWidget {
  final AnalysisResult result;
  final bool save; // false when re-opening from history
  const AnalysisResultScreen({super.key, required this.result, this.save = true});

  @override
  State<AnalysisResultScreen> createState() => _AnalysisResultScreenState();
}

class _AnalysisResultScreenState extends State<AnalysisResultScreen> {
  @override
  void initState() {
    super.initState();
    LastAnalysis.result = widget.result; // for the dress-match checker
    if (widget.save) _saveToHistory();
  }

  Future<void> _saveToHistory() async {
    final best = ColorRules.bestForSkinTone(widget.result.skinTone).name;
    await HistoryStore.add(widget.result, best);
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final rows = [
      _Row(Icons.person_outline, 'Detected Gender', result.gender),
      _Row(Icons.face_outlined, 'Face Shape', result.faceShape),
      _Row(Icons.wb_sunny_outlined, 'Skin Tone', result.skinTone),
      _Row(Icons.accessibility_new, 'Body Type', result.bodyType),
      _Row(Icons.checkroom_outlined, 'Size Suggestion', result.sizeSuggestion),
      _Row(Icons.auto_awesome_outlined, 'Style Personality', result.stylePersonality),
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('AI Personal Stylist'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.white),
          onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
        ),
      ),
      body: BackgroundWrapper(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 72),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      height: 72,
                      width: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [kRoyalPurple, kElectricBlue],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: kElectricBlue.withOpacity(0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 36),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Analysis Complete',
                      style: kDisplay(26, w: FontWeight.w800, color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    KGlassCard(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      child: Column(
                        children: [
                          for (int i = 0; i < rows.length; i++) ...[
                            _buildRow(rows[i]),
                            if (i != rows.length - 1)
                              Divider(height: 1, color: kTextSecondary.withOpacity(0.15)),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'AI analysis is a best guess. Tap shop to refine.',
                      style: kBody(12, color: kTextSecondary),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Row(
                children: [
                  Expanded(
                    child: KPrimaryButton(
                      label: 'Suitable Colors',
                      icon: Icons.palette_outlined,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RecommendedColorsScreen(result: result),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: KPrimaryButton(
                      label: 'Shopping',
                      icon: Icons.shopping_bag_outlined,
                      isGold: true,
                      onTap: () {
                        final colors = ColorRules.forSkinTone(result.skinTone);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ShopScreen(
                              result: result,
                              initialColor: colors.first.name,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(_Row r) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: kElectricBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kElectricBlue.withOpacity(0.2)),
            ),
            child: Icon(r.icon, color: kElectricBlue, size: 20),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(r.label, style: kBody(12, color: kTextSecondary)),
              const SizedBox(height: 2),
              Text(r.value, style: kDisplay(15, w: FontWeight.w700, color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Row {
  final IconData icon;
  final String label;
  final String value;
  _Row(this.icon, this.label, this.value);
}
