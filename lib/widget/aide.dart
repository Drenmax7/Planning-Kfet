import 'package:flutter/material.dart';
import 'package:planning_kfet/global.dart';

class Aide extends StatefulWidget{

  const Aide({super.key});

  @override
  State<Aide> createState() => _Aide();
}

class _Aide extends State<Aide> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: contenu(),
    );
  }

  double width = 0;
  Widget contenu(){
    width = MediaQuery.of(context).size.width / 3*2;
    return Center(
      heightFactor: 1,
      child: SizedBox(
        width: width,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              onglet(0),
              onglet(1),
              onglet(2),
            ],
          ),
        ),
      ),
    );
  }

  Widget onglet(int numOnglet){
    return Container(
      color: numOnglet%2==0 ? Colors.grey[200] : Colors.grey[300],
      child: ExpansionTile(
        title: Text(
          titres[numOnglet],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 26,
          ),
        ),
        subtitle: detail[numOnglet] == "" ? null : Text(
          detail[numOnglet],
          style: TextStyle(
            fontSize: 18,
          ),
        ),
        children: numOnglet == 0 ? faq()
            : numOnglet == 1 ? manuel()
            : numOnglet == 2 ? credit()
            : []
      ),
    );
  }


  List<Map<String,String>> question = [
    {
      "q":"Comment ajouter un membre ?",
      "r":"La gestion des membres s'effectue dans l'onglet 'Gestion Membres', le deuxième onglet de la barre\n"
          "Il faut ensuite appuyer sur le bouton jaune en bas à droite 'Ajouter Membre'\n"
          "Une nouvelle ligne sera alors ajouté au tableau\n"
          "Tous les champs de la ligne sont initialisé à 'N/a' et il n'y a qu'à effectuer un double clique sur un champs pour le modifier\n"
          "Il n'y a alors qu'à activer le membre en appuyant sur la checkbox de la colonne 'Actif', la ligne se colorera alors en vert ou jaune"
    },
    {
      "q":"Comment générer un excel permettant aux membres de remplir leurs disponibilités ?",
      "r":"Cela peut se faire en un seul clique !\n"
          "Il suffit d'aller dans l'onglet 'Gestion Memnres', le deuxième onglet de la barre\n"
          "On peut ensuite voir en bas à droite un bouton violet 'Generer disponibilités\n"
          "Ce bouton génere un tableau contenant tous les membres actifs et le place dans le dossier de l'executable de l'application"
    },
    {
      "q":"Un des membres ne pourra jamais faire de service le vendredi et voudrait que j'en prenne compte dans le tableau de demande.",
      "r":"Il existe une fonctionnalité permettant cela\n"
          "Il s'agit du bouton 'Pré-Disposition' dans la colonne action du tableau des membres\n"
          "Ce bouton ouvre une popup qui permet de définir une préference pour chacun des services de la semaine\n"
          "Il faut donc cocher les cases des 3 services du vendredi afin que le vendredi soit automatiquement compté comme indisponible pour ce membre dans le tableau de demande des disponibilités"
    },
    {
      "q":"Un membre vient souhaite partir de la Kfet, comment l'enlever des plannings ?",
      "r":"Tu as 2 possibilités pour gérer ce cas de figure\n"
          "Si tu penses que ce membre est succeptible de revenir tu peux simplement supprimer son nom du tableau de gestion des membres\n"
          "Tu peux faire cela via le bouton 'supprimer' de la colonne action\n"
          "Ce bouton supprimera définitivement ce membre du tableau\n"
          "Sinon, si le membres pourrait revenir, tu peux 'désactiver' le membre\n"
          "Cela se fait en cliquant sur la checkbox de la colonne actif du tableau\n"
          "Le membre sera alors considéré comme inactif est ne sera plus considéré par les foncitonnalités de l'application"
    },
    {
      "q":"Les membres ont rempli leurs disponibilités, que dois je faire du tableau ?",
      "r":"Assure toi d'abord que ton tableau est sous le format '.xlsx'\n"
          "C'est le format que l'application utilise pour la lecture et l'ecriture de tableau, si tu as changé le format l'application ne pourra pas lire le tableau\n"
          "Tu peux ensuite aller dans le premier onglet 'Generation Planning', puis le premier sous-onglet 'Import Dispos'\n"
          "Le tableau peut ensuite etre importé grace au bouton au centre de l'ecran\n"
          "Apres selection du tableau tu auras un récapitulatif des inforamtions lus sur la droite de l'écran\n"
          "Si tu n'as pas toutes les informations ou que tu as une erreur, verifie que la valeur de l'option 'nombre de colonne par tableau'"
          "correspond bien à la dimension de chaque tableau de ton fichier\n"
          "Tu peux ensuite aller dans le 3eme sous-onglet et cliquer sur le bouton 'Generer' pour generer automatiquement un planning"
    },
    {
      "q":"Comment récuperer le planning maintenant qu'il a été crée ?",
      "r":"Tu peux utiliser le bouton orange 'screenshot' présent vers le haut de l'écran sur la droite\n"
          "Ce bouton va constituer une image du planning que tu vois et l'enregistrer dans le dossier qui contient l'executable du planning\n"
          "L'image est également placé dans ton presse-papier, toute préte pour etre mise sur un salon Discord\n"
          "Fais cependant attention que tu vois l'integralité du planning sur la fenetre de l'application sans quoi tu ne verras qu'une partie du planning sur l'image\n"
          "Je te conseille d'enregistrer le planning que tu choisis, ça te permettra de le revoir plus tard"
    },
    {
      "q":"Mardi prochain est ferié, comment eviter que la planning place des membres sur les services du mardi ?",
      "r":"Tu peux modifier les jours et services actif dans le premier onglet 'Generation Planning', puis dans le 2eme sous-onglet 'Option de génération'\n"
          "Il y a sur la doite de l'écran un tableau qui permet de gérer ce parametre\n"
          "Pour désactiver le mardi il te suffit d'appuyer sur la case mardi et tu vas voir toutes les cases du mardi se griser, indiquant qu'aucun membre ne seront placé la\n"
    },
    {
      "q":"Nous sommes trop peu lors des services du midi, comment augmenter le placement des membres à 5 ?",
      "r":"Tu peux modifier le nombre de personne par service dans le premier onglet 'Generation Planning', puis dans le 2eme sous-onglet 'Option de génération'\n"
          "Il y a sur la doite de l'écran un tableau qui permet de gérer ce parametre\n"
          "Au dessus du tableau tu as 2 boutons, permettant d'ajouter ou d'enlever des colonnes au tableau\n"
          "Si il y a actuellement 4 colonnes, tu peux appuyer une fois sur le bouton vert 'Ajouter colonne' pour en ajouter une 5eme"
    },
    {
      "q":"Je ne comprend pas ce que signifie toutes ces couleurs qui apparaissent lorsque je clique sur une case d'un planning !",
      "r":"La case sur laquelle tu as cliqué contient le nom d'un membre\n"
          "L'application met en evidence les services où cette personne est placé en entourant ces srervices d'un rond bleu\n"
          "La case sur laquelle tu as cliqué est quand à elle encadré d'un cadre doré\n"
          "Si tu as cliqué sur une case du planning (tableau de gauche) alors tu vas voir que certains noms deviennent grisé dans les tableaux de droite\n"
          "Cela signifie que ces personnes ne peuvent pas etre placé dans la case sur laquelle tu as cliqué, "
          "soit parce qu'elles sont deja dans ce service, soit parce que ils sont marqué comme indisponible pour "
          "ce service dans le fichier de demande de disponibilité\n"
          "Si c'est sur une case des tableaux récapitulatif (à droite) que tu as cliqué alors c'est des noms du planning qui vont etre grisé\n"
          "Cette fois ci, si une case est grisé cela signifie que la persoonne sur laquelle tu as cliqué ne peut pas etre placé dedans, pour les mêmes raisons que précèdemment"
    },
    {
      "q":"Le planning qui a été généré est vraiment mauvais",
      "r":"Tu as 2 solutions pour regler ce probleme\n"
          "Tu peux soit essayer de génerer de nouveaux planning, ce qui se fait trés facilement\n"
          "Dans l'outil de visualisation de planning que tu vois aprés avoir généré un planning automatiquement tu peux voir 2 fleches vers le haut de l'écran sur la droite\n"
          "Il suffit d'apppuyer sur la fleche de droite pour génerer un nouveau planning\n"
          "Si les plannings que tu généres ainsi sont toujours mauvais tu peux essayer de modifier les parametres de génération\n"
          "Les meilleurs résultats sont obtenus lorsque toutes les options sont coché mise à part de la dernière, celle pour faire un planning similaire\n"
          "Si cela ne suffit pas alors c'est probable qu'il y ait trop de contraintes imposé à l'algorithme (membres indisponible), et il faut donc te résigner "
          "à diminuer le nombre de personne sur certains service, ou même eventuellement à en enlever"
    },
    {
      "q":"Le planning qui a été généré est presque parfait, comment y faire une modification ?",
      "r":"Les plannings qui sont générés automatiquement sont modifiable !\n"
          "Pour ce faire tu n'as qu'à cliquer dans le tableau récapitulatif (à droite) sur le nom que tu veux ajouter, "
          "puis sur la case du tableau dans laquelle tu veux placer ce nom\n"
          "Les cases grisés sont les cases sur lesquelles tu ne peux pas placer cette personne, car elle est soit indisponible, soit déjà sur ce service\n"
          "Tu peux aussi d'abord cliquer sur la case que tu veux changer, puis sur le membre que tu veux mettre"
    },

  ];

  List<Widget> faq(){
    return [
      for (int numOnglet = 0; numOnglet < question.length; numOnglet++)
        Container(
        color: numOnglet%2==0 ? GlobalColor.tableEvenLine : GlobalColor.tableOddLine,
        child: ExpansionTile(
            title: Text(
              question[numOnglet]["q"]!,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            children: reponse(numOnglet),
        ),
      )
    ];
  }

  List<Widget> reponse(int numOnglet){
    return [
      paragraphe(question[numOnglet]["r"]!)
    ];
  }

  List<Widget> manuel(){
    return [

    ];
  }

  List<Widget> credit(){
    return [
      titre("Créateur"),
      paragraphe("Cette application a été développé par Maxendre Coulon, promo 2026, secretaire de la Kfet 2024-2025"),
      titre("Contact"),
      paragraphe("GitHub : https://github.com/Drenmax7\nTelephone : 06 21 42 41 84\nMail : maxendrecoulon@gmail.com"),
      titre("But de l'application"),
      paragraphe("Cette application a été conçu dans le but d'aider à la conception des emplois du temps de la Kfet et a pour ambition d'être passé de génération en génération"),
    ];
  }

  Widget paragraphe(String texte){
    return SizedBox(
      width: width-100,
      child: SelectableText(
        texte,
        style: TextStyle(
          fontSize: 18,
        ),
      ),
    );
  }

  Widget titre(String texte){
    return Container(
      width: width -50,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            width: 2
          )
        )
      ),
      child: Text(
        texte,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }


}

List<String> titres = ["FAQ","Manuel Utilisateur","Crédit"];
List<String> detail = [
  "Differents scenarios d'usage permettant de prendre en main l'application",
  "Liste exhaustive des fonctionnalité de l'application",
  ""
];