import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:threads_gallery_view/screens/album_selection_screen.dart';
import 'package:threads_gallery_view/utils/permission_helper.dart';
import 'widgets/asset_grid_view.dart';

class PhotoGalleryScreen extends StatefulWidget {
  final List<AssetEntity> initialSelectedAssets;

  const PhotoGalleryScreen({super.key, required this.initialSelectedAssets});

  @override
  PhotoGalleryScreenState createState() => PhotoGalleryScreenState();
}

class PhotoGalleryScreenState extends State<PhotoGalleryScreen> {
  List<AssetPathEntity> _albums = [];
  List<AssetEntity> _assets = [];
  late List<AssetEntity> _selectedAssets;
  bool _loading = true;
  AssetPathEntity? _selectedAlbum;
  String? _selectedAlbumName;
  bool _isDoneEnabled = false;

  @override
  void initState() {
    super.initState();
    _selectedAssets = List.from(widget.initialSelectedAssets);
    _loadAlbums();
  }

  Future<void> _loadAlbums() async {
    final permission = await PermissionHelper.requestPermission();
    if (!permission.isAuth) {
      return;
    }

    final albums = await PhotoManager.getAssetPathList();
    if (albums.isNotEmpty) {
      setState(() {
        _albums = albums;
        _selectedAlbum = albums[0];
        _selectedAlbumName = _albums[0].name;
        _loadAssets(_selectedAlbum!);
      });
    }
  }

  Future<void> _loadAssets(AssetPathEntity album) async {
    final assets = await album.getAssetListPaged(page: 0, size: 100);
    setState(() {
      _assets = assets;
      _loading = false;
    });
  }

  void _onAlbumChanged(AssetPathEntity? album, String? albumName) {
    if (album != null) {
      setState(() {
        _selectedAlbum = album;
        _selectedAlbumName = albumName ?? album.name;
        _loading = true;
      });
      _loadAssets(album);
    }
  }

  void _updateDoneButtonState() {
    setState(() {
      _isDoneEnabled = _selectedAssets.isNotEmpty;
    });
  }

  void _onSelectionChanged(AssetEntity asset, bool selected) {
    setState(() {
      if (selected) {
        if (_selectedAssets.length < 10) {
          _selectedAssets.add(asset);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You can only select up to 10 images.'),
            ),
          );
        }
      } else {
        _selectedAssets.remove(asset);
      }
      _updateDoneButtonState();
    });
  }

  void _showAlbumSelectionBottomSheet() async {
    final recentAlbum = await _fetchRecentAlbum();
    final allVideosAlbum = await _fetchAllVideosAlbum();

    if (context.mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return AlbumSelectionBottomSheet(
            albums: _albums,
            recentAlbum: recentAlbum,
            allVideosAlbum: allVideosAlbum,
            onAlbumSelected: (album, albumName) {
              _onAlbumChanged(album, albumName);
            },
          );
        },
      );
    }
  }

  Future<AssetPathEntity?> _fetchAllVideosAlbum() async {
    final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      type: RequestType.video,
      hasAll: true,
    );
    return albums.isNotEmpty ? albums.first : null;
  }

  Future<AssetPathEntity?> _fetchRecentAlbum() async {
    final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      hasAll: true,
    );
    if (albums.isEmpty) return null;

    final recentAlbum = albums.first;
    final assets = await recentAlbum.getAssetListRange(start: 0, end: 1);
    if (assets.isNotEmpty) return recentAlbum;

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Gallery'),
        actions: [
          TextButton(
            onPressed: _isDoneEnabled
                ? () {
                    Navigator.pop(context, _selectedAssets.toList());
                  }
                : null,
            child: Text(
              'Done',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: _isDoneEnabled ? Colors.blue : Colors.grey,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1.0, color: Colors.grey),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: _showAlbumSelectionBottomSheet,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _selectedAlbumName ?? 'Select Album',
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down),
                ],
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : AssetGridView(
                    assets: _assets,
                    selectedAssets: _selectedAssets,
                    onSelectionChanged: _onSelectionChanged,
                  ),
          ),
        ],
      ),
    );
  }
}
