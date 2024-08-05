import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class AlbumSelectionBottomSheet extends StatelessWidget {
  final List<AssetPathEntity> albums;
  final void Function(AssetPathEntity?) onAlbumSelected;

  const AlbumSelectionBottomSheet({
    Key? key,
    required this.albums,
    required this.onAlbumSelected,
  }) : super(key: key);

  Future<Widget> _buildThumbnail(AssetPathEntity album) async {
    final assets = await album.getAssetListRange(start: 0, end: 1);
    if (assets.isNotEmpty) {
      final asset = assets.first;
      final thumbnailData = await asset.thumbnailData;
      if (thumbnailData != null) {
        return Image.memory(
          thumbnailData,
          fit: BoxFit.cover,
        );
      }
    }
    return const Center(
      child: Text(
        'No Image',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16.0),
      ),
    );
  }

  Future<int> _getAssetCount(AssetPathEntity album) async {
    final assets = await album.getAssetListRange(start: 0, end: 10000);
    return assets.length;
  }

  Future<String?> _getVideoDuration(AssetPathEntity album) async {
    final assets = await album.getAssetListRange(start: 0, end: 1);
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
    // Determine number of items per row
    final itemCount = albums.length;
    final itemsPerRow = (itemCount % 2 == 0)
        ? itemCount ~/ 2
        : (itemCount ~/ 2) + 1;

    // Split items into rows
    final rows = <List<AssetPathEntity>>[];
    for (var i = 0; i < itemCount; i += itemsPerRow) {
      rows.add(albums.sublist(
        i,
        i + itemsPerRow > itemCount ? itemCount : i + itemsPerRow,
      ));
    }

    // Ensure exactly 2 rows
    final row1 = rows.isNotEmpty ? rows[0] : [];
    final row2 = rows.length > 1 ? rows[1] : [];

    return DraggableScrollableSheet(
      minChildSize: 0.96,
      maxChildSize: 0.96,
      initialChildSize: 0.96,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
          ),
          child: Column(
            children: [
              Container(
                color: Colors.grey,
                height: 4,
                width: 30,
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 50.0),
                  const Text(
                    'Select Album',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.start,
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const CircleAvatar(
                          backgroundColor: Colors.blue,
                          radius: 24.0,
                          child: Icon(
                            Icons.access_time,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5.0),
                      const Text(
                        'Recents',
                        style: TextStyle(fontSize: 14.0),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16.0),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const CircleAvatar(
                          backgroundColor: Colors.green,
                          radius: 24.0,
                          child: Icon(
                            Icons.video_library,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      const Text(
                        'Videos',
                        style: TextStyle(fontSize: 14.0),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // First row
                      Container(
                        margin: const EdgeInsets.only(bottom: 16.0), // Space between rows
                        child: Row(
                          children: row1.map((album) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                onAlbumSelected(album);
                              },
                              child: FutureBuilder<Widget>(
                                future: _buildThumbnail(album),
                                builder: (context, snapshot) {
                                  return Container(
                                    width: 120, // Set a fixed width for each item
                                    margin: const EdgeInsets.only(right: 16.0), // Space between items
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
                                                    offset: const Offset(0, 4), // Shadow below the item
                                                  ),
                                                ],
                                              ),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(8.0),
                                                child: AspectRatio(
                                                  aspectRatio: 1,
                                                  child: snapshot.connectionState == ConnectionState.waiting
                                                      ? const Center(child: CircularProgressIndicator())
                                                      : snapshot.hasError
                                                      ? const Center(child: Text('Error loading image'))
                                                      : snapshot.data ?? const SizedBox.shrink(),
                                                ),
                                              ),
                                            ),
                                            FutureBuilder<String?>(
                                              future: _getVideoDuration(album),
                                              builder: (context, snapshot) {
                                                final duration = snapshot.data;
                                                return Positioned(
                                                  bottom: 4.0,
                                                  right: 4.0,
                                                  child: duration != null
                                                      ? Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
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
                                        const SizedBox(height: 8.0), // Space between image and text
                                        Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                album.name,
                                                style: const TextStyle(fontSize: 16.0),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              FutureBuilder<int>(
                                                future: _getAssetCount(album),
                                                builder: (context, snapshot) {
                                                  final itemCount = snapshot.data ?? 0;
                                                  return Text(
                                                    '$itemCount items',
                                                    style: const TextStyle(fontSize: 14.0, color: Colors.grey),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      // Second row
                      Row(
                        children: row2.map((album) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              onAlbumSelected(album);
                            },
                            child: FutureBuilder<Widget>(
                              future: _buildThumbnail(album),
                              builder: (context, snapshot) {
                                return Container(
                                  width: 120, // Set a fixed width for each item
                                  margin: const EdgeInsets.only(right: 16.0), // Space between items
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
                                                  offset: const Offset(0, 4), // Shadow below the item
                                                ),
                                              ],
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(8.0),
                                              child: AspectRatio(
                                                aspectRatio: 1,
                                                child: snapshot.connectionState == ConnectionState.waiting
                                                    ? const Center(child: CircularProgressIndicator())
                                                    : snapshot.hasError
                                                    ? const Center(child: Text('Error loading image'))
                                                    : snapshot.data ?? const SizedBox.shrink(),
                                              ),
                                            ),
                                          ),
                                          FutureBuilder<String?>(
                                            future: _getVideoDuration(album),
                                            builder: (context, snapshot) {
                                              final duration = snapshot.data;
                                              return Positioned(
                                                bottom: 4.0,
                                                right: 4.0,
                                                child: duration != null
                                                    ? Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
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
                                      const SizedBox(height: 8.0), // Space between image and text
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              album.name,
                                              style: const TextStyle(fontSize: 16.0),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            FutureBuilder<int>(
                                              future: _getAssetCount(album),
                                              builder: (context, snapshot) {
                                                final itemCount = snapshot.data ?? 0;
                                                return Text(
                                                  '$itemCount items',
                                                  style: const TextStyle(fontSize: 14.0, color: Colors.grey),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
