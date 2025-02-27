import 'dart:convert';

import 'package:planning_kfet/data/stockage.dart';
import 'package:intl/intl.dart';

import 'dispo.dart';

class Planning {
  late Map<String, dynamic> planningList = {};
  late List<String> jours = [];
  late Future<void> dataLoadPlanning;

  static const List<String> months = [
    "Janvier",
    "Février",
    "Mars",
    "Avril",
    "Mai",
    "Juin",
    "Juillet",
    "Août",
    "Septembre",
    "Octobre",
    "Novembre",
    "Décembre"
  ];

  Planning({bool load = true}) {
    if (load) {
      dataLoadPlanning = _initializeData();
    }
  }

  Future<void> _initializeData() async {
    String value = await Stockage.readJson(Stockage.planning);
    Map<String, dynamic> data = jsonDecode(value);

    planningList = data;
    jours = planningList.keys.toList();

    DateFormat format = DateFormat("dd/MM/yyyy");
    jours.sort((a, b) => format.parse(b).compareTo(format.parse(a)));
  }

  Future<void> save() async {
    Map<String, dynamic> data = planningList;

    var encoder = JsonEncoder.withIndent('  ');
    String dataJson = encoder.convert(data);

    await Stockage.writeJson(dataJson, Stockage.planning);
  }

  String getDay(int currentPage, {bool fancy = false}){
    if (fancy){
      return getFancy(jours[currentPage]);
    }
    else {
      return jours[currentPage];
    }
  }

  static String getFancy(String dateString){
    DateTime date = DateFormat("dd/MM/yyyy").parse(dateString);
    return "${date.day} ${months[date.month-1]} ${date.year}";
  }

  List<String> getAllDays({bool fancy = false}){
    List<String> liste = [];
    if (fancy){
      for (int i = 0; i < getLength(); i++){
        DateTime date = DateFormat("dd/MM/yyyy").parse(jours[i]);
        liste.add("${date.day} ${months[date.month-1]} ${date.year}");

      }
      return liste;
    }
    else {
      return jours;
    }
  }

  int getLength(){
    return jours.length;
  }

  void addPlanning(String jour, List<List<List<String>>> planning){
    planningList[jour] = planning;

    if (!jours.contains(jour)) {
      jours.add(jour);
      DateFormat format = DateFormat("dd/MM/yyyy");
      jours.sort((a, b) => format.parse(b).compareTo(format.parse(a)));
    }

    save();
  }

  int getMaxServicePlanning(String jour){
    List<dynamic> planning = planningList[jour];
    int max = [
      for (List<dynamic> listeJour in planning)
        for (List<dynamic> listeService in listeJour)
          listeService.length
    ].reduce((a, b) => a > b ? a : b);
    return max;
  }

  String getPersonne(String jour, int numJour, int numService, int numPersonne) {
    List<dynamic> service = planningList[jour][numJour][numService];
    return service.length > numPersonne ? service[numPersonne] : "";
  }

  Map<String,List<int>> getServiceParPersonne(String jour) {
    Map<String,List<int>> serviceParPersonne = {};

    //parcours chaque personne du planning
    for (int numJour = 0; numJour < 5; numJour++){
      for (int numService = 0; numService < 3; numService++){
        for (String personne in planningList[jour][numJour][numService]){
          //recupere le nombre de service de la personne ou [0,0] si pas present
          List<int> nombreService = serviceParPersonne[personne] ?? [0,0];
          //incremente le champs correspondant au service de 1
          nombreService[numService == 1 ? 0 : 1]++;
          serviceParPersonne[personne] = nombreService;
        }
      }
    }
    return serviceParPersonne;
  }

  /*
  * si forcefull est a false la fonction effectuera des verifications :
  *   verifier que la personne n'est pas deja assigné sur cette journée
  *   verifier que la personne est disponible sur ce service
  * et si la placement ne s'est pas effectué, renverrra la raison
  * */
  ///personne est le nom de la personne a placer
  ///jour est la date du planning
  ///numJour est un entier de 0 à 4 donnant le jour de la semaine
  ///numService est un entier de 0 à 2 donnant le service du jour
  ///numPersonne est un entier donnant la personne a remplacer du planning
  ///forcefull est un booleen indiquant si les verification doivent etre faite
  String placePersonne(String personne, String jour, int numJour, int numService, int numPersonne, Dispo? tableDispo, {bool forcefull = false}) {
    List<dynamic> liste = planningList[jour][numJour][numService];

    if (!forcefull) {
      for (int i = 0; i < liste.length; i++) {
        //si la personne est deja presente sur la ligne
        if (liste[i] == personne) {
          //si on essaie de placer la personne la ou elle est deja, on ne souleve pas d'erreur
          if (i == numPersonne) return "";
          return "$personne est deja placé sur ce service";
        }
      }

      if (tableDispo != null){
        if (!tableDispo.isDisponible(jour, personne, numJour, numService)){
          return "$personne n'est pas disponible sur ce service";
        }
      }
    }

    if (numPersonne < liste.length){
      liste[numPersonne] = personne;
    }
    else{
      liste.add(personne);
    }

    return "";
  }

  void deletePersonne(String jour, int numJour, int numService, int numPersonne) {
    List<dynamic> liste = planningList[jour][numJour][numService];

    if (numPersonne >= liste.length){
      return;
    }

    liste.removeAt(numPersonne);
  }

  void deletePlanning(String jour) {
    jours.remove(jour);
    planningList.remove(jour);
    save();
  }
}