import 'dart:convert';

import 'package:planning_kfet/data/excelIO.dart';
import 'package:planning_kfet/data/stockage.dart';

class Membre{
  late Map<String,dynamic> colonnes;
  late List<dynamic> membres;
  late Future<void> dataLoadMembre;

  Membre() {
    dataLoadMembre = _initializeData();
  }

  Future<void> _initializeData() async {
    String value = await Stockage.readJson(Stockage.membre);
    Map<String, dynamic> data = jsonDecode(value);

    colonnes = data["colonnes"];
    membres = data["membres"];
  }

  Future<void> save() async {
    Map<String,dynamic> data = {"colonnes":colonnes,"membres":membres};

    var encoder = JsonEncoder.withIndent('  ');
    String dataJson  = encoder.convert(data);

    await Stockage.writeJson(dataJson, Stockage.membre);
  }

  void echangeColonne(int oldIndex, int newIndex){
    String header = getHeader(oldIndex);
    colonnes["ordre"].removeAt(oldIndex);

    if (newIndex > oldIndex){
      newIndex--;
    }
    colonnes["ordre"].insert(newIndex,header);

    save();
  }

  int getWidth(){
    return colonnes["ordre"].length;
  }

  List<int> getVisible(){
    return [
      for (int column = 0; column < colonnes["ordre"].length; column++)
        if (isVisible(column)) column
    ];

  }

  int getHeight(){
    return membres.length;
  }

  String getHeader(int index){
    return colonnes["ordre"][index];
  }

  Map<String,int> correspondanceUniqueNomIndex = {};
  List<String> getUniqueName({bool actifSeulement = true}){
    Map<int,String> uniqueNameList = {};
    int nbLettrePrecision = 0;

    while (uniqueNameList.length < getHeight() && nbLettrePrecision < 10) {
      List<String> duplicatas = [];

      for (int i = 0; i < getHeight(); i++) {
        if (uniqueNameList[i] != null){
          continue;
        }

        String nom = membres[i]["Prénom"];
        nom[0].toUpperCase();

        String precision = membres[i]["Nom"].substring(0, nbLettrePrecision);
        if (precision.isNotEmpty) {
          precision[0].toUpperCase();
          nom = "$nom.$precision";
        }

        //si duplicatas contient le nom, le cas du duplication a deja ete vu et traité
        if (duplicatas.contains(nom)) {
          continue;
        }

        //si le nom existe deja, on supprime l'existant et on l'ajoute dans une liste pour s'en souvenir
        if (uniqueNameList.values.contains(nom)) {
          duplicatas.add(nom);
          uniqueNameList.removeWhere((key,value) => value == nom);
        }
        //si le nom n'existe pas encore
        else {
          uniqueNameList[i] = nom;
        }
      }

      nbLettrePrecision++;
    }

    if (actifSeulement) {
      for (int i = 0; i < getHeight(); i++) {
        if (!isActive(i)) uniqueNameList.remove(i);
      }
    }

    for (int key in uniqueNameList.keys){
      correspondanceUniqueNomIndex[uniqueNameList[key]!] = key;
    }

    return uniqueNameList.values.toList();
  }

  String getCell(int column, int line){
    return membres[line][getHeader(column)].toString();
  }

  void setCell(int column, int line, String enteredText){
    membres[line][getHeader(column)] = enteredText;
    save();
  }

  bool isActive(int line){
    return membres[line]["Actif"] == "1";
  }

  String getLine(int line){
    String texte = "";
    for (int column = 0; column < getWidth(); column++){
      if (!isVisible(column)) continue;
      texte += "${getCell(column, line)} ";
    }
    return texte;
  }

  void deleteLine(int line){
    membres.removeAt(line);
  }

  void sort(int column, bool ascending) {
    String header = getHeader(column);
    membres.sort((a, b) {
      final String aValue = a[header].toLowerCase();
      final String bValue = b[header].toLowerCase();
      return ascending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });
  }

  void addLine() {
    Map<String,dynamic> newLine = {};
    for (int column = 0; column < getWidth(); column++){
      newLine[getHeader(column)] = "N/a";
    }
    newLine["Actif"] = "0";

    membres.insert(0, newLine);
  }

  bool isVisible(int column){
    return colonnes["activite"][getHeader(column)] == "1";
  }

  void setVisibility(int column, bool status){
    colonnes["activite"][getHeader(column)] = status ? "1" : "0";
  }

  List<dynamic> getPreDispo(int numPersonne){
    return membres[numPersonne]["preDispo"];
  }

  void togglePreDispo(int numPersonne, int numJour, int numService){
    membres[numPersonne]["preDispo"][numJour*3+numService] = !membres[numPersonne]["preDispo"][numJour*3+numService];
  }

  Future<void> genere() async {
    List<String> noms = getUniqueName();
    noms.sort();

    Map<String,List<dynamic>> dispo = {};
    for (int i = 0; i < noms.length; i++){
      int corr = correspondanceUniqueNomIndex[noms[i]]!;
      dispo[noms[i]] = getPreDispo(corr);
    }

    var excel = ExcelIO.genere(noms, dispo);
    await Stockage.saveExcel(excel, Stockage.demandeDispo);
  }
}