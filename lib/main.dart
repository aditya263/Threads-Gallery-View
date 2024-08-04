import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  List<AssetEntity> _selectedAssets = [];

  Future<void> _openGallery() async {
    final permission = await PhotoManager.requestPermissionExtend();

    if (permission.isAuth) {
      if (context.mounted) {
        final selectedAssets = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PhotoGalleryPage(
              initialSelectedAssets: _selectedAssets,
            ),
          ),
        );

        if (selectedAssets != null) {
          setState(() {
            _selectedAssets = selectedAssets;
            _counter = _selectedAssets.length;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _openGallery,
              child: const Text('Open Gallery'),
            ),
            Text('Selected images: $_counter'),
            _counter > 0
                ? SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedAssets.length,
                      itemBuilder: (context, index) {
                        final asset = _selectedAssets[index];
                        return FutureBuilder<Uint8List?>(
                          future: asset.thumbnailData,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            final imageData = snapshot.data;
                            return Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: imageData != null
                                  ? Image.memory(imageData,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover)
                                  : Container(),
                            );
                          },
                        );
                      },
                    ),
                  )
                : const Text('No images selected.'),
          ],
        ),
      ),
    );
  }
}

class PhotoGalleryPage extends StatefulWidget {
  final List<AssetEntity> initialSelectedAssets;

  const PhotoGalleryPage({super.key, required this.initialSelectedAssets});

  @override
  PhotoGalleryPageState createState() => PhotoGalleryPageState();
}

class PhotoGalleryPageState extends State<PhotoGalleryPage> {
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
    final permission = await PhotoManager.requestPermissionExtend();
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

class AssetGridView extends StatelessWidget {
  final List<AssetEntity> assets;
  final List<AssetEntity> selectedAssets;
  final void Function(AssetEntity asset, bool selected) onSelectionChanged;

  const AssetGridView({
    super.key,
    required this.assets,
    required this.selectedAssets,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
      ),
      itemCount: assets.length,
      itemBuilder: (context, index) {
        final asset = assets[index];
        final isSelected = selectedAssets.contains(asset);
        final indexInSelection = selectedAssets.indexOf(asset) + 1;

        return AssetThumbnail(
          asset: asset,
          isSelected: isSelected,
          indexInSelection: indexInSelection,
          onSelect: (selected) {
            if (selected) {
              if (selectedAssets.length < 10) {
                onSelectionChanged(asset, true);
              } else {
                // Show a message or dialog informing the user about the limit
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('You can only select up to 10 images.'),
                  ),
                );
              }
            } else {
              onSelectionChanged(asset, false);
            }
          },
        );
      },
    );
  }
}

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
  _AssetThumbnailState createState() => _AssetThumbnailState();
}

class _AssetThumbnailState extends State<AssetThumbnail> {
  Uint8List? _thumbnailData;

  @override
  void initState() {
    super.initState();
    _loadThumbnail();
  }

  Future<void> _loadThumbnail() async {
    final data = await widget.asset.thumbnailData;
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
          ],
        ),
      ),
    );
  }
}
