// To parse this JSON data, do
//
//     final centroTrabajo = centroTrabajoFromJson(jsonString);

import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';

List<CentroTrabajo> centroTrabajoFromJson(String str) =>
    List<CentroTrabajo>.from(
        json.decode(str).map((x) => CentroTrabajo.fromJson(x)));

String centroTrabajoToJson(List<CentroTrabajo> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CentroTrabajo {
  final String idDivision;
  final String idCentroTrabajo;
  final String textoCentroTrabajo;

  CentroTrabajo({
    required this.idDivision,
    required this.idCentroTrabajo,
    required this.textoCentroTrabajo,
  });

  factory CentroTrabajo.fromJson(Map<String, dynamic> json) => CentroTrabajo(
        idDivision: json["ID_DIVISION"],
        idCentroTrabajo: json["Id_Centro_trabajo"],
        textoCentroTrabajo: json["Texto_Centro_trabajo"],
      );

  Map<String, dynamic> toJson() => {
        "ID_DIVISION": idDivision,
        "Id_Centro_trabajo": idCentroTrabajo,
        "Texto_Centro_trabajo": textoCentroTrabajo,
      };

  factory CentroTrabajo.fromSnapshot(DataSnapshot snapshot) {
    var value = snapshot.value as Map?;
    return CentroTrabajo(
      idDivision: snapshot.key!,
      idCentroTrabajo: value?['Id_Centro_trabajo'] ?? '',
      textoCentroTrabajo: value?['Texto_Centro_trabajo'] ?? '',
    );
  }
}
