import 'package:flutter/material.dart';
import 'package:planning_kfet/global.dart';

import '../data/option.dart';

class ModifierOption extends StatefulWidget{

  const ModifierOption({super.key});

  @override
  State<ModifierOption> createState() => _ModifierOption();
}

class _ModifierOption extends State<ModifierOption> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: contenu(),
    );
  }

  double width = 0;
  Widget contenu(){
    width = 600;
    return Center(
      heightFactor: 2,
      child: SizedBox(
        child: SingleChildScrollView(
          child: Table(
            columnWidths: {
              0: IntrinsicColumnWidth(), // Ajuste à la largeur du texte 🦆
              1: FixedColumnWidth(100),
            },
            children: [
              for (int i = 0; i < Option.nombreOption; i++)
                getOptionNb(i)
            ],
          ),
        ),
      ),
    );
  }

  TableRow getOptionNb(int numOption){
    Color color = numOption%2==0 ? GlobalColor.tableEvenLine : GlobalColor.tableOddLine;

    TextStyle nomStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18,
    );
    Text nom = Text("Option overflow $numOption", style: nomStyle);

    TextStyle descriptionStyle = TextStyle(
      fontSize: 14,
      color: Colors.grey[700],
    );
    Text description = Text("Option overflow $numOption", style: descriptionStyle);
    Container action = Container(color:color, child: Text("Option overflow"));

    switch (numOption){
      case 0 : {
        nom = Text("Nombre de colonne par tableau", style: nomStyle,);
        description = Text("Combien de nom seront affiché sur chaque tableau de fichier de demande de disponibilité", style: descriptionStyle,);
        action = Container(
          color: color,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: Option.NB_NOM_PAR_LIGNE > 1 ? () {
                  setState(() {
                    Option.NB_NOM_PAR_LIGNE -= 1;
                    Option.saveSpecific();
                  });
                } : null,
              ),
              Text(Option.NB_NOM_PAR_LIGNE.toString()),
              IconButton(
                icon: Icon(Icons.arrow_forward),
                onPressed: () {
                  setState(() {
                    Option.NB_NOM_PAR_LIGNE += 1;
                    Option.saveSpecific();
                  });
                },
              ),
            ],
          ),
        );
        break;
      }
      case 1 : {
        nom = Text("Extra tableau", style: nomStyle,);
        description = Text("Doit-il y avoir un tableau supplémentaire, complétement vide dans le fichier de demande de disponibilité", style: descriptionStyle,);
        action = Container(
          color: color,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Checkbox(
                value: Option.EXTRA_TABLE,
                onChanged: (newValue) {
                  setState(() {
                    Option.EXTRA_TABLE = newValue!;
                    Option.saveSpecific();
                  });
                },
              )
            ],
          ),
        );
        break;
      }
      case 2 : {
        nom = Text("Noms colorés", style: nomStyle,);
        description = Text("Afficher ou non une case de couleur à coté des noms du planning pour aider à trouver son nom pour un membre", style: descriptionStyle,);
        action = Container(
          color: color,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Checkbox(
                value: Option.COULEUR_NOM,
                onChanged: (newValue) {
                  setState(() {
                    Option.COULEUR_NOM = newValue!;
                    Option.saveSpecific();
                  });
                },
              )
            ],
          ),
        );
        break;
      }
    }

    return TableRow(
        children: [
          TableCell(
            child: Container(
              color: color,
              child: Column(
                children: [
                  nom,
                  description,
                ],
              ),
            ),
          ),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.fill,
            child: action,
          ),
        ]
    );
  }
}
