import 'package:flutter/material.dart';
import 'package:planning_kfet/widget/editablePlanning.dart';
import 'package:planning_kfet/data/planning.dart';
import 'package:planning_kfet/global.dart';

import '../data/dispo.dart';

class Historique extends StatefulWidget{
  final Planning tablePlanning;
  final Dispo tableDispo;

  const Historique({super.key, required this.tablePlanning, required this.tableDispo});

  @override
  State<Historique> createState() => _Historique();
}

class _Historique extends State<Historique>{
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _goToPage(int page) {
    setState(() {
      _currentPage = page;
    });
    _pageController.jumpToPage(page);
    // _pageController.animateToPage(page, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Scaffold(
        appBar: boutonsPage(),
        body: contenu(),
      ),
    );
  }

  AppBar boutonsPage(){
    return AppBar(
      title: GestureDetector(
        onTap: () {
          showDatePopup(widget.tablePlanning.getAllDays(fancy: true));
        },
        child: Center(
          child: Text(
            "Semaine du ${widget.tablePlanning.getDay(_currentPage, fancy: true)}",
            style: TextStyle(
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ),
      actions: [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: GlobalColor.buttonRed,
          ),
          onPressed: () {
            showDeleteConfirmation();
          },
          icon: Icon(
            Icons.delete,
            color: Colors.black,
          ),
          label: Text(
            "Supprimer Planning",
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ),
        Container(
          width: 50,
        ),
        IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: _currentPage > 0
              ? () => _goToPage(_currentPage - 1)
              : null, // Désactive le bouton si à la première page
        ),
        IconButton(
          icon: Icon(Icons.arrow_forward),
          onPressed: _currentPage < widget.tablePlanning.getLength()-1
              ? () => _goToPage(_currentPage + 1)
              : null, // Désactive le bouton si à la dernière page
        ),
      ],
    );
  }

  Widget contenu(){
    return PageView(
      controller: _pageController,
      onPageChanged: (int index) {
        setState(() {
          _currentPage = index;
        });
      },
      children: [
        for (int i = 0; i < widget.tablePlanning.getLength(); i++)
          EditablePlanning(
              tablePlanning: widget.tablePlanning,
              tableDispo: widget.tableDispo,
              jour: widget.tablePlanning.getDay(_currentPage),
              editable: false
          )
      ],
    );
  }

  void showDatePopup(List<String> dates) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Sélectionne une date 🦆"),
          content: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < dates.length; i++)
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          width: 1,
                          color: Colors.black,
                        )
                      ),
                      color: i%2 == 0 ? GlobalColor.tableEvenLine : GlobalColor.tableOddLine,

                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: ListTile(
                        title: Center(
                          child: Text(dates[i]),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _goToPage(i);
                        },
                      ),
                    ),
                  )
              ],
            ),
          ),
        );
      },
    );
  }

  void showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Confirmation 🦆"),
          content: Text("Voulez-vous vraiment supprimer cet planning de l'historique ?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Annuler"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  String jour = widget.tablePlanning.getDay(_currentPage);
                  widget.tablePlanning.deletePlanning(jour);
                  widget.tableDispo.deleteDispo(jour);
                  GlobalColor.afficheSnackBar(context, "Le planning a bien été supprimé");
                });// Exécute l'action de suppression
              },
              child: Text("Supprimer", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}