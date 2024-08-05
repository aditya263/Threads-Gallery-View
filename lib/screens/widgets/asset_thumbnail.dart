import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class AssetThumbnail extends StatefulWidget {
  final AssetEntity asset;
  final bool isSelected;
  final int indexInSelection;
  final void Function(bool) onSelect;

  const AssetThumbnail({
    super.key,
    required this.asset,
    required this.isSelected,
    required this.indexInSelection,
    required this.onSelect,
  });

  @override
  AssetThumbnailState createState() => AssetThumbnailState();
}

class AssetThumbnailState extends State<AssetThumbnail> {
  Uint8List? _thumbnailData;
  Duration? _duration;
  bool _isVideo = false;

  @override
  void initState() {
    super.initState();
    _loadThumbnail();
  }

  Future<void> _loadThumbnail() async {
    final data = await widget.asset.thumbnailData;
    final type = widget.asset.type;

    if (type == AssetType.video) {
      _isVideo = true;
      final videoDuration = widget.asset.videoDuration;
      setState(() {
        _duration = videoDuration;
      });
    }

    setState(() {
      _thumbnailData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: () => widget.onSelect(!widget.isSelected),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_thumbnailData != null)
              Image.memory(
                _thumbnailData!,
                fit: BoxFit.cover,
              )
            else
              const Center(child: CircularProgressIndicator()),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: widget.isSelected ? Colors.blue : Colors.transparent,
                  border: Border.all(color: Colors.white, width: 2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: widget.isSelected
                      ? Text(
                          '${widget.indexInSelection}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
              ),
            ),
            if (_isVideo && _duration != null)
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  color: Colors.black.withOpacity(0.7),
                  child: Text(
                    _formatDuration(_duration!),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
