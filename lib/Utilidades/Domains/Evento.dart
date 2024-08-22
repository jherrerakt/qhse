import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';

List<Evento> eventoFromJson(String str) =>
    List<Evento>.from(json.decode(str).map((x) => Evento.fromJson(x)));

String eventoToJson(List<Evento> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Evento {
  final String idTipoEvento;
  final String idClaseEvento;
  final String textoEvento;
  final String textoEventoResumido;

  Evento({
    required this.idTipoEvento,
    required this.idClaseEvento,
    required this.textoEvento,
    required this.textoEventoResumido,
  });

  factory Evento.fromJson(Map<String, dynamic> json) => Evento(
        idTipoEvento: json["IdTipoEvento"],
        idClaseEvento: json["Id_Clase_Evento"],
        textoEvento: json["Texto_Evento"],
        textoEventoResumido: json["Texto_Evento_RESUMIDO"],
      );

  Map<String, dynamic> toJson() => {
        "IdTipoEvento": idTipoEvento,
        "Id_Clase_Evento": idClaseEvento,
        "Texto_Evento": textoEvento,
        "Texto_Evento_RESUMIDO": textoEventoResumido,
      };

  factory Evento.fromSnapshot(DataSnapshot snapshot) {
    var value = snapshot.value as Map?;
    return Evento(
      idTipoEvento: value?['IdTipoEvento'] ?? '',
      idClaseEvento: value?['Id_Clase_Evento'] ?? '',
      textoEvento: value?['Texto_Evento'] ?? '',
      textoEventoResumido: value?['Texto_Evento_RESUMIDO'] ?? '',
    );
  }
}
