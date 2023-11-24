import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:phale_mood/classes/database.dart';

class DatabaseFileRoutine {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    // ignore: avoid_print
    print('$path/local_persistence.json');
    return File('$path/local_persistence.json');
  }

  Future<String> readJournals() async {
    try {
      final file = await _localFile;

      // Check if the file exists
      if (!file.existsSync()) {
        // ignore: avoid_print
        print('File does not exist: ${file.path}');
        await writeJournals('{"journals": []}');
      }

      // Read the file
      String contents = await file.readAsString();
      return contents;
    } catch (e) {
      // ignore: avoid_print
      print('Error reading journals: $e');
      return "";
    }
  }

  Future<File> writeJournals(String json) async {
    final file = await _localFile;
    return file.writeAsString(json);
  }

  //To read and parse from  JSON data - databaseFromJson(jsonString)
  Database databaseFromJson(String str) {
    final dataFromJson = json.decode(str);
    return Database.fromJson(dataFromJson);
  }

  //To save and parse to JSON
  String databaseToJson(Database data) {
    final dataToJson = data.toJson();
    return json.encode(dataToJson);
  }
}
