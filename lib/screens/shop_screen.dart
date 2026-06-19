import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/app_theme.dart';
import '../models/analysis_result.dart';
import '../models/search_conditions.dart';
import '../services/color_rules.dart';

class ShopScreen extends StatefulWidget {
  final AnalysisResult result;
  final String initialColor;
  const ShopScreen({super.key, required this.result, required this.initialColor});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  late String _color;
  late String _wearer; // Men / Women / Boys / Girls
  late String _size;   // small / medium / large / XL / XXL
  String _category = 'shirt';
  String? _occasion;
  String? _brand;
  int? _budget;
  bool _showAlternatives = false;

  static const _wearers = ['Men', 'Women', 'Boys', 'Girls'];
  static const _categories = ['shirt', 'suit', 'kurta', 'jacket', 'blazer', 'trousers'];
  static const _occasions = [
    'wedding', 'birthday', 'festival', 'interview', 'casual', 'office', 'party'
  ];
  static const _sizes = ['small', 'medium', 'large', 'XL', 'XXL'];
  static const _brands = ['Any', 'Armani', 'Raymond', 'Levi\'s', 'Hugo Boss', 'Allen Solly'];
  static const _budgets = <String, int?>{
    'Any': null, 'Under ₹1000': 1000, 'Under ₹2000': 2000, 'Under ₹5000': 5000,
  };

  @override
  void initState() {
    super.initState();
    _color = widget.initialColor;
    _wearer = widget.result.gender.toLowerCase().startsWith('f') ? 'Women' : 'Men';
    _size = _sizeFromSuggestion(widget.result.sizeSuggestion);
  }

  /// Maps 'Small (S)' / 'Medium (M)' / 'Large (L)' to a search-friendly word.
  String _sizeFromSuggestion(String s) {
    final t = s.toLowerCase();
    if (t.contains('xxl')) return 'XXL';
    if (t.contains('xl')) return 'XL';
    if (t.contains('small') || t.contains('(s)')) return 'small';
    if (t.contains('large') || t.contains('(l)')) return 'large';
    return 'medium';
  }

  SearchConditions get _conditions => SearchConditions(
        color: _color,
        gender: _wearer.toLowerCase(),
        category: _category,
        occasion: _occasion,
        size: _size,
        brand: (_brand == null || _brand == 'Any') ? null : _brand,
        maxPrice: _budget,
      );

  Color _swatch(String name, List<ColorOption> palette) =>
      palette.firstWhere((c) => c.name == name, orElse: () => palette.first).color;

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Could not open the link.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = ColorRules.forSkinTone(widget.result.skinTone);
    final c = _conditions;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Shop the Look'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BackgroundWrapper(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 72),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    // AI MATCHED COLOR — auto-selected
                    KGlassCard(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        children: [
                          Container(
                            height: 56,
                            width: 56,
                            decoration: BoxDecoration(
                              color: _swatch(_color, colors),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white24, width: 1.5),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.auto_awesome, size: 14, color: kGold),
                                    const SizedBox(width: 5),
                                    Text(
                                      'AI MATCHED COLOR',
                                      style: kDisplay(11, color: kGold, w: FontWeight.w800),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  _color,
                                  style: kDisplay(20, w: FontWeight.w800, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () =>
                                setState(() => _showAlternatives = !_showAlternatives),
                            child: Text(
                              _showAlternatives ? 'Close' : 'Change',
                              style: kBody(13, color: kElectricBlue, w: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_showAlternatives) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Other colors that suit you',
                        style: kBody(13, color: kTextSecondary),
                      ),
                      const SizedBox(height: 12),
                      KGlassCard(
                        padding: const EdgeInsets.all(16),
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: colors.map((co) {
                            final sel = co.name == _color;
                            return GestureDetector(
                              onTap: () => setState(() {
                                _color = co.name;
                                _showAlternatives = false;
                              }),
                              child: Column(
                                children: [
                                  Container(
                                    height: 46,
                                    width: 46,
                                    decoration: BoxDecoration(
                                      color: co.color,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: sel ? kElectricBlue : Colors.white24,
                                          width: sel ? 3 : 1),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    co.name,
                                    style: kBody(10, color: Colors.white),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),
                    _label('Shopping for'),
                    _chips(_wearers, _wearer, (v) => setState(() => _wearer = v)),
                    const SizedBox(height: 20),
                    _label('Occasion'),
                    _chips(_occasions, _occasion, (v) => setState(() {
                          _occasion = (_occasion == v) ? null : v;
                        })),
                    const SizedBox(height: 20),
                    _label('Category'),
                    _chips(_categories, _category, (v) => setState(() => _category = v)),
                    const SizedBox(height: 20),
                    _label('Size'),
                    _chips(_sizes, _size, (v) => setState(() => _size = v)),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(child: _dropdown('Brand', _brands, _brand ?? 'Any',
                            (v) => setState(() => _brand = v))),
                        const SizedBox(width: 12),
                        Expanded(child: _budgetDropdown()),
                      ],
                    ),
                    const SizedBox(height: 24),
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
                      label: 'Shop on Amazon',
                      bg: const Color(0xFFFF9900),
                      fg: Colors.black,
                      onTap: () => _open(c.amazonUrl),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: KPrimaryButton(
                      label: 'Shop on Flipkart',
                      isGold: true,
                      onTap: () => _open(c.flipkartUrl),
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

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          t,
          style: kDisplay(14, w: FontWeight.w800, color: Colors.white),
        ),
      );

  Widget _chips(List<String> items, String? selected, ValueChanged<String> onTap) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items.map((e) {
        final sel = e == selected;
        return GestureDetector(
          onTap: () => onTap(e),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: sel
                  ? const LinearGradient(colors: [kRoyalPurple, kElectricBlue])
                  : null,
              color: sel ? null : kCardBg,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: sel ? Colors.transparent : kBorderColor),
            ),
            child: Text(
              e[0].toUpperCase() + e.substring(1),
              style: kBody(13,
                  color: Colors.white,
                  w: sel ? FontWeight.w700 : FontWeight.w500),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _dropdown(String label, List<String> items, String value,
      ValueChanged<String> onChanged) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: kDeepBlack,
          icon: const Icon(Icons.expand_more, color: kElectricBlue),
          style: kBody(14, color: Colors.white),
          hint: Text(label, style: kBody(14, color: kTextSecondary)),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) => onChanged(v ?? items.first),
        ),
      ),
    );
  }

  Widget _budgetDropdown() {
    final current = _budgets.entries
        .firstWhere((e) => e.value == _budget, orElse: () => _budgets.entries.first)
        .key;
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: current,
          isExpanded: true,
          dropdownColor: kDeepBlack,
          icon: const Icon(Icons.expand_more, color: kElectricBlue),
          style: kBody(14, color: Colors.white),
          items: _budgets.keys
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) => setState(() => _budget = _budgets[v]),
        ),
      ),
    );
  }
}
