import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';

List<FactEventos> factEventosFromJson(String str) => List<FactEventos>.from(
    json.decode(str).map((x) => FactEventos.fromJson(x)));

String factEventosToJson(List<FactEventos> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class FactEventos {
  String idEvento;
  String tipoEvento;
  String evento;
  String centroTrabajo;
  String dateController;
  String timeController;
  int selectedOption;
  String textonombreempresa;
  String textposition;
  String textodescripcion;
  List<String> selectedFiles;
  String tipoUsuario2;
  double heartRate;
  double systolic;
  double diastolic;
  double oxygen;
  bool hasFever;
  bool hasCough;
  bool hasFatigue;
  bool hasHeadache;
  bool hasWeakness;
  int opcionValida;
  String textomotivono;
  int opcionGravedad;
  String selectedDay;
  double horatrabajo;
  int planemergencias;
  String tipoUsuario;
  String textocausas;
  String textocorrectivas;
  String textoconclusiones;
  String textorecomendaciones;
  String textoseveridad;
  String textolesiones;
  List<String> valoresParteCuerpo;
  String? imagenCuerpo;
  int validacionResponsable;
  String textomotivo2;
  int validacionHSE;

  FactEventos({
    required this.idEvento,
    required this.tipoEvento,
    required this.evento,
    required this.centroTrabajo,
    required this.dateController,
    required this.timeController,
    required this.selectedOption,
    required this.textonombreempresa,
    required this.textposition,
    required this.textodescripcion,
    required this.selectedFiles,
    required this.tipoUsuario2,
    required this.heartRate,
    required this.systolic,
    required this.diastolic,
    required this.oxygen,
    required this.hasFever,
    required this.hasCough,
    required this.hasFatigue,
    required this.hasHeadache,
    required this.hasWeakness,
    required this.opcionValida,
    required this.textomotivono,
    required this.opcionGravedad,
    required this.selectedDay,
    required this.horatrabajo,
    required this.planemergencias,
    required this.tipoUsuario,
    required this.textocausas,
    required this.textocorrectivas,
    required this.textoconclusiones,
    required this.textorecomendaciones,
    required this.textoseveridad,
    required this.textolesiones,
    required this.valoresParteCuerpo,
    this.imagenCuerpo,
    required this.validacionResponsable,
    required this.textomotivo2,
    required this.validacionHSE,
  });

  factory FactEventos.fromJson(Map<String, dynamic> json) => FactEventos(
        idEvento: json["idEvento"],
        tipoEvento: json["tipoEvento"],
        evento: json["evento"],
        centroTrabajo: json["centroTrabajo"],
        dateController: json["dateController"],
        timeController: json["timeController"],
        selectedOption: json["selectedOption"],
        textonombreempresa: json["textonombreempresa"],
        textposition: json["textposition"],
        textodescripcion: json["textodescripcion"],
        selectedFiles: List<String>.from(json["selectedFiles"].map((x) => x)),
        tipoUsuario2: json["tipoUsuario2"],
        heartRate: json["heartRate"].toDouble(),
        systolic: json["systolic"].toDouble(),
        diastolic: json["diastolic"].toDouble(),
        oxygen: json["oxygen"].toDouble(),
        hasFever: json["hasFever"],
        hasCough: json["hasCough"],
        hasFatigue: json["hasFatigue"],
        hasHeadache: json["hasHeadache"],
        hasWeakness: json["hasWeakness"],
        opcionValida: json["opcionValida"],
        textomotivono: json["textomotivono"],
        opcionGravedad: json["opcionGravedad"],
        selectedDay: json["selectedDay"],
        horatrabajo: json["horatrabajo"].toDouble(),
        planemergencias: json["planemergencias"],
        tipoUsuario: json["tipoUsuario"],
        textocausas: json["textocausas"],
        textocorrectivas: json["textocorrectivas"],
        textoconclusiones: json["textoconclusiones"],
        textorecomendaciones: json["textorecomendaciones"],
        textoseveridad: json["textoseveridad"],
        textolesiones: json["textolesiones"],
        valoresParteCuerpo:
            List<String>.from(json["valoresParteCuerpo"].map((x) => x)),
        imagenCuerpo: json["imagenCuerpo"],
        validacionResponsable: json["validacionResponsable"],
        textomotivo2: json["textomotivo2"],
        validacionHSE: json["validacionHSE"],
      );

  Map<String, dynamic> toJson() => {
        "idEvento": idEvento,
        "tipoEvento": tipoEvento,
        "evento": evento,
        "centroTrabajo": centroTrabajo,
        "dateController": dateController,
        "timeController": timeController,
        "selectedOption": selectedOption,
        "textonombreempresa": textonombreempresa,
        "textposition": textposition,
        "textodescripcion": textodescripcion,
        "selectedFiles": List<dynamic>.from(selectedFiles.map((x) => x)),
        "tipoUsuario2": tipoUsuario2,
        "heartRate": heartRate,
        "systolic": systolic,
        "diastolic": diastolic,
        "oxygen": oxygen,
        "hasFever": hasFever,
        "hasCough": hasCough,
        "hasFatigue": hasFatigue,
        "hasHeadache": hasHeadache,
        "hasWeakness": hasWeakness,
        "opcionValida": opcionValida,
        "textomotivono": textomotivono,
        "opcionGravedad": opcionGravedad,
        "selectedDay": selectedDay,
        "horatrabajo": horatrabajo,
        "planemergencias": planemergencias,
        "tipoUsuario": tipoUsuario,
        "textocausas": textocausas,
        "textocorrectivas": textocorrectivas,
        "textoconclusiones": textoconclusiones,
        "textorecomendaciones": textorecomendaciones,
        "textoseveridad": textoseveridad,
        "textolesiones": textolesiones,
        "valoresParteCuerpo":
            List<dynamic>.from(valoresParteCuerpo.map((x) => x)),
        "imagenCuerpo": imagenCuerpo,
        "validacionResponsable": validacionResponsable,
        "textomotivo2": textomotivo2,
        "validacionHSE": validacionHSE,
      };
  factory FactEventos.fromSnapshot(DataSnapshot snapshot) {
    return FactEventos(
      idEvento: snapshot.child("idEvento").value as String? ?? '',
      tipoEvento: snapshot.child("tipoEvento").value as String? ?? '',
      evento: snapshot.child("evento").value as String? ?? '',
      centroTrabajo: snapshot.child("centroTrabajo").value as String? ?? '',
      dateController: snapshot.child("dateController").value as String? ?? '',
      timeController: snapshot.child("timeController").value as String? ?? '',
      selectedOption: snapshot.child("selectedOption").value as int? ?? 0,
      textonombreempresa:
          snapshot.child("textonombreempresa").value as String? ?? '',
      textposition: snapshot.child("textposition").value as String? ?? '',
      textodescripcion:
          snapshot.child("textodescripcion").value as String? ?? '',
      selectedFiles: List<String>.from(
          snapshot.child("selectedFiles").value != null
              ? (snapshot.child("selectedFiles").value as List)
                  .map((x) => x as String)
              : []),
      tipoUsuario2: snapshot.child("tipoUsuario2").value as String? ?? '',
      heartRate: (snapshot.child("heartRate").value as num?)?.toDouble() ?? 0.0,
      systolic: (snapshot.child("systolic").value as num?)?.toDouble() ?? 0.0,
      diastolic: (snapshot.child("diastolic").value as num?)?.toDouble() ?? 0.0,
      oxygen: (snapshot.child("oxygen").value as num?)?.toDouble() ?? 0.0,
      hasFever: snapshot.child("hasFever").value as bool? ?? false,
      hasCough: snapshot.child("hasCough").value as bool? ?? false,
      hasFatigue: snapshot.child("hasFatigue").value as bool? ?? false,
      hasHeadache: snapshot.child("hasHeadache").value as bool? ?? false,
      hasWeakness: snapshot.child("hasWeakness").value as bool? ?? false,
      opcionValida: snapshot.child("opcionValida").value as int? ?? 0,
      textomotivono: snapshot.child("textomotivono").value as String? ?? '',
      opcionGravedad: snapshot.child("opcionGravedad").value as int? ?? 0,
      selectedDay: snapshot.child("selectedDay").value as String? ?? '',
      horatrabajo:
          (snapshot.child("horatrabajo").value as num?)?.toDouble() ?? 0.0,
      planemergencias: snapshot.child("planemergencias").value as int? ?? 0,
      tipoUsuario: snapshot.child("tipoUsuario").value as String? ?? '',
      textocausas: snapshot.child("textocausas").value as String? ?? '',
      textocorrectivas:
          snapshot.child("textocorrectivas").value as String? ?? '',
      textoconclusiones:
          snapshot.child("textoconclusiones").value as String? ?? '',
      textorecomendaciones:
          snapshot.child("textorecomendaciones").value as String? ?? '',
      textoseveridad: snapshot.child("textoseveridad").value as String? ?? '',
      textolesiones: snapshot.child("textolesiones").value as String? ?? '',
      valoresParteCuerpo: List<String>.from(
          snapshot.child("valoresParteCuerpo").value != null
              ? (snapshot.child("valoresParteCuerpo").value as List)
                  .map((x) => x as String)
              : []),
      imagenCuerpo: snapshot.child("imagenCuerpo").value as String?,
      validacionResponsable:
          snapshot.child("validacionResponsable").value as int? ?? 0,
      textomotivo2: snapshot.child("textomotivo2").value as String? ?? '',
      validacionHSE: snapshot.child("validacionHSE").value as int? ?? 0,
    );
  }
}
