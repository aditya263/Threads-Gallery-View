import 'dart:typed_data';

class AssetThumbnailCache {
  static final Map<String, Uint8List> _cache = {};

  static Uint8List? get(String key) => _cache[key];

  static void put(String key, Uint8List data) {
    _cache[key] = data;
  }

  static void clear() {
    _cache.clear();
  }
}
