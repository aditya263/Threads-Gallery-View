import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:threads_gallery_view/screens/widgets/album_summary.dart';
import 'package:threads_gallery_view/screens/widgets/album_thumbnail.dart';

class AlbumSelectionBottomSheet extends StatelessWidget {
  final List<AssetPathEntity> albums;
  final AssetPathEntity? recentAlbum;
  final AssetPathEntity? allVideosAlbum;
  final void Function(AssetPathEntity?, String?) onAlbumSelected;

  const AlbumSelectionBottomSheet({
    Key? key,
    required this.albums,
    this.recentAlbum,
    this.allVideosAlbum,
    required this.onAlbumSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final itemCount = albums.length;
    final itemsPerRow =
        (itemCount % 2 == 0) ? itemCount ~/ 2 : (itemCount ~/ 2) + 1;

    final rows = <List<AssetPathEntity>>[];
    for (var i = 0; i < itemCount; i += itemsPerRow) {
      rows.add(albums.sublist(
        i,
        i + itemsPerRow > itemCount ? itemCount : i + itemsPerRow,
      ));
    }

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
                  recentAlbum != null
                      ? AlbumSummary(
                          icon: Icons.access_time,
                          color: Colors.blue,
                          title: 'Recents',
                          onTap: () {
                            Navigator.pop(context);
                            onAlbumSelected(recentAlbum, "Recent");
                          },
                        )
                      : const Text('No Recent Album Available'),
                  const SizedBox(width: 16.0),
                  allVideosAlbum != null
                      ? AlbumSummary(
                          icon: Icons.video_library,
                          color: Colors.green,
                          title: 'Videos',
                          onTap: () {
                            Navigator.pop(context);
                            onAlbumSelected(allVideosAlbum, "Videos");
                          },
                        )
                      : const Text('No Videos Album Available'),
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
                      SizedBox(
                        height: 200.0,
                        child: Row(
                          children: row1.map((album) {
                            return AlbumThumbnail(
                              album: album,
                              onTap: () {
                                Navigator.pop(context);
                                onAlbumSelected(album, null);
                              },
                            );
                          }).toList(),
                        ),
                      ),
                      // Second row
                      SizedBox(
                        height: 200.0,
                        child: Row(
                          children: row2.map((album) {
                            return AlbumThumbnail(
                              album: album,
                              onTap: () {
                                Navigator.pop(context);
                                onAlbumSelected(album, null);
                              },
                            );
                          }).toList(),
                        ),
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
