/// Normalizes comma-separated addresses to a reasonable city label for grouping.
/// Not perfect for every locale; chefs also store an explicit `city` when present.
class ChefCityExtractor {
  ChefCityExtractor._();

  /// Best-effort city from full address text (comma-separated lines).
  static String fromAddress(String address) {
    final parts = address
        .split(RegExp(r',|;'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first;
    if (parts.length == 2) return parts[1];
    return parts[parts.length - 2];
  }

  static String normalizeKey(String city) => city.trim().toLowerCase();
}
