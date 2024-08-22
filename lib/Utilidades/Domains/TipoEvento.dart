import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';

List<TipoEvento> tipoEventoFromJson(String str) =>
    List<TipoEvento>.from(json.decode(str).map((x) => TipoEvento.fromJson(x)));

String tipoEventoToJson(List<TipoEvento> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TipoEvento {
  final String idEvento;
  final String textoEvento;

  TipoEvento({
    required this.idEvento,
    required this.textoEvento,
  });

  factory TipoEvento.fromJson(Map<String, dynamic> json) => TipoEvento(
        idEvento: json["Id_Evento"],
        textoEvento: json["Texto_Evento"],
      );

  Map<String, dynamic> toJson() => {
        "Id_Evento": idEvento,
        "Texto_Evento": textoEvento,
      };

  factory TipoEvento.fromSnapshot(DataSnapshot snapshot) {
    var value = snapshot.value as Map?;
    return TipoEvento(
      idEvento: value?['Id_Evento'] ?? '',
      textoEvento: value?['Texto_Evento'] ?? '',
    );
  }
}
