import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
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

  void _onAlbumChanged(AssetPathEntity? album) {
    if (album != null) {
      setState(() {
        _selectedAlbum = album;
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
        children: [
          const Divider(height: 1.0, color: Colors.grey),
          // Divider below AppBar
          _albums.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      DropdownButton<AssetPathEntity>(
                        value: _selectedAlbum,
                        items: _albums.map((album) {
                          return DropdownMenuItem(
                            value: album,
                            child: Text(album.name),
                          );
                        }).toList(),
                        onChanged: (album) {
                          _onAlbumChanged(album);
                        },
                        hint: const Text('Select Album'),
                        underline: const SizedBox(),
                        isExpanded: false,
                        icon: const Icon(Icons.keyboard_arrow_down),
                        iconSize: 24.0,
                      ),
                    ],
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
