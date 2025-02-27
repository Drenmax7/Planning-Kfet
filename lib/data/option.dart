import 'dart:convert';

import 'package:planning_kfet/data/stockage.dart';

class Option{
  //nombre d'option qui seront affiché dans l'onglet d'option
  static const int nombreOption = 3;

  //lors de la generation de la demande de dispo, definit le nombre de personne par tableau
  static int NB_NOM_PAR_LIGNE = 8;

  //si un tableau vide doit etre generé
  static bool EXTRA_TABLE = true;

  //affiche ou non une couleur a cote de chaque nom pour aider a reperer son nom
  static bool COULEUR_NOM = false;

  late List<dynamic> option;
  late List<dynamic> template;
  late Future<void> dataLoadOption;

  Option() {
    dataLoadOption = _initializeData();
  }

  Future<void> _initializeData() async {
    String value = await Stockage.readJson(Stockage.option);
    Map<String, dynamic> data = jsonDecode(value);

    option = data["option"];
    template = data["template"];

    NB_NOM_PAR_LIGNE = data["system"][0];
    EXTRA_TABLE = data["system"][1];
    COULEUR_NOM = data["system"][2];
  }

  Future<void> save() async {
    Map<String,dynamic> data = {"option":option,"template":template};

    var encoder = JsonEncoder.withIndent('  ');
    String dataJson  = encoder.convert(data);

    await Stockage.writeJson(dataJson, Stockage.option);
  }

  static Future<void> saveSpecific() async{
    String value = await Stockage.readJson(Stockage.option);
    Map<String, dynamic> data = jsonDecode(value);
    data["system"] = [
      NB_NOM_PAR_LIGNE,
      EXTRA_TABLE,
      COULEUR_NOM,
    ];

    var encoder = JsonEncoder.withIndent('  ');
    String dataJson  = encoder.convert(data);

    await Stockage.writeJson(dataJson, Stockage.option);
  }

  int getNbColonne(){
    return template[0].length;
  }

  bool isOn(int numJour, int numService, int numColonne){
    return template[numJour*3+numService][numColonne];
  }

  void deleteColonne(){
    if (getNbColonne() > 1) {
      for (int numLigne = 0; numLigne < template.length; numLigne++) {
        template[numLigne].removeLast();
      }
      save();
    }
  }

  void addColonne(){
    for (int numLigne = 0; numLigne < template.length; numLigne++){
      if (template[numLigne].length > 0) {
        template[numLigne].add(template[numLigne].last);
      }
      else{
        template[numLigne].add(true);
      }
    }
    save();
  }

  void toggleColonne(int numJour, int numService, int numColonne){
    template[numJour*3+numService][numColonne] = !template[numJour*3+numService][numColonne];
    save();
  }

  void toggleColonneJour(int numJour){
    bool serv1Off = template[numJour*3].every((a) => !a);
    bool serv2Off = template[numJour*3+1].every((a) => !a);
    bool serv3Off = template[numJour*3+2].every((a) => !a);

    for (int numService = 0; numService < 3; numService++){
      for (int numColonne = 0; numColonne < getNbColonne(); numColonne++){
        template[numJour*3+numService][numColonne] = serv1Off && serv2Off && serv3Off;
      }
    }
    save();
  }

  void toggleColonneService(int numJour, int numService){
    bool servOff = template[numJour*3+numService].every((a) => !a);

    for (int numColonne = 0; numColonne < getNbColonne(); numColonne++){
      template[numJour*3+numService][numColonne] = servOff;
    }
    save();
  }

  void toggleOption(int numOption){
    if (numOption >= option.length) return;
    option[numOption] = !option[numOption];
    save();
  }


  bool getOption(int numOption){
    if (numOption >= option.length) return false;
    return option[numOption];
  }
}