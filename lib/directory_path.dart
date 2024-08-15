import 'dart:io';

class DirectoryPath {
  getPath() async {
    final path = Directory(
        "/storage/emulated/0/Android/media/com.example.download_any_file/files/count.csv");
    if (await path.exists()) {
      return path.path;
    } else {
      path.create();
      return path.path;
    }
  }
}