import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';

class CsvStorage {
  /*
  BuildContext context;

  CsvStorage(BuildContext context) {
    this.context = context;
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/life_events.csv');
  }
   */

  Future<String> readCsv() async {
    try {
      Directory directory = await getDownloadsDirectory();
      String folder = directory.path;
      final file = File('$folder/life_events.csv');
      // Read the file
      final contents = await file.readAsString();
      return contents;
    } catch (e) {
      // If encountering an error, return 0
      print("Cannot get the csv in the download folder path! " + e.toString());
      return "";
    }
  }

  Future<Directory> getDownloadsDirectory() async {
    Directory directory;
    try {
      if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = Directory('/storage/emulated/0/Download');
        // Put file in global download folder, if for an unknown reason it didn't exist, we fallback
        // ignore: avoid_slow_async_io
        if (!await directory.exists())
          directory = await getExternalStorageDirectory();
      }
    } catch (e) {
      print("Cannot get download folder path! " + e.toString());
    }
    return directory;
  }

  /*
  Future<String> getDirectoryToSaveIn() async {
    String path = await FilesystemPicker.open(
      title: 'Save to folder',
      context: context,
      rootDirectory: await getDownloadsDirectory(),
      //DownloadsPathProvider.downloadsDirectory,
      //rootDirectory: await getTemporaryDirectory(),
      fsType: FilesystemType.folder,
      pickText: 'Save file to this folder',
      folderIconColor: AppColours.appBackgroundColour,
    );
    return path;
  }
   */

  Future<File> writeCsv(String csvData) async {
    //final file = await _localFile;
    // Write the file
    Directory directory = await getDownloadsDirectory();
    String folder = directory.path;
    final file = File('$folder/life_events.csv');
    return file.writeAsString(csvData);
  }

  Future<bool> importCsvExists() async {
    bool exists = false;
    try {
      Directory directory = await getDownloadsDirectory();
      String folder = directory.path;
      final file = File('$folder/life_events.csv');
      if (await file.exists()) {
        exists = true;
      }
    }
    catch(err) {
      print(err.toString());
    }
    return exists;
  }
}