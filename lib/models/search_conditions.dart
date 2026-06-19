/// Holds the user's shopping conditions + the AI color, and builds the
/// dynamic Amazon / Flipkart search deeplinks.
class SearchConditions {
  String color;       // chosen colour e.g. 'Navy'
  String gender;      // men / women / boys / girls
  String? brand;      // optional 'Armani' (null = any)
  String category;    // 'suit' / 'shirt' / 'kurta' / 'jacket'
  String? occasion;   // 'wedding' / 'birthday' / 'festival' / 'interview' ...
  String? size;       // 'small' / 'medium' / 'large' / 'XL' / 'XXL'
  int? maxPrice;      // 1000 / 2000 / 5000 (null = any)

  SearchConditions({
    required this.color,
    required this.gender,
    required this.category,
    this.brand,
    this.occasion,
    this.size,
    this.maxPrice,
  });

  /// order tuned for relevance: brand → color → gender → occasion → category → size
  String get query => [brand, color, gender, occasion, category, size]
      .where((e) => e != null && e.toString().trim().isNotEmpty)
      .join(' ')
      .trim();

  String get amazonUrl {
    final base = 'https://www.amazon.in/s?k=${Uri.encodeComponent(query)}';
    return maxPrice != null ? '$base&low-price=0&high-price=$maxPrice' : base;
  }

  String get flipkartUrl {
    final base = 'https://www.flipkart.com/search?q=${Uri.encodeComponent(query)}';
    return maxPrice != null ? '$base&sort=price_asc' : base;
  }
}
