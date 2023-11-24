import 'package:phale_mood/classes/journal.dart';

class Database {
  List<Journal> journal;

  Database({required this.journal});

  factory Database.fromJson(Map<String, dynamic>? json) {
    if (json == null || json["journals"] == null) {
      // Return a default instance when JSON is null or lacks the expected structure
      return Database(journal: []);
    }

    return Database(
      journal:
          List<Journal>.from(json["journals"].map((x) => Journal.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "journals": List<dynamic>.from(journal.map((x) => x.toJson())),
      };
}
