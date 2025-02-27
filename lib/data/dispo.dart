import 'dart:convert';

import 'package:planning_kfet/data/stockage.dart';

class Dispo {
  late Map<String, dynamic> dispo = {};
  late Future<void> dataLoadDispo;

  Dispo({bool load = true}) {
    if (load) {
      dataLoadDispo = _initializeData();
    }
  }

  Future<void> _initializeData() async {
    String value = await Stockage.readJson(Stockage.dispo);
    Map<String, dynamic> data = jsonDecode(value);

    dispo = data;
  }

  Future<void> save() async {
    var encoder = JsonEncoder.withIndent('  ');
    String dataJson  = encoder.convert(dispo);

    await Stockage.writeJson(dataJson, Stockage.dispo);
  }

  bool isDisponible(String jour, String personne, int numJour, int numService) {
    Map<String,dynamic>? dispoJour = dispo[jour];
    if (dispoJour == null){
      return true;
    }

    List<dynamic>? dispoPersonne = dispoJour[personne];

    if (dispoPersonne == null) {
      return true;
    } else {
      return dispoPersonne[numJour*3+numService] == 1;
    }
  }

  void deleteDispo(String jour) {
    dispo.remove(jour);
    save();
  }

  void addDispo(String jour, Map<String,dynamic> newDispo){
    dispo[jour] = newDispo;
    save();
  }
}