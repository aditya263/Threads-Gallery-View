import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'asset_thumbnail.dart';

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
