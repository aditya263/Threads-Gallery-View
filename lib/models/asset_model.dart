import 'package:photo_manager/photo_manager.dart';

class AssetModel {
  final AssetEntity asset;
  final bool isSelected;
  final int indexInSelection;

  AssetModel({
    required this.asset,
    required this.isSelected,
    required this.indexInSelection,
  });
}
