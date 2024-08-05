import 'package:photo_manager/photo_manager.dart';

class PermissionHelper {
  static Future<PermissionState> requestPermission() async {
    final permission = await PhotoManager.requestPermissionExtend();
    return permission;
  }
}
