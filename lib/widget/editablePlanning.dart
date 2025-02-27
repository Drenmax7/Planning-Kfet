
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:planning_kfet/data/option.dart';
import 'package:planning_kfet/global.dart';
import 'package:planning_kfet/data/planning.dart';
import 'package:super_clipboard/super_clipboard.dart';

import '../data/dispo.dart';
import '../data/membre.dart';
import '../data/stockage.dart';

class EditablePlanning extends StatefulWidget{
  final Planning tablePlanning;
  //si table membre est fourni les membres seront ajouté au tableau listant les personnes et leurs services, meme si ils n'ont aucun
  final Membre? tableMembre;

  //si table dispo est fourni les membres seront caché si ils ne sont pas disponible sur un jour
  final Dispo? tableDispo;
  final String jour;
  final bool editable;
  final Function? saveFunction;

  const EditablePlanning({super.key, required this.jour, required this.tablePlanning, this.tableMembre, this.tableDispo, this.editable = false, this.saveFunction});

  @override
  State<EditablePlanning> createState() => _EditablePlanning();
}

class _EditablePlanning extends State<EditablePlanning>{
  static const List<String> nomJours = [
    "Lundi",
    "Mardi",
    "Mercredi",
    "Jeudi",
    "Vendredi",
    "Samedi",
    "Dimanche",
  ];
  static const List<String> nomServices = [
    "Matin",
    "Midi",
    "Après-midi",
  ];
  static const List<String> nomColonnePlanning = [
    "Jours",
    "Services",
    "STAFF",
  ];

  GlobalKey previewContainer = GlobalKey();

  late Map<String,List<int>> listeMembrePlanning;
  //trié par ordre croissant des services des membres
  late List<String> listeMembre;
  int sortingColumn = 0;

  late Map<String,Color> couleurAssocie;

  @override
  void initState() {
    super.initState();

    initList();
    determinerCouleur();
  }

  void initList(){
    listeMembrePlanning = widget.tablePlanning.getServiceParPersonne(widget.jour);
    listeMembre = listeMembrePlanning.keys.toList();

    if (widget.tableMembre != null){
      List<String> listeMembreActuelle = widget.tableMembre!.getUniqueName();
      for (String personne in listeMembreActuelle){
        if (listeMembrePlanning[personne] == null){
          listeMembrePlanning[personne] = [0,0];
          listeMembre.add(personne);
        }
      }
    }

    couleurAssocie = {};
    List<String> nomPresent = listeMembrePlanning.keys.toList();
    for (int i = 0; i < nomPresent.length; i++){
      String nom = nomPresent[i];

      double hue = i * 360 / nomPresent.length;
      Color color = HSLColor.fromAHSL(1.0, hue, 0.8, 0.6).toColor();

      couleurAssocie[nom] = color;
    }
  }

  void trieMembre(){
    if (sortingColumn == -1){
      listeMembre.sort((a,b) {
        return Comparable.compare(a,b);
      });
    }
    else{
      listeMembre.sort((a,b) {
        int serviceA = listeMembrePlanning[a]![sortingColumn];
        int serviceB = listeMembrePlanning[b]![sortingColumn];
        return Comparable.compare(serviceA, serviceB);
      });
    }

    determinerCouleur();
  }

  Future<void> takeScreenShot() async{
    final boundary = previewContainer.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage();
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData?.buffer.asUint8List();
    final directory = await Stockage.localPath;
    final imgFile = File('$directory/${Stockage.screenshot}');
    imgFile.writeAsBytes(pngBytes!);

    final clipboard = SystemClipboard.instance;
    if (clipboard == null) {
      return; // Clipboard API is not supported on this platform.
    }
    final item = DataWriterItem();
    item.add(Formats.png(pngBytes));
    await clipboard.write([item]);

    GlobalColor.afficheSnackBar(context, "Image copié dans le presse papier");
  }

  @override
  Widget build(BuildContext context) {
    determinerCouleur();

    trieMembre();
    int height = 500;


    return Scaffold(
      appBar: AppBar(
        actions: [
          boutons(),
        ],
      ),
      body: Center(
        child: Container(
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: RepaintBoundary( //pour capturer le widget en screenshot
                  key: previewContainer,
                  child: tableau(height),
                ),
              ),
              Expanded(
                  flex: 2,
                  child:  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Row(
                      children: [
                        Expanded(
                          child: recapitulatif(height, true),
                        ),
                        Expanded(
                          child: recapitulatif(height, false),
                        ),
                      ],
                    ),
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget tableau(int height){
    return Container(
      padding: EdgeInsets.all(5),
      color: Colors.white,
      child: Table(
        columnWidths: {
          0: FlexColumnWidth(1),
          1: FlexColumnWidth(1),
          2: FlexColumnWidth(widget.tablePlanning.getMaxServicePlanning(widget.jour).toDouble()),
        },
        border: TableBorder.all(
          color: Colors.black,
          width: 2,
        ),
        children: [
          //les entetes de colonnes
          TableRow(
            children: [
              for (int numColonne = 0; numColonne < 3; numColonne++)
                Container(
                  color: GlobalColor.tableHeader,
                  child: Center(
                    child: Text(
                      nomColonnePlanning[numColonne],
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ]
          ),
          //chaque ligne de jour
          for (int numJour = 0; numJour < 5; numJour++)
            TableRow(
              children: [
                //nom du jour
                Container(
                  height: height/5,
                  color: couleurJourTableau[numJour],
                  child: Center(
                    child: Text(
                      nomJours[numJour],
                      style: TextStyle(
                        fontSize: 26,
                      ),
                    ),
                  ),
                ),
                //nom des periodes
                Column(
                  children: [
                    for (int numService = 0; numService < 3; numService++)
                      Container(
                        decoration: BoxDecoration(
                          border: numService <=1 ? Border(
                            bottom: BorderSide(color: Colors.black, width: 1),
                          ) : null,
                          color: couleurServiceTableau[numJour][numService],
                        ),
                        height: height/15,
                        child: Center(
                          child: Text(
                            nomServices[numService],
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ),
                      )
                  ],
                ),
                //nom des gens
                Column(
                  children: [
                    for (int numService = 0; numService < 3; numService++)
                    //une ligne pour chaque service
                      Container(
                        decoration: BoxDecoration(
                          //color: numJour%2==0 ? GlobalColor.tableEvenLine : GlobalColor.tableOddLine,
                          border: numService <=1 ? Border(
                            bottom: BorderSide(color: Colors.black, width: 1),
                          ) : null,
                        ),
                        height: height/15,
                        child: Row(
                          children: [
                            for (int numPersonne = 0; numPersonne < widget.tablePlanning.getMaxServicePlanning(widget.jour); numPersonne++)
                            //une colonne pour chaque personne du service
                              Expanded(
                                child: GestureDetector(
                                  onTap: (){
                                    //appelé lorsque l'utilisateur clique sur une case 'personne'
                                    setState(() {
                                      cliquePlanning(numJour, numService, numPersonne);
                                    });
                                  },
                                  onSecondaryTap: () {
                                    setState(() {
                                      if (widget.editable){
                                        widget.tablePlanning.deletePersonne(widget.jour, numJour, numService, numPersonne);
                                        initList();
                                      }
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: numPersonne >= 1 ? Border(
                                        left: BorderSide(color: Colors.black, width: 1),
                                      ) : null,
                                      color: couleurPersonneTableau[numJour][numService][numPersonne],
                                    ),
                                    child: Container(
                                      decoration: determinerBordure(null, [numJour, numService, numPersonne]),
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: Center(
                                                child: Text(
                                                  widget.tablePlanning.getPersonne(widget.jour, numJour, numService, numPersonne),
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            if (Option.COULEUR_NOM && widget.tablePlanning.getPersonne(widget.jour, numJour, numService, numPersonne) != "")
                                              SizedBox(
                                                  width: 30,
                                                  child: Align(
                                                      alignment: Alignment.centerLeft,
                                                      child: Container(
                                                        width: 20,
                                                        height: 20,
                                                        color: couleurAssocie[widget.tablePlanning.getPersonne(widget.jour, numJour, numService, numPersonne)],
                                                        child: Center(
                                                          child: Text(
                                                            listeMembrePlanning[widget.tablePlanning.getPersonne(widget.jour, numJour, numService, numPersonne)]!.reduce((a,b) => a+b).toString(),
                                                          ),
                                                        ),
                                                      ),
                                                  ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  //montre 2 tableaux listant les memmbres et le nombre de service qu'ils font sur ce planning
  //les tableaux sont respectivement trié par odre croissant et decroissant en fonction du nombre de service
  Widget recapitulatif(int height, bool croissant){
    List<String> liste = listeMembre;
    if (croissant) liste = liste.reversed.toList();

    return Container(
      padding: EdgeInsets.all(5),
      child: Table(
        border: TableBorder.all(
          color: Colors.black,
          width: 2,
        ),
        children: [
          //header
          TableRow(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    sortingColumn = -1;
                  });
                },
                child: Container(
                  height: height/15*2,
                  color: GlobalColor.tableHeader,
                  child: Center(
                    child: Text(
                      "Membres",
                      style: TextStyle(
                        fontSize: 22,
                      ),
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: GlobalColor.tableHeader,
                      border: Border(
                        bottom: BorderSide(color: Colors.black, width: 1),
                      ),
                    ),
                    height: height/15,
                    child: Center(
                      child: Text(
                        "Services",
                        style: TextStyle(
                          fontSize: 22,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              sortingColumn = 0;
                            });
                          },
                          child: Container(
                            height: height/15,
                            decoration: BoxDecoration(
                              color: GlobalColor.tableHeader,
                              border: Border(
                                right: BorderSide(color: Colors.black, width: 1),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                "Midi",
                                style: TextStyle(
                                  fontSize: 22,
                                ),
                              ),
                            ),
                          ),
                        )
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              sortingColumn = 1;
                            });
                          },
                          child: Container(
                            height: height/15,
                            color: GlobalColor.tableHeader,
                            child: Center(
                              child: Text(
                                "Pauses",
                                style: TextStyle(
                                  fontSize: 22,
                                ),
                              ),
                            ),
                          ),
                        )
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          //une ligne pour chaque personne du planning
          for (int numPersonne = 0; numPersonne < liste.length; numPersonne++)
            TableRow(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      cliqueRecapitulatif(liste[numPersonne]);
                    });
                  },
                  child: Container(
                  height: height/15,
                  color: couleurRecapitulatif[liste[numPersonne]],
                  child: Container(
                    decoration: determinerBordure(liste[numPersonne], null),
                    child: Center(
                      child: Text(
                        liste[numPersonne],
                        style: TextStyle(
                          fontSize: 22,
                        ),
                      ),
                    ),
                  ),
                ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      cliqueRecapitulatif(liste[numPersonne]);
                    });
                  },
                  child: Container(
                    height: height/15,
                    color: couleurRecapitulatif[liste[numPersonne]],
                    child: Row(
                      children: [
                        for (int i = 0; i < 2; i++)
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: i == 0 ? Border(
                                  right: BorderSide(width: 1, color: Colors.black),
                                ) : null,
                              ),
                              child: Center(
                                child: Text(
                                  listeMembrePlanning[liste[numPersonne]]![i].toString(),
                                  style: TextStyle(
                                    fontSize: 22,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget boutons(){
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: (){
            if (widget.saveFunction != null) widget.saveFunction!();
            takeScreenShot();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: GlobalColor.buttonOrange,
          ),
          icon: Icon(
            Icons.camera_alt,
            color: Colors.black,
          ),
          label: Text(
            "Screenshot",
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }


  String nomActif = "";
  List<int>? caseClique;
  int dernierClique = 0;
  static const int PLANNING = 1;
  static const int RECAPITULATIF = 2;

  void cliquePlanning(int numJour, int numService, int numPersonne) {
    String personne = widget.tablePlanning.getPersonne(widget.jour, numJour, numService, numPersonne);

    //si la personne clique sur un nom du planning, puis clique de nouveau sur le meme nom : on le deselectionne
    if (dernierClique == PLANNING && listEquals(caseClique, [numJour, numService, numPersonne])){
      nomActif = "";
      dernierClique = 0;
      caseClique = null;
    }

    //si la personne clique sur un nom du planning, puis clique sur un autre nom du planning : on selectionne le nouveau nom
    else if (dernierClique == PLANNING && !listEquals(caseClique, [numJour, numService, numPersonne])){
      nomActif = personne;
      caseClique = [numJour, numService, numPersonne];
    }

    //si la personne clique sur un nom du recapitulatif, puis clique sur une case du tableau : on place la personne sur la case cliqué
    else if (dernierClique == RECAPITULATIF){
      if (widget.editable) {
        String message = widget.tablePlanning.placePersonne(
            nomActif,
            widget.jour, numJour, numService, numPersonne,
            widget.tableDispo,
            forcefull: false
        );

        if (message != ""){
          GlobalColor.afficheSnackBar(context, message);
        }
        else{
          initList();
        }

      }

      nomActif = "";
      dernierClique = 0;
      caseClique = null;
    }

    //si la personne clique sur le planning alors qu'aucune personne n'est selectionné
    else if (dernierClique == 0){
      nomActif = personne;
      caseClique = [numJour, numService, numPersonne];
      dernierClique = PLANNING;
    }

    determinerCouleur();
  }

  void cliqueRecapitulatif(String personne) {

    //si la personne clique sur un nom du recapitulatif alors qu'aucune personne n'est selectionné
    if (dernierClique == 0){
      nomActif = personne;
      dernierClique = RECAPITULATIF;
    }

    //si la personne clique de nouveau sur la meme personne de recapitulatif : on la deselectionne
    else if (dernierClique == RECAPITULATIF && nomActif == personne){
      nomActif = "";
      dernierClique = 0;
    }

    //si la personne a deja cliqué sur un nom de recapitulatif mais clique sur un autre nom de recapitulatif : on selectionne la nouvel personne
    else if (dernierClique == RECAPITULATIF && nomActif != personne){
      nomActif = personne;
    }

    //si la personne a cliqué sur une case du tableau puis sur un nom de recapitulatif : on place la personne de recapitulatif dans le tableau
    else if (dernierClique == PLANNING){
      int numJour = caseClique![0];
      int numService = caseClique![1];
      int numPersonne = caseClique![2];
      caseClique = null;

      if (widget.editable) {
        String message = widget.tablePlanning.placePersonne(
            personne,
            widget.jour, numJour, numService, numPersonne,
            widget.tableDispo,
            forcefull: false
        );

        if (message != ""){
          GlobalColor.afficheSnackBar(context, message);
        }
        else{
          initList();
        }

      }

      dernierClique = 0;
      nomActif = "";
    }

    determinerCouleur();
  }


  /*
  *  on peut cliquer sur un nom de recapitulatif puis sur une case du tableau pour placer le nom dans le tableau
  *  les autres lignes de recapitulatif passe en grisé
  * le nom cliqué est entouré de doré
  * une lignes du tableau est grisé si la personne n'est pas disponible sur cette journée ou si elle est deja placé dedans
  * les cases ou cette personne est restent de la bonne couleur et le nom est entouré de bleu
  *
  *  on peut cliquer sur une case du tableau puis sur une case de rcapitulatif pour mettre la personne de recapitulatif dans la case
  * la case cliqué a une surbrillance doré, et ce nom est entouré en bleu dans le tableau
  * les noms de recapitulatif passent en grisé si la personne est indisponible sur ce jour la
  * sinon reste de la bonne couleur
  *
  * */

  void determinerCouleur(){
    determinerTableau();
    determinerRecapitulatif();
  }

  late List<Color> couleurJourTableau;
  late List<List<Color>> couleurServiceTableau;
  late List<List<List<Color>>> couleurPersonneTableau;
  /*
  * Remplis 3 variables
  * couleurJourTableau qui donne la couleur de chaque case jour du tableau
  *   - si toutes les cases du jour sont grisé alors le jour aussi
  *   - sinon le jour est de la couleur normal, alterné en fonciton de la parité
  * couleurServiceTableau
  *   - si toutes les cases du service sont grisé alors le service aussi
  *   - sinon le service est de la couleur normal en fonction de la parité
  * couleurPersonneTableau
  *   - si personne selectionné par recapitulatif
  *     - si la personne selectionné ne peut pas etre placé sur cette case elle est grisé
  *     - si la personne selectionné est celle de la case alors elle est coloré normalement
  *     - si la personne peut etre placé sur cette case alors elle est coloré
  *  - si personne selectionné par tableau ou pas de selection
  *     - coloré normalement en fonction de la parité
  * */
  void determinerTableau(){
    couleurPersonneTableau = [];
    couleurServiceTableau = [];
    couleurJourTableau = [];

    //attribue les couleurs aux cases personne
    for (int numJour = 0; numJour < 5; numJour++){
      List<List<Color>> couleurPersonneJour = [];
      List<Color> couleurServiceJour = [];
      Color couleurJour = Colors.red;

      bool jourGrise = true;
      for (int numService = 0; numService < 3; numService++){
        List<Color> couleurPersonneService = [];
        Color couleurService = Colors.red;

        bool griseService = true;
        //attribue aux cases personnes leur couleur, et notifie si la ligne entiere est grise
        for (int numPersonne = 0; numPersonne < widget.tablePlanning.getMaxServicePlanning(widget.jour); numPersonne++){
          Color couleurPersonne = Colors.red;

          //couleur a afficher si il n'y a aucun nom de selectionner
          if (dernierClique == 0 || dernierClique == PLANNING){
            if (numJour%2 == 0) {
              if (widget.tablePlanning.getPersonne(widget.jour, numJour, numService, numPersonne) == ""){
                couleurPersonne = GlobalColor.tableEvenLineOFF;
              }
              else{
                couleurPersonne = GlobalColor.tableEvenLine;
                griseService = false;
              }
            }
            else{
              if (widget.tablePlanning.getPersonne(widget.jour, numJour, numService, numPersonne) == ""){
                couleurPersonne = GlobalColor.tableOddLineOFF;
              }
              else{
                couleurPersonne = GlobalColor.tableOddLine;
                griseService = false;
              }
            }
          }
          else if (dernierClique == RECAPITULATIF){
            bool grise = false;
            if (widget.tableDispo != null) {
              grise = !widget.tableDispo!.isDisponible(widget.jour, nomActif, numJour, numService);
            }

            bool presentSurLigne = false;
            for (int iPersonne = 0; iPersonne < widget.tablePlanning.getMaxServicePlanning(widget.jour); iPersonne++){
              //il faut check si la personne est sur la ligne mais n'est pas la case cliqué
              presentSurLigne |= widget.tablePlanning.getPersonne(widget.jour, numJour, numService, iPersonne) == nomActif;
            }

            String nomCase = widget.tablePlanning.getPersonne(widget.jour, numJour, numService, numPersonne);
            bool memeNom = nomActif == nomCase;
            bool vide = nomCase == "";

            if (numJour%2 == 0){
              //si la personne n'est pas dispo ou que son nom est present sur la ligne (a l'exception de si c'est la case elle meme) on grise
              if ((grise || presentSurLigne || vide) && !memeNom){
                couleurPersonne = GlobalColor.tableEvenLineOFF;
              }
              else{
                couleurPersonne = GlobalColor.tableEvenLine;
                griseService = false;
              }
            }
            else{
              if ((grise || presentSurLigne || vide) && !memeNom){
                couleurPersonne = GlobalColor.tableOddLineOFF;
              }
              else{
                couleurPersonne = GlobalColor.tableOddLine;
                griseService = false;
              }
            }

          }

          couleurPersonneService.add(couleurPersonne);
        }

        //attribue aux cases services leur couleur
        if (numJour%2 == 0){
          if (griseService){
            couleurService = GlobalColor.tableEvenLineOFF;
          }
          else{
            couleurService = GlobalColor.tableEvenLine;
            jourGrise = false;
          }
        }
        else{
          if (griseService){
            couleurService = GlobalColor.tableOddLineOFF;
          }
          else{
            couleurService = GlobalColor.tableOddLine;
            jourGrise = false;
          }
        }

        couleurServiceJour.add(couleurService);
        couleurPersonneJour.add(couleurPersonneService);
      }

      //attribue aux cases jour leur couleur
      if (numJour%2 == 0){
        if (jourGrise){
          couleurJour = GlobalColor.tableEvenLineOFF;
        }
        else{
          couleurJour = GlobalColor.tableEvenLine;
        }
      }
      else{
        if (jourGrise){
          couleurJour = GlobalColor.tableOddLineOFF;
        }
        else{
          couleurJour = GlobalColor.tableOddLine;
        }
      }

      couleurJourTableau.add(couleurJour);
      couleurServiceTableau.add(couleurServiceJour);
      couleurPersonneTableau.add(couleurPersonneJour);
    }
  }

  late Map<String, Color> couleurRecapitulatif;
  /*
  * Remplit couleurRecapitulatif qui donne la couleur de la ligne de chaque nom de recapitulatif
  *   - si personne de selectionné par recapitulatif ou aucune selction
  *     - colores de facon normal, en fonction de la paraité
  *   - si personne selectionné par tableau
  *     - si personne de recapitulatif peut etre placé dans la case du tableau alors coloré normalement
  *     - sinon grisé
  * */
  void determinerRecapitulatif(){
    couleurRecapitulatif = {};

    for (int numPersonne = 0; numPersonne < listeMembre.length; numPersonne++){
      Color couleurPersonne = Colors.red;

      //couleur a afficher si il n'y a aucun nom de selectionner
      if (dernierClique == 0 || dernierClique == RECAPITULATIF){
        if (numPersonne%2 == 0) {
          couleurPersonne = GlobalColor.tableEvenLine;
        }
        else{
          couleurPersonne = GlobalColor.tableOddLine;
        }
      }
      //couleur a afficher si il y a d'abord eu un clique sur le planning
      else if (dernierClique == PLANNING){
        bool grise = false;
        if (widget.tableDispo != null) {
          grise = !widget.tableDispo!.isDisponible(widget.jour, listeMembre[numPersonne], caseClique![0], caseClique![1]);
        }

        bool presentSurLigne = false;
        for (int iPersonne = 0; iPersonne < widget.tablePlanning.getMaxServicePlanning(widget.jour); iPersonne++){
          //il faut check si la personne est sur la ligne mais n'est pas la case cliqué
          presentSurLigne |= widget.tablePlanning.getPersonne(widget.jour, caseClique![0], caseClique![1], iPersonne) == listeMembre[numPersonne];
        }

        if (numPersonne%2 == 0) {
          if (grise || presentSurLigne){
            couleurPersonne = GlobalColor.tableEvenLineOFF;
          }
          else{
            couleurPersonne = GlobalColor.tableEvenLine;
          }
        }
        else{
          if (grise || presentSurLigne){
            couleurPersonne = GlobalColor.tableOddLineOFF;
          }
          else{
            couleurPersonne = GlobalColor.tableOddLine;
          }
        }
      }

      couleurRecapitulatif[listeMembre[numPersonne]] = couleurPersonne;
    }
  }

  /*
  * Remplit bordure nom qui donne la bordure a appliqué autour de chaque nom
  *   - si nom identique alors bordure ovale bleu
  *   - si nom different pas de bordure
  * */
  BoxDecoration? determinerBordure(String? personne, List<int>? caseTableau){
    BoxDecoration doree = BoxDecoration(
      border: Border.all(color: Colors.amber, width: 4),
    );
    BoxDecoration bleu = BoxDecoration(
      border: Border.all(color: Colors.blue, width: 4),
      borderRadius: BorderRadius.circular(25),
    );

    if (personne != null && personne == nomActif){
      if (caseClique == null) {
        return doree;
      }
      else{
        return bleu;
      }
    }

    if (caseTableau != null && listEquals(caseTableau, caseClique)){
      return doree;
    }

    if (caseTableau != null){
      if (nomActif != "" && nomActif == widget.tablePlanning.getPersonne(widget.jour, caseTableau[0], caseTableau[1], caseTableau[2])) {
        return bleu;
      }
    }

    return null;
  }
}