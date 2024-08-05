import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class AlbumThumbnail extends StatefulWidget {
  final AssetPathEntity album;
  final VoidCallback onTap;

  const AlbumThumbnail({
    Key? key,
    required this.album,
    required this.onTap,
  }) : super(key: key);

  @override
  AlbumThumbnailState createState() => AlbumThumbnailState();
}

class AlbumThumbnailState extends State<AlbumThumbnail> {
  Uint8List? _thumbnailData;
  Future<int>? _assetCountFuture;
  Future<String?>? _videoDurationFuture;
  bool _isThumbnailLoaded = false;

  @override
  void initState() {
    super.initState();
    _assetCountFuture = _getAssetCount();
    _videoDurationFuture = _getVideoDuration();
    _loadThumbnail();
  }

  Future<void> _loadThumbnail() async {
    final assets = await widget.album.getAssetListRange(start: 0, end: 1);
    if (assets.isNotEmpty) {
      final asset = assets.first;
      final data = await asset.thumbnailData;
      if (data != null) {
        setState(() {
          _thumbnailData = data;
          _isThumbnailLoaded = true;
        });
      }
    }
  }

  Future<int> _getAssetCount() async {
    final assets = await widget.album.getAssetListRange(start: 0, end: 10000);
    return assets.length;
  }

  Future<String?> _getVideoDuration() async {
    final assets = await widget.album.getAssetListRange(start: 0, end: 1);
    if (assets.isNotEmpty) {
      final asset = assets.first;
      if (asset.type == AssetType.video) {
        final durationMillis = asset.videoDuration;
        final minutes = durationMillis.inMinutes;
        final seconds = durationMillis.inSeconds % 60;
        return '$minutes:${seconds.toString().padLeft(2, '0')}';
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: _isThumbnailLoaded
                          ? (_thumbnailData != null
                              ? Image.memory(
                                  _thumbnailData!,
                                  fit: BoxFit.cover,
                                )
                              : const SizedBox.shrink())
                          : const SizedBox.shrink(),
                    ),
                  ),
                ),
                FutureBuilder<String?>(
                  future: _videoDurationFuture,
                  builder: (context, snapshot) {
                    final duration = snapshot.data;
                    return Positioned(
                      bottom: 4.0,
                      right: 4.0,
                      child: duration != null
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4.0, vertical: 2.0),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              child: Text(
                                duration,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.0,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: FutureBuilder<int>(
                future: _assetCountFuture,
                builder: (context, snapshot) {
                  final itemCount = snapshot.data ?? 0;
                  return Column(
                    children: [
                      Text(
                        widget.album.name,
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        '$itemCount items',
                        style:
                            const TextStyle(fontSize: 14.0, color: Colors.grey),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
