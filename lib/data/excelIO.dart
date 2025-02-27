import 'dart:convert';
import 'dart:io';

import 'package:excel/excel.dart';

import 'option.dart';

class ExcelIO{
  static List<String> nomJours = ["Lundi","Mardi","Mercredi","Jeudi","Vendredi"];
  static List<String> nomService = ["Matin","Midi","Après-midi"];

  static Excel genere(List<String> noms, Map<String,List<dynamic>> dispo){
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];

    //cell modele couleur
    CellIndex cell = CellIndex.indexByColumnRow(columnIndex: 2 + Option.NB_NOM_PAR_LIGNE +1, rowIndex: 1);
    sheet.cell(cell).cellStyle = style(border: true, bold: true, color: "#4285f4");
    cell = CellIndex.indexByColumnRow(columnIndex: 2 + Option.NB_NOM_PAR_LIGNE +2, rowIndex: 1);
    sheet.cell(cell).value = TextCellValue("DISPONIBLE");
    sheet.cell(cell).cellStyle = style(border: true, bold: true);

    cell = CellIndex.indexByColumnRow(columnIndex: 2 + Option.NB_NOM_PAR_LIGNE +1, rowIndex: 2);
    sheet.cell(cell).cellStyle = style(border: true, bold: true, color: "#ff0000");
    cell = CellIndex.indexByColumnRow(columnIndex: 2 + Option.NB_NOM_PAR_LIGNE +2, rowIndex: 2);
    sheet.cell(cell).value = TextCellValue("OCCUPÉ");
    sheet.cell(cell).cellStyle = style(border: true, bold: true);

    int extraTable = Option.EXTRA_TABLE ? 1 : 0;
    //une iteration par tableau
    for (int i = 0; i < (noms.length-1)~/Option.NB_NOM_PAR_LIGNE +1 + extraTable; i++){
      CellIndex start = CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i*19+1);
      CellIndex end = CellIndex.indexByColumnRow(columnIndex: 2 + Option.NB_NOM_PAR_LIGNE -1, rowIndex: i*19+1);

      //cell staff
      sheet.merge(start, end, customValue: TextCellValue('STAFF'));
      sheet.cell(start).cellStyle = style(border: true, bold: true);
      sheet.cell(end).cellStyle = style(border: true, bold: true);

      //les cellules des jours
      for (int numJour = 0; numJour < 5; numJour++){
        CellIndex start = CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i*19+3 + numJour*3);
        CellIndex end = CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i*19+5 + numJour*3);

        //cell staff
        sheet.merge(start, end, customValue: TextCellValue(nomJours[numJour]));
        sheet.cell(start).cellStyle = style(border: true, bold: true);
        sheet.cell(end).cellStyle = style(border: true, bold: true);

        //cell service
        for (int numService = 0; numService < 3; numService++){
          CellIndex cell = CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i*19+3 + numJour*3 + numService);
          sheet.cell(cell).value = TextCellValue(nomService[numService]);
          sheet.cell(cell).cellStyle = style(bold: true, border: true, color: numJour%2 == 0 ? "#B0B0B0" : "#FFFFFF");
        }
      }

      //cell jour
      CellIndex cell = CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i*19+2);
      sheet.cell(cell).value = TextCellValue("Jours");
      sheet.cell(cell).cellStyle = style(bold: true, border: true);

      //cell service
      cell = CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i*19+2);
      sheet.cell(cell).value = TextCellValue("Services");
      sheet.cell(cell).cellStyle = style(bold: true, border: true);

      for (int numPersonne = 0; numPersonne < Option.NB_NOM_PAR_LIGNE; numPersonne++){
        //cell personne
        cell = CellIndex.indexByColumnRow(columnIndex: 2 + numPersonne, rowIndex: i*19+2);
        sheet.cell(cell).value = TextCellValue(numPersonne + i*Option.NB_NOM_PAR_LIGNE < noms.length ? noms[numPersonne + i*Option.NB_NOM_PAR_LIGNE] : "");
        sheet.cell(cell).cellStyle = style(bold: true, border: true);

        for (int numService = 0; numService < 15; numService++){
          //cell dispo
          cell = CellIndex.indexByColumnRow(columnIndex: 2 + numPersonne, rowIndex: i*19+3 + numService);
          String couleur = "#4285f4";
          if (numPersonne + i*Option.NB_NOM_PAR_LIGNE < noms.length) {
            couleur =
            dispo[noms[numPersonne + i * Option.NB_NOM_PAR_LIGNE]]![numService]
                ? "#4285f4"
                : "#ff0000";
          }
          sheet.cell(cell).cellStyle = style(bold: true, border: true, color: couleur);
        }
      }
    }

    return excel;
  }

  static CellStyle style({bool border = false, bool bold = false, String color = "#FFFFFF"}){
    return CellStyle(
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
      bold: bold,
      leftBorder: border ? Border(borderStyle: BorderStyle.Thin) : null,
      rightBorder: border ? Border(borderStyle: BorderStyle.Thin) : null,
      topBorder: border ? Border(borderStyle: BorderStyle.Thin) : null,
      bottomBorder: border ? Border(borderStyle: BorderStyle.Thin) : null,
      backgroundColorHex: ExcelColor.fromHexString(color),
    );
  }

  static Map<String,List<bool>> lire(String path){
    Map<String,List<bool>> dispos = {};

    if (path.substring(path.length-3,path.length) == "txt") {
      try {
        String data = File(path).readAsStringSync();
        Map<String, dynamic> decoded = jsonDecode(data);
        dispos = decoded.map(
              (key, value) => MapEntry(key, List<bool>.from(value)),
        );
        return dispos;
      }
      catch (e){
        print(e);
        return dispos;
      }
    }


    var bytes = File(path).readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);

    String sheetName = excel.tables.keys.toList()[0];

    var table = excel.tables[sheetName]!.rows;

    try {
      for (int numLigne = 0; numLigne < table.length / 19; numLigne++) {
        for (int numColonne = 0; numColonne <
            Option.NB_NOM_PAR_LIGNE; numColonne++) {
          if (table[numLigne * 19 + 2][numColonne + 2] == null) continue;

          String nom = table[numLigne * 19 + 2][numColonne + 2]!.value.toString();
          if (nom == "" || nom == "null") continue;
          dispos[nom] = [];

          for (int numService = 1; numService < 16; numService++) {
            if (table[numLigne * 19 + 2 + numService][numColonne + 2] == null) {
              continue;
            }

            String color = table[numLigne * 19 + 2 + numService][numColonne +
                2]!.cellStyle!.backgroundColor.colorHex.toString();

            if (color == "none") {
              dispos["Erreur"] = [true];
              continue;
            }

            int r = int.parse(color.substring(2, 4), radix: 16);
            //int g = int.parse(color.substring(4, 6), radix: 16);
            int b = int.parse(color.substring(6, 8), radix: 16);

            dispos[nom]!.add(b > r);
          }
        }
      }
    }
    on RangeError{
      dispos["Erreur"] = [true];
    }

    return dispos;
  }
}