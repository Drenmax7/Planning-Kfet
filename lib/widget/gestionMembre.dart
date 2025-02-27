import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:planning_kfet/data/membre.dart';

import '../global.dart';

class GestionMembre extends StatefulWidget{
  final Membre tableMembre;

  const GestionMembre({super.key, required this.tableMembre});


  @override
  State<GestionMembre> createState() => _GestionMembre();
}

class _GestionMembre extends State<GestionMembre>{
  bool ascending = true;
  int columnSort = -1;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Scaffold(
        appBar: toggleColumn(),
        body: contenu(),
        floatingActionButton: bouton(),
      ),
    );
  }

  Widget contenu(){
    return SingleChildScrollView(
        child: Column(
          children: [
            tableau(),
          ],
        ),
    );
  }

  Widget tableau(){
    return Center(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all<Color>(GlobalColor.tableHeader),
          border: TableBorder(
            verticalInside : BorderSide(width: 1, color: Colors.black, style: BorderStyle.solid),
            horizontalInside : BorderSide(width: 1, color: Colors.grey, style: BorderStyle.solid),
          ),
          columns: dataColumn(),
          rows: dataRow(),
        ),
      ),
    );
  }

  List<DataColumn> dataColumn(){
    return [
      for (int column in widget.tableMembre.getVisible())
        DataColumn(
          onSort: (int columnIndex,_) {
            setState(() {
              if (widget.tableMembre.getVisible()[columnIndex] == columnSort){
                ascending = !ascending;
                widget.tableMembre.sort(columnSort, ascending);
              }
              else{
                ascending = true;
                columnSort = widget.tableMembre.getVisible()[columnIndex];
                widget.tableMembre.sort(columnSort, ascending);
              }
            });
          },
          label: Expanded(
            child: Center(
              child: Text(
                widget.tableMembre.getHeader(column),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      DataColumn(
        label: Expanded(
          child: Center(
            child: Text(
              "Actions",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    ];
  }

  List<DataRow> dataRow(){
    return [
      for (int line = 0; line < widget.tableMembre.getHeight(); line++)
        DataRow(
          color: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
            if (widget.tableMembre.isActive(line)){
              if (line%2 == 0) {
                return GlobalColor.tableEvenLine;
              } else {
                return GlobalColor.tableOddLine;
              }}
            else{
              if (line%2 == 0) {
                return GlobalColor.tableEvenLineOFF;
              } else {
                return GlobalColor.tableOddLineOFF;
              }}
            }
          ),
          cells: dataCell(line),
        ),
    ];
  }

  List<DataCell> dataCell(int line){
    return [
      for (int column in widget.tableMembre.getVisible())
        if (widget.tableMembre.getHeader(column) == "Actif")
          DataCell(
            Checkbox(
              value: widget.tableMembre.getCell(column, line) == "1",
              onChanged: (bool? value) {
                setState(() {
                  if (value==null) return;
                  widget.tableMembre.setCell(column, line, value ? "1" : "0");
                });
              },
            ),
          )
        else
          DataCell(
          onTap: () {
            _copyToClipboard(context, widget.tableMembre.getCell(column, line));
          },

          onDoubleTap: (){
            changeDataPopup(context, line, column);
          },

          Center(
            child: Text(
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              widget.tableMembre.getCell(column, line),
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ),
        ),
      DataCell(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              style: TextButton.styleFrom(
                backgroundColor: GlobalColor.buttonRed,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                confirmDeletion(context, line);
              },
              child: Text(
                "Supprimer",
              ),
            ),
            SizedBox(
              width: 10,
            ),
            ElevatedButton(
              style: TextButton.styleFrom(
                backgroundColor: GlobalColor.buttonOrange,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                changePreDispo(line);
              },
              child: Text(
                "Pré-Dispositions",
              ),
            ),
          ],
        ),
      )
    ];
  }


  void _copyToClipboard(BuildContext context, String text) {
    final data = ClipboardData(text: text);
    Clipboard.setData(data).then((_) {
      GlobalColor.afficheSnackBar(context, 'Texte copié dans le presse-papier !');
    });
  }

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
  Future<void> changePreDispo(int numPersonne){
    int height = 500;
    return showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Table(
              columnWidths: {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
              },
              border: TableBorder.all(
                color: Colors.black,
                width: 2,
              ),
              children: [
                for (int numJour = 0; numJour < 5; numJour++)
                  TableRow(
                    children: [
                      //nom du jour
                      Container(
                        height: height/5,
                        color: numJour%2==0 ? GlobalColor.tableEvenLine : GlobalColor.tableOddLine,
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
                              height: height/15,
                              decoration: BoxDecoration(
                                border: numService <=1 ? Border(
                                  bottom: BorderSide(color: Colors.black, width: 1),
                                ) : null,
                                color: numJour%2==0 ? GlobalColor.tableEvenLine : GlobalColor.tableOddLine,
                              ),
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
                      //case
                      Column(
                        children: [
                          for (int numService = 0; numService < 3; numService++)
                            GestureDetector(
                              onTap: (){
                                setState(() {
                                  widget.tableMembre.togglePreDispo(numPersonne, numJour, numService);
                                  Navigator.pop(context);
                                  changePreDispo(numPersonne);
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  border: numService <=1 ? Border(
                                    bottom: BorderSide(color: Colors.black, width: 1),
                                  ) : null,
                                  color: widget.tableMembre.getPreDispo(numPersonne)[numJour*3+numService] ? Colors.blue : Colors.red,
                                ),
                                height: height/15,
                              ),
                            ),
                        ],
                      ),
                    ],
                  )
              ],
            ),
          ),
        )
      ),
    );
  }

  Future<void> changeDataPopup(BuildContext context, int line, int column) async {
    final TextEditingController _controller = TextEditingController(text: widget.tableMembre.getCell(column, line));
    final FocusNode _focusNode = FocusNode();

    //selectionner tout le texte lors de la creation de la popup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
    });

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Empêche de fermer la popup en dehors de celle-ci
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Entrez un texte'),
          content: TextField(
            autofocus: true,
            focusNode: _focusNode,
            controller: _controller,
            decoration: InputDecoration(hintText: "Modifier la ligne"),
            onTap: () => _controller.selection = TextSelection(baseOffset: 0, extentOffset: _controller.value.text.length),
            onSubmitted:  (_) {
              setState(() {
                String enteredText = _controller.text;
                widget.tableMembre.setCell(column, line, enteredText);
                Navigator.of(context).pop(); // Ferme la popup
              });
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Ferme la popup sans faire d'action
                Navigator.of(context).pop();
              },
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  String enteredText = _controller.text;
                  widget.tableMembre.setCell(column, line, enteredText);
                  Navigator.of(context).pop(); // Ferme la popup
                });
              },
              child: Text('Valider'),
            ),
          ],
        );
      },
    );
  }

  Future<void> confirmDeletion(BuildContext context, int line) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Empêche de fermer la popup en dehors de celle-ci
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Etes vous sur de vouloir supprimer la ligne ${widget.tableMembre.getLine(line)} ?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Ferme la popup sans faire d'action
                Navigator.of(context).pop();
              },
              child: Text('Annuler'),
            ),
            TextButton(
              autofocus: true,
              onPressed: () {
                setState(() {
                  widget.tableMembre.deleteLine(line);
                  Navigator.of(context).pop(); // Ferme la popup
                });
              },
              child: Text('Valider'),
            ),
          ],
        );
      },
    );
  }

  Widget bouton(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton.icon(
            onPressed: (){
              setState(() {
                widget.tableMembre.addLine();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: GlobalColor.buttonYellow,
              foregroundColor: Colors.black,
            ),
            icon: Icon(
              Icons.add,
              color: Colors.black,
            ),
            label: Text(
                "Ajouter membre"
            )
        ),
        SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: (){
            widget.tableMembre.save().then((value){
              GlobalColor.afficheSnackBar(context, 'Sauvegarde Effectué');
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: GlobalColor.buttonGreen,
            foregroundColor: Colors.black,
          ),
          icon: Icon(
            Icons.save,
            color: Colors.black,
          ),
          label: Text(
            "Enregistrer",
          ),
        ),
        SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: (){
            widget.tableMembre.genere().then((value){
              GlobalColor.afficheSnackBar(context, 'Tableau crée');
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: GlobalColor.buttonPurple,
            foregroundColor: Colors.black,
          ),
          icon: Icon(
            Icons.calendar_month,
            color: Colors.black,
          ),
          label: Text(
            "Generer Disponibilités",
          ),
        ),
      ],
    );
  }

  AppBar toggleColumn(){
    return AppBar(
      actions: [
        for (int column = 0; column < widget.tableMembre.getWidth(); column++)
          Container(
            padding: EdgeInsets.all(8.0),
            margin: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              children: [
                Text(
                  widget.tableMembre.getHeader(column),
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                Checkbox(
                  value: widget.tableMembre.isVisible(column),
                  onChanged: (bool? value) {
                    setState(() {
                      widget.tableMembre.setVisibility(column, value!);
                    });
                  },
                ),
              ],
            ),
          )
      ],
    );
  }
}