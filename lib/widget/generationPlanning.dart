
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:planning_kfet/algorithmePlanning.dart';
import 'package:planning_kfet/data/dispo.dart';
import 'package:planning_kfet/data/membre.dart';
import 'package:planning_kfet/data/stockage.dart';
import 'package:planning_kfet/global.dart';

import '../data/excelIO.dart';
import '../data/option.dart';
import '../data/planning.dart';

class GenerationPlanning extends StatefulWidget{
  final Planning tablePlanning;
  final Membre tableMembre;
  final Dispo tableDispo;
  final Option tableOption;
  final AlgorithmePlanning algorithmePlanning;


  const GenerationPlanning({super.key, required this.tablePlanning, required this.tableMembre, required this.tableDispo, required this.tableOption, required this.algorithmePlanning});

  @override
  State<GenerationPlanning> createState() => _GenerationPlanning();
}

class _GenerationPlanning extends State<GenerationPlanning> {
  List<String> onglets = ["Import Dispos","Option de Génération","Planning"];
  int ongletActuelle = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    widget.algorithmePlanning.tableMembre = widget.tableMembre;

    return Scaffold(
      /*
      * Un onglet pour importer les dispos
      *   - posibilité d'importer en glissant ou en choississant dans l'explorateur de fichier
      *   - lit le fichier selectionné et affiche un recapitulatif de la lecture sur la droite
      * Un onglet pour naviguer a travers les plannings, qui les generes a la volée
      *   - un bouton qui permet d'enregistrer le planning actuel, pop up qui propose la date d'enregistrement du planning
      *     avec la date du prochain lundi en temps que date de base, message d'alerte si jour choisi est un jour ou un planning existe deja
      * Un onglet d'option de generation de planning
      *   - les options sur l'algo
      *   - nombre de personne par service, sous forme d'un tableau avec des cases a cocher
      * */
      appBar: AppBar(
        title: Row(
          children: [
            for (int numOnglet = 0; numOnglet < onglets.length; numOnglet++)
              GestureDetector(
                onTap: () {
                  setState(() {
                    ongletActuelle = numOnglet;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: ongletActuelle == numOnglet ? Colors.blue[400] : Colors.grey[300],
                    borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                  ),
                  child: Text(
                    onglets[numOnglet],
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
      body: contenu(),
    );
  }

  Widget contenu(){
    if (ongletActuelle == 0){
      return importDispo();
    }
    if (ongletActuelle == 1){
      return optionGeneration();
    }
    if (ongletActuelle == 2){
      return choixPlanning();
    }

    return Center(child: Text("Onglet invalide"));
  }

  String? fileName;

  void pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx','txt'],
      initialDirectory: await Stockage.localPath,
    );

    if (result != null) {
      setState(() {
        fileName = result.files.single.name;
        if (result.files.single.path != null){
          widget.algorithmePlanning.dispos = ExcelIO.lire(result.files.single.path!);
        }
      });
    }
  }

  Widget importDispo(){
    return Row(
      children: [
        Expanded(
          child: Center(
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue[50], // Fond doux bleu
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.blue.shade200, blurRadius: 10, offset: Offset(2, 4))
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Importe un fichier (format .xlsx ou .txt) 📄",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: pickFile,
                    icon: Icon(Icons.upload_file),
                    label: Text(
                      "Choisir un fichier",
                      style: TextStyle(
                        fontSize: 26,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[400],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    fileName ?? "Aucun fichier sélectionné",
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (widget.algorithmePlanning.dispos != null)
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  spacing: 10,
                  children: [
                    Text(
                      "Recapitulatif Dispos",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Table(
                      columnWidths: {
                        0: FlexColumnWidth(1),
                        1: FlexColumnWidth(1),
                      },
                      border: TableBorder.all(
                        color: Colors.black,
                        width: 2,
                      ),
                      children: [
                        TableRow(
                          children: [
                            Container(
                              color: GlobalColor.tableHeader,
                              child: Center(
                                child: Text(
                                  "Membres",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              color: GlobalColor.tableHeader,
                              child: Center(
                                child: Text(
                                  "Total disponible",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        for (int i = 0; i < widget.algorithmePlanning.dispos!.keys.length; i++)
                          TableRow(
                            children: [
                              Container(
                                color: i%2==0 ? GlobalColor.tableEvenLine : GlobalColor.tableOddLine,
                                child: Center(
                                  child: Text(
                                    widget.algorithmePlanning.dispos!.keys.toList()[i],
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                color: i%2==0 ? GlobalColor.tableEvenLine : GlobalColor.tableOddLine,
                                child: Center(
                                  child: Text(
                                    widget.algorithmePlanning.dispos!.values.toList()[i].where((b) => b).length.toString(),
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ]
                          )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  late List<Color> couleurJourTableau;
  late List<List<Color>> couleurServiceTableau;
  late List<List<List<Color>>> couleurPersonneTableau;
  void determinerCouleur(){
    couleurJourTableau = [];
    couleurServiceTableau = [];
    couleurPersonneTableau = [];

    for (int numJour = 0; numJour < 5; numJour++){
      Color couleurJour = Colors.red;
      List<Color> couleurServiceJour = [];
      List<List<Color>> couleurPersonneJour = [];

      bool jourGrise = true;
      for (int numService = 0; numService < 3; numService++){
        Color couleurService = Colors.red;
        List<Color> couleurPersonneService = [];

        bool serviceGrise = true;
        for (int numPersonne = 0; numPersonne < widget.tableOption.getNbColonne(); numPersonne++){
          Color couleurPersonne = Colors.red;

          if (numJour%2 == 0){
            if (widget.tableOption.isOn(numJour, numService, numPersonne)){
              couleurPersonne = GlobalColor.tableEvenLine;
              serviceGrise = false;
            }
            else{
              couleurPersonne = GlobalColor.tableEvenLineOFF;
            }
          }
          else{
            if (widget.tableOption.isOn(numJour, numService, numPersonne)){
              couleurPersonne = GlobalColor.tableOddLine;
              serviceGrise = false;
            }
            else{
              couleurPersonne = GlobalColor.tableOddLineOFF;
            }
          }

          couleurPersonneService.add(couleurPersonne);
        }

        if (numJour%2 == 0){
          if (serviceGrise){
            couleurService = GlobalColor.tableEvenLineOFF;
          }
          else{
            couleurService = GlobalColor.tableEvenLine;
            jourGrise = false;
          }
        }
        else{
          if (serviceGrise){
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

  List<Map<String, dynamic>> options = [
    {"label": "Maximum un service par jour"}, //si une personne est mise sur un service, elle ne peut pas etre mise sur un autre service de la journée
    {"label": "Tout le monde a un service"}, //fais de son mieux pour placer tout le monde sur au moins un service
    {"label": "Équilibre service midi"}, //evite qu'une personne ait 3 services et une autre 1
    {"label": "Équilibre service pause"},//identique pour les pauses
    {"label": "Pas 2x le plus de service"}, //si quelqu'un a eu beaucoup de service la semaine qui precede, il en aura peu celle la
    {"label": "Évite les similitudes d'une semaine à l'autre"}, //permet de varier les positions des membres, pas toujours les memes services aux memes jours
    {"label": "Semblable au plus récent planning (en cas de modification)"}, //si il faut modifier le planning et qu'il a deja ete envoyé, on prefere eviter de trop le changer
   ];
  Widget optionGeneration(){
    List<String> nomColonnePlanning = ["Jours","Services","Crenaux"];
    List<String> nomJours = ["Lundi","Mardi","Mercredi","Jeudi","Vendredi","Samedi","Dimanche"];
    List<String> nomServices = ["Matin","Midi","Après-midi"];

    determinerCouleur();

    int height = 400;
    return Row(
      children: [
        Expanded(
          child: Container(
            margin: EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.blue,
                width: 2.0,
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (int numOption = 0; numOption < options.length; numOption++)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          widget.tableOption.toggleOption(numOption);
                        });
                      },
                      child: Container(
                        color: numOption%2 == 0 ? GlobalColor.tableEvenLine : GlobalColor.tableOddLine,
                        child: ListTile(
                          title: Text(options[numOption]["label"]),
                          trailing: Checkbox(
                            value: widget.tableOption.getOption(numOption),
                            onChanged: (bool? newValue) {
                              setState(() {
                                widget.tableOption.toggleOption(numOption);
                              });
                            },
                          ),
                        ),
                      ),
                    )
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.all(24.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          widget.tableOption.addColonne();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GlobalColor.buttonGreen,
                      ),
                      icon: Icon(
                        Icons.add_circle,
                        color: Colors.black,
                      ),
                      label: Text(
                        "Ajouter colonne",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(width: 20,),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          widget.tableOption.deleteColonne();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GlobalColor.buttonRed,
                      ),
                      icon: Icon(
                        Icons.remove_circle_outline,
                        color: Colors.black,
                      ),
                      label: Text(
                        "Supprimer colonne",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20,),
                Table(
                  columnWidths: {
                    0: FlexColumnWidth(1),
                    1: FlexColumnWidth(1),
                    2: FlexColumnWidth(widget.tableOption.getNbColonne().toDouble()),
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
                                    fontSize: 18,
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
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                widget.tableOption.toggleColonneJour(numJour);
                              });
                            },
                            child: Container(
                              height: height/5,
                              color: couleurJourTableau[numJour],
                              child: Center(
                                child: Text(
                                  nomJours[numJour],
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          //nom des periodes
                          Column(
                            children: [
                              for (int numService = 0; numService < 3; numService++)
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      widget.tableOption.toggleColonneService(numJour, numService);
                                    });
                                  },
                                  child: Container(
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
                                      for (int numPersonne = 0; numPersonne < widget.tableOption.getNbColonne(); numPersonne++)
                                      //une colonne pour chaque personne du service
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: (){
                                              //appelé lorsque l'utilisateur clique sur une case 'personne'
                                              setState(() {
                                                widget.tableOption.toggleColonne(numJour, numService, numPersonne);
                                              });
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: numPersonne >= 1 ? Border(
                                                  left: BorderSide(color: Colors.black, width: 1),
                                                ) : null,
                                                color: couleurPersonneTableau[numJour][numService][numPersonne],
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
              ],
            ),
          ),
        ),
      ],
    );
  }


  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _goToPage(int page) {
    setState(() {
      _currentPage = page;
    });
    _pageController.jumpToPage(page);
    // _pageController.animateToPage(page, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  Widget choixPlanning(){
    if (widget.algorithmePlanning.getNbPlanning() == 0){
      return Center(
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Colors.blue.shade200, blurRadius: 10, offset: Offset(2, 4))
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Génerer un planning 🤖",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  widget.algorithmePlanning.option = widget.tableOption.option;
                  widget.algorithmePlanning.dimension = widget.tableOption.template;
                  widget.algorithmePlanning.tableHistorique = widget.tablePlanning;
                  String erreur = widget.algorithmePlanning.genereNouveauPlanning();

                  if (erreur != ""){
                    GlobalColor.afficheSnackBar(context, erreur);
                  }
                  else{
                    setState(() {
                    });
                  }
                },
                icon: Icon(Icons.timer),
                label: Text(
                  "Générer",
                  style: TextStyle(
                    fontSize: 26,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[400],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
      );
    }
    else{
      return Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text("Planning n°${_currentPage+1} / ${widget.algorithmePlanning.getNbPlanning()}"),
          ),
          actions: [
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  widget.algorithmePlanning.reinitialiser();
                  _goToPage(0);
                });
              },
              label: Text("Supprimer tous les plannings"),
              icon: Icon(
                Icons.delete,
                color: Colors.black,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: GlobalColor.buttonRed,
                foregroundColor: Colors.black,
              ),

            ),
            Container(width: 50),
            ElevatedButton.icon(
              onPressed: () {
                showDateSelectionDialog();
              },
              label: Text("Enregistrer ce planning"),
              icon: Icon(
                Icons.save,
                color: Colors.black,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: GlobalColor.buttonGreen,
                foregroundColor: Colors.black,
              ),

            ),
            Container(width: 50),
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: _currentPage > 0
                  ? () => _goToPage(_currentPage - 1)
                  : null, // Désactive le bouton si à la première page
            ),
            IconButton(
              icon: Icon(Icons.arrow_forward),
              onPressed: _currentPage < widget.algorithmePlanning.getNbPlanning()-1
                  ? () => _goToPage(_currentPage + 1)
                  : () {
                widget.algorithmePlanning.genereNouveauPlanning();
                _goToPage(_currentPage + 1);
              }, // Désactive le bouton si à la dernière page
            ),
          ],
        ),
        body: PageView(
          controller: _pageController,
          children: [
            for (int numPage = 0; numPage < widget.algorithmePlanning.getNbPlanning(); numPage++)
              //widget.algorithmePlanning.getPlanning(numPage)
              widget.algorithmePlanning.getPlanning(numPage,showDateSelectionDialog)
          ],
        ),
      );
    }
  }

  late DateTime monday;
  Future<void> showDateSelectionDialog({bool selfCall = false}) async {
    if (!selfCall) {
      DateTime today = DateTime.now();
      monday = today.add(Duration(days: (8 - today.weekday) % 7));
    }

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return KeyboardListener(
          autofocus: true,
          onKeyEvent: (KeyEvent event) {
            if(event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter){
              enregistrer(monday);
              Navigator.pop(context);
            }
          },
          focusNode: FocusNode(),
          child: AlertDialog(
              title: Text("Choisir une date 🗓️"),
              content: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_left, size: 30),
                    onPressed: () {
                      setState(() {
                        monday = monday.subtract(Duration(days: 7));
                        Navigator.pop(context);
                        showDateSelectionDialog(selfCall: true);
                      });
                    },
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "Lundi ${Planning.getFancy(DateFormat('dd/MM/yyyy').format(monday))}",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  IconButton(
                      icon: Icon(Icons.arrow_right, size: 30),
                      onPressed: () {
                        setState(() {
                          monday = monday.add(Duration(days: 7));
                          Navigator.pop(context);
                          showDateSelectionDialog(selfCall: true);
                        });
                      }
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Annuler"),
                ),
                ElevatedButton(
                  onPressed: () {
                    enregistrer(monday);
                    Navigator.pop(context);
                  },
                  child: Text("Valider"),
                ),
              ],
            ),
        );
      },
    );
  }

  void enregistrer(DateTime date){
    List<List<List<String>>> planning = widget.algorithmePlanning.tablePlanning.planningList["$_currentPage"];
    widget.tablePlanning.addPlanning(DateFormat('dd/MM/yyyy').format(date), planning);
    widget.tableDispo.addDispo(DateFormat('dd/MM/yyyy').format(date), widget.algorithmePlanning.tableDispo.dispo["$_currentPage"]);

    GlobalColor.afficheSnackBar(context, "Emploi du temps enregistré");
  }
}