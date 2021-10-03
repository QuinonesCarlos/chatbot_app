import 'dart:io' as io;
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter_native_image/flutter_native_image.dart';

Future<String> subirArchivoMobil(
    io.File? imageFile, nombre, int targetWidth) async {
  firebase_storage.Reference storageReference =
      firebase_storage.FirebaseStorage.instance.ref().child(nombre);
  //Es audio
  if (targetWidth > 0) {
    ImageProperties properties =
        await FlutterNativeImage.getImageProperties(imageFile!.path);
    File compressedFile = await FlutterNativeImage.compressImage(imageFile.path,
        // quality: 95,
        targetWidth: targetWidth,
        targetHeight:
            (properties.height! * targetWidth / properties.width!).round());
    final firebase_storage.UploadTask uploadTask =
        storageReference.putFile(compressedFile);
    await uploadTask.whenComplete(() => null);
  } else {
    final firebase_storage.UploadTask uploadTask =
        storageReference.putFile(imageFile!);
    await uploadTask.whenComplete(() => null);
  }
  String url = await storageReference.getDownloadURL();
  return url.split('/v0/b/').last.split('?alt=media').first;
}
