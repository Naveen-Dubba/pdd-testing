import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../models/analysis_result.dart';
import '../services/color_rules.dart';
import 'shop_screen.dart';

class RecommendedColorsScreen extends StatelessWidget {
  final AnalysisResult result;
  const RecommendedColorsScreen({super.key, required this.result});

  void _shop(BuildContext context, String colorName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ShopScreen(result: result, initialColor: colorName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = ColorRules.forSkinTone(result.skinTone);
    final best = colors.first;        // AI's perfect match
    final others = colors.skip(1).toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Your Colors'),
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
                'Best color for your\n${result.skinTone} skin tone',
                style: kDisplay(24, w: FontWeight.w800, color: Colors.white),
              ),
              const SizedBox(height: 20),

              // PERFECT MATCH hero
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [
                      kRoyalPurple.withOpacity(0.4),
                      Colors.black.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: kRoyalPurple.withOpacity(0.3), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: kRoyalPurple.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 64,
                          width: 64,
                          decoration: BoxDecoration(
                            color: best.color,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: best.color.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.auto_awesome, size: 14, color: kGold),
                                const SizedBox(width: 5),
                                Text(
                                  'Your perfect match',
                                  style: kDisplay(12, color: kGold, w: FontWeight.w700),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              best.name,
                              style: kDisplay(24, color: Colors.white, w: FontWeight.w800),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    KPrimaryButton(
                      label: 'Shop in ${best.name}',
                      icon: Icons.shopping_bag_outlined,
                      isGold: true,
                      onTap: () => _shop(context, best.name),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),
              Text(
                'Also great on you',
                style: kDisplay(18, w: FontWeight.w700, color: Colors.white),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: others.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 18,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.82,
                ),
                itemBuilder: (_, i) {
                  final c = others[i];
                  return GestureDetector(
                    onTap: () => _shop(context, c.name),
                    child: Column(
                      children: [
                        Container(
                          height: 72,
                          width: 72,
                          decoration: BoxDecoration(
                            color: c.color,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white24, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: c.color.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          c.name,
                          textAlign: TextAlign.center,
                          style: kBody(13, w: FontWeight.w600, color: Colors.white),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
