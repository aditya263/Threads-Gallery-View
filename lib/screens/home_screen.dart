import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:threads_gallery_view/utils/permission_helper.dart';
import 'photo_gallery_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _counter = 0;
  List<AssetEntity> _selectedAssets = [];

  Future<void> _openGallery() async {
    final permission = await PermissionHelper.requestPermission();

    if (permission.isAuth) {
      if (context.mounted) {
        final selectedAssets = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PhotoGalleryScreen(
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
