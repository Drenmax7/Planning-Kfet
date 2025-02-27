import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:planning_kfet/algorithmePlanning.dart';
import 'package:planning_kfet/data/credit.dart';
import 'package:planning_kfet/widget/aide.dart';
import 'package:planning_kfet/widget/modifierOption.dart';
import 'package:planning_kfet/widget/generationPlanning.dart';
import 'package:planning_kfet/widget/gestionMembre.dart';
import 'package:planning_kfet/widget/historique.dart';
import 'package:planning_kfet/data/planning.dart';

import 'data/dispo.dart';
import 'data/membre.dart';
import 'data/option.dart';

void main() {
  runApp(const MyApp());

  doWhenWindowReady(() {
    appWindow.maximize();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<void> dataLoadAll;
  late final Membre tableMembre;
  late final Planning tablePlanning;
  late final Dispo tableDispo;
  late final Option tableOption;
  late final AlgorithmePlanning algorithmePlanning;

  Future<void> loadData() async{
    tableMembre = Membre();
    tablePlanning = Planning();
    tableDispo = Dispo();
    Credit credit = Credit();
    tableOption = Option();

    await tableMembre.dataLoadMembre;
    await tablePlanning.dataLoadPlanning;
    await tableDispo.dataLoadDispo;
    await credit.dataSavedCredit;
    await tableOption.dataLoadOption;
  }

  @override
  void initState() {
    super.initState();

    algorithmePlanning = AlgorithmePlanning();
    dataLoadAll = loadData();
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: dataLoadAll,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          else{
            return DefaultTabController(
              length: 5,
              child: Scaffold(
                appBar: AppBar(
                  title: Text('Planning Kfet 🦆'),
                  bottom: TabBar(
                    tabs: [
                      /*
                      * enregistrer le tableau si appuie sur le bouton screenshot
                      * */
                      Tab(icon: Icon(Icons.calendar_month_outlined), text: 'Generation Planning'),
                      /*
                * fonctionnalité pour deplacer les colonnes
                * verifier que les fichiers sont bien cree si ils n'existent pas deja
                * et mettre en place des samples data
                * installer rust automatiquement si non fait
                * */
                      Tab(icon: Icon(Icons.person), text: 'Gestion Membres'),
                      /*       *
                * si tableau depasse, reduire la police d'ecriture
                * */
                      Tab(icon: Icon(Icons.history), text: 'Historique'),
                      /*
                      permet de changer les couleurs
                      changer le fait qu'un tableau de plus soit genere ou non
                      mode canard on/off (des canards partout !)
                * */
                      Tab(icon: Icon(Icons.settings), text: 'Options'),
                      /*
                * piste d'amelioration de l'appli : liaison google drive pour mettre en ligne automatiquement, lisaison discord pour rappeler les services aux gens
                * ainsi que envoyer le exel de dispo et le planning automatiquement
                * manuel utilisateur decrivant l'appli
                *
                * */
                      Tab(icon: Icon(Icons.help), text: 'Aide'),
                    ],
                  ),
                ),
                body: TabBarView(
                  children: [
                    GenerationPlanning(tableMembre: tableMembre, tablePlanning: tablePlanning, tableDispo: tableDispo, tableOption: tableOption, algorithmePlanning: algorithmePlanning),
                    GestionMembre(tableMembre:tableMembre),
                    Historique(tablePlanning: tablePlanning, tableDispo: tableDispo),
                    ModifierOption(),
                    Aide(),
                  ],
                ),
              ),
            );
          }
        },
    );
  }
}
