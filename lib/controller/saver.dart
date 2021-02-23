import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:share/share.dart';
import 'dart:typed_data';

  savefile(File file) async {
    await _askPermission();
    final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(await file.readAsBytes()));
  }

  shareFile(File file) {
    var fileString = file.path;
    Share.shareFiles(["$fileString"],text: "Olusturdugum fotografa bak");
  }


  _askPermission() async {
    Map<PermissionGroup, PermissionStatus> permissions =
        await PermissionHandler().requestPermissions([PermissionGroup.storage]);
  }
