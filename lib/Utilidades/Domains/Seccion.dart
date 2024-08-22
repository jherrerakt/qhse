import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';

List<Seccion> seccionFromJson(String str) =>
    List<Seccion>.from(json.decode(str).map((x) => Seccion.fromJson(x)));

String seccionToJson(List<Seccion> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Seccion {
  final String idSeccion;
  final String textoSeccion;
  final String idCentroTrabajo;

  Seccion({
    required this.idSeccion,
    required this.textoSeccion,
    required this.idCentroTrabajo,
  });

  factory Seccion.fromJson(Map<String, dynamic> json) => Seccion(
      idSeccion: json["Id_Seccion"],
      textoSeccion: json["Texto_Seccion"],
      idCentroTrabajo: json["Id_Centro_trabajo"]);

  Map<String, dynamic> toJson() => {
        "Id_Seccion": idSeccion,
        "Texto_Seccion": textoSeccion,
        "Id_Centro_trabajo": idCentroTrabajo
      };

  factory Seccion.fromSnapshot(DataSnapshot snapshot) {
    return Seccion(
      idCentroTrabajo:
          snapshot.child("Id_Centro_trabajo").value as String? ?? '',
      idSeccion: snapshot.child("Id_Seccion").value as String? ?? '',
      textoSeccion: snapshot.child("Texto_Seccion").value as String? ?? '',
    );
  }
}
