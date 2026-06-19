import 'package:flutter/material.dart';

class ColorOption {
  final String name;
  final Color color;
  const ColorOption(this.name, this.color);
}

/// Maps a detected skin tone to a curated set of flattering colours.
/// This is YOUR recommendation logic — no external API needed.
class ColorRules {
  static const Map<String, List<ColorOption>> _byTone = {
    'fair': [
      ColorOption('Coral', Color(0xFFFF7F6B)),
      ColorOption('Sea Green', Color(0xFF2E8B7F)),
      ColorOption('Medium Purple', Color(0xFF9B7EDE)),
      ColorOption('Goldenrod', Color(0xFFDAA520)),
      ColorOption('Navy', Color(0xFF2C3E66)),
      ColorOption('Soft Teal', Color(0xFF3FA9A0)),
    ],
    'light': [
      ColorOption('Coral', Color(0xFFFF7F6B)),
      ColorOption('Sea Green', Color(0xFF2E8B7F)),
      ColorOption('Medium Purple', Color(0xFF9B7EDE)),
      ColorOption('Goldenrod', Color(0xFFDAA520)),
      ColorOption('Navy', Color(0xFF2C3E66)),
      ColorOption('Dusty Rose', Color(0xFFC97B84)),
    ],
    'medium': [
      ColorOption('Olive', Color(0xFF6B7A3A)),
      ColorOption('Mustard', Color(0xFFD4A017)),
      ColorOption('Rust', Color(0xFFB7410E)),
      ColorOption('Teal', Color(0xFF20808D)),
      ColorOption('Burgundy', Color(0xFF7B2D3A)),
      ColorOption('Cobalt', Color(0xFF2151C9)),
    ],
    'dark': [
      ColorOption('Bright White', Color(0xFFF5F5F0)),
      ColorOption('Cobalt Blue', Color(0xFF2151C9)),
      ColorOption('Magenta', Color(0xFFC2185B)),
      ColorOption('Emerald', Color(0xFF1B7A4B)),
      ColorOption('Royal Purple', Color(0xFF6A2FB5)),
      ColorOption('Gold', Color(0xFFE0A93B)),
    ],
    'deep': [
      ColorOption('Bright White', Color(0xFFF5F5F0)),
      ColorOption('Cobalt Blue', Color(0xFF2151C9)),
      ColorOption('Magenta', Color(0xFFC2185B)),
      ColorOption('Emerald', Color(0xFF1B7A4B)),
      ColorOption('Royal Purple', Color(0xFF6A2FB5)),
      ColorOption('Amber', Color(0xFFE0A93B)),
    ],
  };

  /// Returns the recommended palette for a given skin tone string.
  static List<ColorOption> forSkinTone(String tone) {
    final key = tone.toLowerCase().trim();
    for (final entry in _byTone.entries) {
      if (key.contains(entry.key)) return entry.value;
    }
    return _byTone['medium']!; // sensible default
  }

  /// The single best-matching colour for a skin tone (AI's top pick).
  static ColorOption bestForSkinTone(String tone) => forSkinTone(tone).first;
}
