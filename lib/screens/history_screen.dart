import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../models/history_entry.dart';
import '../services/color_rules.dart';
import '../services/history_store.dart';
import 'analysis_result_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<HistoryEntry>> _future;

  @override
  void initState() {
    super.initState();
    _future = HistoryStore.all();
  }

  void _reload() => setState(() => _future = HistoryStore.all());

  Future<void> _confirmClear() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kDeepBlack,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Clear history?', style: kDisplay(18, color: Colors.white)),
        content: Text('This removes all your saved analyses.',
            style: kBody(14, color: kTextSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancel', style: kBody(14, color: kTextSecondary))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Clear',
                  style: kBody(14, color: const Color(0xFFFF5252), w: FontWeight.w700))),
        ],
      ),
    );
    if (ok == true) {
      await HistoryStore.clear();
      _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: _confirmClear,
          ),
        ],
      ),
      body: BackgroundWrapper(
        child: RefreshIndicator(
          color: kElectricBlue,
          onRefresh: () async => _reload(),
          child: FutureBuilder<List<HistoryEntry>>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: kElectricBlue));
              }
              final items = snap.data ?? [];
              if (items.isEmpty) return _empty();
              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 72),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _tile(items[i]),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _empty() {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        const Icon(Icons.history, size: 64, color: kTextSecondary),
        const SizedBox(height: 16),
        Center(child: Text('No saved analyses yet', style: kDisplay(20, color: Colors.white))),
        const SizedBox(height: 8),
        Center(child: Text('Your scans will appear here.',
            style: kBody(14, color: kTextSecondary))),
      ],
    );
  }

  Widget _tile(HistoryEntry e) {
    final swatch = ColorRules.forSkinTone(e.result.skinTone)
        .firstWhere((c) => c.name == e.bestColor,
            orElse: () => ColorRules.bestForSkinTone(e.result.skinTone))
        .color;

    final content = GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AnalysisResultScreen(result: e.result, save: false),
        ),
      ),
      child: KGlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: swatch,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24, width: 1.5),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${e.result.gender} · ${e.result.skinTone} skin',
                    style: kDisplay(15, w: FontWeight.w700, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Match: ${e.bestColor}  •  ${e.result.stylePersonality}',
                    style: kBody(12, color: kTextSecondary),
                  ),
                  if (e.dateLabel.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      e.dateLabel,
                      style: kBody(11, color: kTextSecondary.withOpacity(0.6)),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: kTextSecondary),
          ],
        ),
      ),
    );

    if (e.id == null) return content;
    return Dismissible(
      key: ValueKey(e.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: const Color(0xFFFF5252),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) async {
        await HistoryStore.delete(e.id!);
      },
      child: content,
    );
  }
}
