import 'dart:io';

import 'package:excel/excel.dart';
import 'package:path/path.dart';

class Stockage{
  static const String membre = "membre.json";
  static const String planning = "planning.json";
  static const String dispo = "dispo.json";
  static const String credit = "credit.txt";
  static const String option = "option.json";
  static const String screenshot = "planningKfet.png";
  static const String demandeDispo = "demandeDispo.xlsx";

  static Future<String> get localPath async {
    final directory = dirname(Platform.resolvedExecutable);
    return "$directory/data";
    //final directory = await getApplicationSupportDirectory();
    //return directory.path;
  }

  static Future<File> writeJson(String json, String openFile) async {
    final path = await localPath;
    final file = File('$path/$openFile');

    // Write the file
    return file.writeAsString(json);
  }

  static Future<String> readJson(String openFile) async {
    try {
      final path = await localPath;
      final file = File('$path/$openFile');

      // Read the file
      final contents = await file.readAsString();

      return contents;
    } catch (e) {
      // If encountering an error, return 0
      return "";
    }
  }

  static Future<void> saveExcel(Excel excel, String nom) async{
    final path = await localPath;
    final file = File("$path/$nom");
    await file.writeAsBytes(excel.encode()!);
  }
}