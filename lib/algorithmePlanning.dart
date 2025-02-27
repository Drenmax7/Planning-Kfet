
import 'dart:math';

import 'package:planning_kfet/data/dispo.dart';
import 'package:planning_kfet/data/membre.dart';
import 'package:planning_kfet/data/planning.dart';
import 'package:planning_kfet/widget/editablePlanning.dart';

class AlgorithmePlanning{
  Map<String,List<bool>>? dispos;
  List<dynamic>? dimension;
  List<dynamic>? option;

  late Planning tablePlanning;
  late Dispo tableDispo;
  late Membre tableMembre;
  late Planning tableHistorique;

  AlgorithmePlanning(){
    tablePlanning = Planning(load: false);
    tableDispo = Dispo(load: false);
  }

  int getNbPlanning(){
    return tablePlanning.getLength();
  }

  List<int> getDimension(){
    List<int> compte = [];

    for (List<dynamic> compteBool in dimension!){
      int nbValide = 0;
      for (bool b in compteBool){
        if (b) nbValide++;
      }
      compte.add(nbValide);
    }
    return compte;
  }

  void reinitialiser(){
    dimension = null;
    option = null;
    tablePlanning.planningList = {};
    tablePlanning.jours = [];
  }

  EditablePlanning getPlanning(int numPlanning, Function saveFunction){
    return EditablePlanning(
      jour: "$numPlanning",
      tablePlanning: tablePlanning,
      tableDispo: tableDispo,
      //tableMembre: tableMembre,
      editable: true,
      saveFunction: saveFunction,
    );
  }

  String genereNouveauPlanning(){
    if (dimension == null) return "";
    if (option == null) return "";
    if (dispos == null || dispos!.containsKey("Erreur")){
      return "Veuillez importer un fichier de disponibilité";
    }

    List<List<List<String>>> meilleurPlanning = makePlanning();
    int minErreur = testPlanning(meilleurPlanning);

    for (int i = 0; i < 10000; i++){
      List<List<List<String>>> planning = makePlanning();
      int erreur = testPlanning(planning);

      if (erreur < minErreur){
        minErreur = erreur;
        meilleurPlanning = planning;
      }
    }

    testPlanning(meilleurPlanning, affichage: true);

    String index = "${tablePlanning.getLength()}";
    tablePlanning.planningList[index] = meilleurPlanning;

    tablePlanning.jours.add(index);

    Map<String,List<int>> dispoInt = {};
    for (String nom in dispos!.keys){
      List<int> listeInt = [];

      for (bool disponible in dispos![nom]!){
        listeInt.add(disponible ? 1 : 0);
      }

      dispoInt[nom] = listeInt;
    }
    tableDispo.dispo[index] = dispoInt;

    return "";
  }

  Map<int,List<String>> getDispoPersonneParService({bool shuffle = false}){
    Map<int,List<String>> dispoPersonneParService = {};
    for (int i = 0; i < 15; i++){
      dispoPersonneParService[i] = [];
    }

    for (String nom in dispos!.keys){
      for (int i = 0; i < 15; i++){
        if (dispos![nom]![i]){
          dispoPersonneParService[i]!.add(nom);
        }
      }
    }

    if (shuffle) {
      for (int i = 0; i < 15; i++) {
        dispoPersonneParService[i]!.shuffle(Random());
      }
    }

    return dispoPersonneParService;
  }

  /*
    * Un service par jour
    * Favorise les plannings avec le plus de personne differentes ( tout le monde a un service)
    * Maximum 1 de difference entre celui avec le plus de service de midi et celui qui en a le moins (à l'exception de ceux qui ne pourrait pas avoir plus de service)
    * pareil pour les pauses
    * si un membre a beaucoup de service une semaine, il en a peu la suivante
    * n'affecte pas chaque semaine les memes personne aux memes jours
    * */
  List<List<List<String>>> makePlanning(){
    Map<String,List<bool>> servicePersonne = {};
    for (String nom in dispos!.keys){
      servicePersonne[nom] = [for (int i = 0; i < 15; i++) false];
    }

    Map<int,List<String>> dispoPersonneParService = getDispoPersonneParService(shuffle: true);
    List<int> dimension = getDimension();
    for (int numDimension = 0; numDimension < dimension.length; numDimension++){
      int nbPersonne = dimension[numDimension];

      for (int i = 0; i < nbPersonne && i < dispoPersonneParService[numDimension]!.length; i++){
        String nom = dispoPersonneParService[numDimension]![i];
        servicePersonne[nom]![numDimension] = true;
      }
    }

    List<List<List<String>>> planning = convertPlanning(servicePersonne);

    return planning;
  }

  List<List<List<String>>> convertPlanning(Map<String,List<bool>> servicePersonne){
    List<List<List<String>>> planning = [];
    for (int numJour = 0; numJour < 5; numJour++) {
      List<List<String>> planningJour = [];

      for (int numService = 0; numService < 3; numService++) {
        List<String> planningService = [];

        for (String nom in servicePersonne.keys) {
          if (!servicePersonne[nom]![numJour*3+numService]) continue;

          planningService.add(nom);
        }

        planningJour.add(planningService);
      }

      planning.add(planningJour);
    }

    return planning;
  }

  int testPlanning(List<List<List<String>>> planning, {bool affichage = false}){
    int compte = 0;
    //CONTRAINTES FORTES

    //une personne ne peut pas etre affecté 2 fois au meme service
    for (int numJour = 0; numJour < 5; numJour++){
      for (int numService = 0; numService < 3; numService++){
        Map<String, int> comptePersonne = {};

        for (int numPersonne = 0; numPersonne < planning[numJour][numService].length; numPersonne++){
          String nom = planning[numJour][numService][numPersonne];

          comptePersonne[nom] = comptePersonne[nom] == null ? 1 : comptePersonne[nom]!+1;
        }

        for (String nom in comptePersonne.keys){
          if (comptePersonne[nom]! > 1){
            if (affichage) {
              print("$nom present ${comptePersonne[nom]} fois le service $numService, jour $numJour");
              print("===============================================");
            }
            compte = 100000000;
          }
        }
      }
    }

    //Services plein
    List<int> dimension = getDimension();

    for (int numJour = 0; numJour < 5; numJour++){
      for (int numService = 0; numService < 3; numService++){
        if (planning.length < dimension[numJour*3+numService]){
          if (affichage) {
            print("Le service $numService du jour $numJour n'est pas rempli");
            print("===============================================");
          }
          compte = 100000000;
        }
      }
    }

    //personne n'est affecté un jour ou il n'est pas dispo
    for (int numJour = 0; numJour < 5; numJour++){
      for (int numService = 0; numService < 3; numService++){
        for (int numPersonne = 0; numPersonne < planning[numJour][numService].length; numPersonne++){
          String nom = planning[numJour][numService][numPersonne];

          if (dispos![nom]![numJour*3+numService] == false){
            if (affichage) {
              print("$nom est affecté au service $numService du jour $numJour alors qu'il n'est pas disponible");
              print("===============================================");
            }
            compte = 100000000;
          }
        }
      }
    }

    //CONTRAINTES FAIBLES

    //un service par jour
    for (int numJour = 0; numJour < 5; numJour++){
      Map<String, int> comptePersonne = {};

      for (int numService = 0; numService < 3; numService++){
        for (int numPersonne = 0; numPersonne < planning[numJour][numService].length; numPersonne++){
          String nom = planning[numJour][numService][numPersonne];

          comptePersonne[nom] = comptePersonne[nom] == null ? 1 : comptePersonne[nom]!+1;
        }
      }

      for (String nom in comptePersonne.keys){
        if (comptePersonne[nom]! > 1){
          if (affichage) {
            print("$nom present ${comptePersonne[nom]} fois le jour $numJour");
          }
          compte++;
        }
      }
    }

    //tout le monde a un service
    Map<String, bool> present = {};

    for (int numJour = 0; numJour < 5; numJour++){
      for (int numService = 0; numService < 3; numService++){
        for (int numPersonne = 0; numPersonne < planning[numJour][numService].length; numPersonne++){
          String nom = planning[numJour][numService][numPersonne];

          present[nom] = true;
        }
      }
    }

    for (String nom in dispos!.keys){
      if (dispos![nom]!.contains(true) && present[nom] == null){
        if (affichage) {
          print("$nom n'a pas de service alors qu'il est disponible dans la semaine");
        }
        compte++;
      }
    }

    //equilibre service midi
    Map<String, int> compteService = {};
    for (String nom in dispos!.keys){
      compteService[nom] = 0;
    }

    for (int numJour = 0; numJour < 5; numJour++){
      for (int numService = 0; numService < 3; numService++){
        for (int numPersonne = 0; numPersonne < planning[numJour][numService].length; numPersonne++){
          String nom = planning[numJour][numService][numPersonne];

          if (numService == 1){
            compteService[nom] = compteService[nom]!+1;
          }
        }
      }
    }

    List<String> nomTrie = compteService.keys.toList();
    nomTrie.sort((a,b) {
      return Comparable.compare(compteService[a]!, compteService[b]!);
    });

    int i = 0;
    bool exclue = true;
    while (exclue) {
      exclue = false;
      List<dynamic> dispoPersonne = dispos![nomTrie[i]]!;
      dispoPersonne = [
        for (int i = 0; i < dispoPersonne.length; i++) if (i % 3 ==
            1) dispoPersonne[i]
      ];

      int nbDispo = 0;
      for (bool present in dispoPersonne) {
        if (present) {
          nbDispo++;
        }
      }

      if (nbDispo <= compteService[nomTrie[i]]! && i < nomTrie.length-1) {
        exclue = true;
        i++;
      }
    }

    int min = compteService[nomTrie[i]]!;
    int max = compteService[nomTrie.last]!;

    if (max - min > 1){
      if (affichage) {
        print("${nomTrie.last} a $max service de pause alors que ${nomTrie[i]} a seulement $min services de pause, une difference superieur a 1");
      }
      compte++;
    }


    //equilibre service pause

    compteService = {};
    for (String nom in dispos!.keys){
      compteService[nom] = 0;
    }

    for (int numJour = 0; numJour < 5; numJour++){
      for (int numService = 0; numService < 3; numService++){
        for (int numPersonne = 0; numPersonne < planning[numJour][numService].length; numPersonne++){
          String nom = planning[numJour][numService][numPersonne];

          if (numService != 1){
            compteService[nom] = compteService[nom]!+1;
          }
        }
      }
    }

    nomTrie = compteService.keys.toList();
    nomTrie.sort((a,b) {
      return Comparable.compare(compteService[a]!, compteService[b]!);
    });

    i = 0;
    exclue = true;
    while (exclue) {
      exclue = false;
      List<dynamic> dispoPersonne = dispos![nomTrie[i]]!;
      dispoPersonne = [
        for (int i = 0; i < dispoPersonne.length; i++) if (i % 3 != 1) dispoPersonne[i]
      ];

      int nbDispo = 0;
      for (bool present in dispoPersonne) {
        if (present) {
          nbDispo++;
        }
      }

      if (nbDispo <= compteService[nomTrie[i]]! && i < nomTrie.length-1) {
        exclue = true;
        i++;
      }
    }

    min = compteService[nomTrie[i]]!;
    max = compteService[nomTrie.last]!;

    if (max - min > 1){
      if (affichage) {
        print("${nomTrie.last} a $max service de pause alors que ${nomTrie[i]} a seulement $min services de pause, une difference superieur a 1");
      }
      compte++;
    }

    //pas 2 semaines de suite avec le plus de service
    String jour = tableHistorique.jours[0];
    Map<String,List<int>> dernierPlanning = tableHistorique.getServiceParPersonne(jour);

    int maxServiceMidi = 0;
    int maxServicePause = 0;
    for (String nom in dernierPlanning.keys){
      maxServiceMidi = dernierPlanning[nom]![0] < maxServiceMidi ? maxServiceMidi : dernierPlanning[nom]![0];
      maxServicePause = dernierPlanning[nom]![1] < maxServicePause ? maxServicePause : dernierPlanning[nom]![1];
    }

    List<String> personneMaxMidiPrecedant = [
      for (String nom in dernierPlanning.keys)
        if (dernierPlanning[nom]![0] == maxServiceMidi)
          nom
    ];

    List<String> personneMaxPausePrecedant = [
      for (String nom in dernierPlanning.keys)
        if (dernierPlanning[nom]![1] == maxServicePause)
          nom
    ];

    Map<String, List<int>> comptePersonne = {};
    for (int numJour = 0; numJour < 5; numJour++){

      for (int numService = 0; numService < 3; numService++){
        for (int numPersonne = 0; numPersonne < planning[numJour][numService].length; numPersonne++){
          String nom = planning[numJour][numService][numPersonne];

          comptePersonne[nom] = comptePersonne[nom] == null ? [0,0] : comptePersonne[nom]!;
          if (numService == 1){
            comptePersonne[nom]![0]++;
          }
          else {
            comptePersonne[nom]![1]++;
          }
        }
      }
    }

    maxServiceMidi = 0;
    maxServicePause = 0;
    for (String nom in comptePersonne.keys){
      maxServiceMidi = comptePersonne[nom]![0] < maxServiceMidi ? maxServiceMidi : comptePersonne[nom]![0];
      maxServicePause = comptePersonne[nom]![1] < maxServicePause ? maxServicePause : comptePersonne[nom]![1];
    }

    List<String> personneMaxMidi = [
      for (String nom in comptePersonne.keys)
        if (comptePersonne[nom]![0] == maxServiceMidi)
          nom
    ];

    List<String> personneMaxPause = [
      for (String nom in comptePersonne.keys)
        if (comptePersonne[nom]![1] == maxServicePause)
          nom
    ];

    if (personneMaxMidi.length < comptePersonne.length/2 && personneMaxMidiPrecedant.length < dernierPlanning.length/2) {
      for (String nom in personneMaxMidi) {
        if (personneMaxMidiPrecedant.contains(nom)) {
          if (affichage) {
            print("$nom est une des personne faisant le plus de service du midi, tout comme la semaine derniere");
          }
          compte++;
        }
      }
    }

    if (personneMaxPause.length < comptePersonne.length/2 && personneMaxPausePrecedant.length < dernierPlanning.length/2) {
      for (String nom in personneMaxPause) {
        if (personneMaxPausePrecedant.contains(nom)) {
          if (affichage) {
            print("$nom est une des personne faisant le plus de service de pause, tout comme la semaine derniere");
          }
          compte++;
        }
      }
    }

    //diversifier les positions auxquelles sont les gens
    jour = tableHistorique.jours[0];
    int similarite = 0;
    int total = 0;
    for (int numJour = 0; numJour < 5; numJour++){
      for (int numService = 0; numService < 3; numService++){
        for (int numPersonne = 0; numPersonne < planning[numJour][numService].length; numPersonne++){
          String nom1 = planning[numJour][numService][numPersonne];

          String nom2 = tableHistorique.getPersonne(jour, numJour, numService, numPersonne);
          if (nom2 == "") continue;

          total++;
          if (nom1 == nom2){
            similarite++;
          }
        }
      }
    }

    if (total != 0) {
      if (affichage) {
        print("Le planning est similaire au precedant à ${(similarite / total * 10000).round() / 100}%");
      }
      compte++;
    }

    return compte;
  }

}