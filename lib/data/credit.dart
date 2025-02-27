import 'package:planning_kfet/data/stockage.dart';

class Credit {
  late Future<void> dataSavedCredit;


  Credit() {
    dataSavedCredit = _initializeData();
  }

  Future<void> _initializeData() async {
    String message = "Cette application a été développé par Maxendre Coulon, promo 2026, secretaire de la Kfet 2024-2025\n";
    message += "Elle a été conçu dans le but d'aider à la conception des emplois du temps de la Kfet et a pour ambition d'être passé de génération en génération\n";
    message += "Le code source est en libre accès sur mon GitHub : https://github.com/Drenmax7/Planning-Kfet.git\n";
    message += "L'application a été développé en dart à l'aide de Flutter\n";
    message += "Mes contacts :\n\tTelephone : 06 21 42 41 84\n\tMail : maxendrecoulon@gmail.com";
    //await Stockage.writeJson(message, Stockage.credit);
  }
}