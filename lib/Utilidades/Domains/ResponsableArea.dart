import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';

List<ResponsableArea> responsableAreaFromJson(String str) =>
    List<ResponsableArea>.from(
        json.decode(str).map((x) => ResponsableArea.fromJson(x)));

String responsableAreaToJson(List<ResponsableArea> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ResponsableArea {
  final String idResponsableAreaSeccion;
  final String idSeccion;
  final String nombreResponsableAreaSeccion;

  ResponsableArea({
    required this.idResponsableAreaSeccion,
    required this.idSeccion,
    required this.nombreResponsableAreaSeccion,
  });

  factory ResponsableArea.fromJson(Map<String, dynamic> json) =>
      ResponsableArea(
        idResponsableAreaSeccion: json["ID_Responsable_Area_Seccion"],
        idSeccion: json["IdSeccion"],
        nombreResponsableAreaSeccion: json["Nombre_Responsable_Area_Seccion"],
      );

  Map<String, dynamic> toJson() => {
        "ID_Responsable_Area_Seccion": idResponsableAreaSeccion,
        "IdSeccion": idSeccion,
        "Nombre_Responsable_Area_Seccion": nombreResponsableAreaSeccion,
      };
  factory ResponsableArea.fromSnapshot(DataSnapshot snapshot) {
    return ResponsableArea(
      idResponsableAreaSeccion:
          snapshot.child("ID_Responsable_Area_Seccion").value as String? ?? '',
      idSeccion: snapshot.child("IdSeccion").value as String? ?? '',
      nombreResponsableAreaSeccion:
          snapshot.child("Nombre_Responsable_Area_Seccion").value as String? ??
              '',
    );
  }
}
