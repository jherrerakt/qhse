import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';

List<ParteCuerpo> parteCuerpoFromJson(String str) => List<ParteCuerpo>.from(
    json.decode(str).map((x) => ParteCuerpo.fromJson(x)));

String parteCuerpoToJson(List<ParteCuerpo> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ParteCuerpo {
  final String idParteCuerpo;
  final String textoParteCuerpo;

  ParteCuerpo({
    required this.idParteCuerpo,
    required this.textoParteCuerpo,
  });

  factory ParteCuerpo.fromJson(Map<String, dynamic> json) => ParteCuerpo(
        idParteCuerpo: json["Id_ParteCuerpo"],
        textoParteCuerpo: json["Texto_ParteCuerpo"],
      );

  Map<String, dynamic> toJson() => {
        "Id_ParteCuerpo": idParteCuerpo,
        "Texto_ParteCuerpo": textoParteCuerpo,
      };

  factory ParteCuerpo.fromSnapshot(DataSnapshot snapshot) {
    return ParteCuerpo(
      idParteCuerpo: snapshot.child("Id_ParteCuerpo").value as String? ?? '',
      textoParteCuerpo:
          snapshot.child("Texto_ParteCuerpo").value as String? ?? '',
    );
  }
}
