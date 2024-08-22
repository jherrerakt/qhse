import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';

ComunicacionRiesgo comunicacionRiesgoFromJson(String str) =>
    ComunicacionRiesgo.fromJson(json.decode(str));

String comunicacionRiesgoToJson(ComunicacionRiesgo data) =>
    json.encode(data.toJson());

class ComunicacionRiesgo {
  int num;
  String accionInmediata;
  String descripcion;
  String dialogo;
  final String directorioArchivos;
  final String fechaEntrada;
  String idAmbito;
  String idCentroTrabajo;
  final String idEstatus;
  final int idRegistro;
  String idSeccion;
  final String idTipoComunicacion;
  final String idUsuarioDeclarante;
  String idUsuarioProyectoAsignado;
  String idUsuarioResponsableAreaSeccion;
  String motivoRechazoValidacion;
  final String nombreUsuarioDeclarante;
  String nombreUsuarioProyectoAsignado;
  String nombreUsuarioResponsableAreaSeccion;
  bool requierePlanAccion;
  String validadoResponsableArea;
  List<String> imageUrls;
  List<String> documentUrls;

  ComunicacionRiesgo(
      {required this.num,
      required this.accionInmediata,
      required this.descripcion,
      required this.dialogo,
      required this.directorioArchivos,
      required this.fechaEntrada,
      required this.idAmbito,
      required this.idCentroTrabajo,
      required this.idEstatus,
      required this.idRegistro,
      required this.idSeccion,
      required this.idTipoComunicacion,
      required this.idUsuarioDeclarante,
      required this.idUsuarioProyectoAsignado,
      required this.idUsuarioResponsableAreaSeccion,
      required this.motivoRechazoValidacion,
      required this.nombreUsuarioDeclarante,
      required this.nombreUsuarioProyectoAsignado,
      required this.nombreUsuarioResponsableAreaSeccion,
      required this.requierePlanAccion,
      required this.validadoResponsableArea,
      required this.imageUrls,
      required this.documentUrls});

  factory ComunicacionRiesgo.fromJson(Map<String, dynamic> json) =>
      ComunicacionRiesgo(
        num: json["num"],
        accionInmediata: json["Accion_Inmediata"],
        descripcion: json["Descripcion"],
        dialogo: json["Dialogo"],
        directorioArchivos: json["Directorio_Archivos"],
        fechaEntrada: json["Fecha_Entrada"],
        idAmbito: json["Id_Ambito"],
        idCentroTrabajo: json["Id_Centro_Trabajo"],
        idEstatus: json["Id_Estatus"],
        idRegistro: json["Id_Registro"],
        idSeccion: json["Id_Seccion"],
        idTipoComunicacion: json["Id_Tipo_Comunicacion"],
        idUsuarioDeclarante: json["Id_Usuario_Declarante"],
        idUsuarioProyectoAsignado: json["Id_Usuario_Proyecto_Asignado"],
        idUsuarioResponsableAreaSeccion:
            json["Id_Usuario_Responsable_Area_Seccion"],
        motivoRechazoValidacion: json["Motivo_Rechazo_Validacion"],
        nombreUsuarioDeclarante: json["Nombre_Usuario_Declarante"],
        nombreUsuarioProyectoAsignado: json["Nombre_Usuario_Proyecto_Asignado"],
        nombreUsuarioResponsableAreaSeccion:
            json["Nombre_Usuario_Responsable_Area_Seccion"],
        requierePlanAccion: json["Requiere_Plan_Accion"],
        validadoResponsableArea: json["Validado_Responsable_Area"],
        imageUrls: List<String>.from(json["imageUrls"].map((x) => x)),
        documentUrls: List<String>.from(json["documentUrls"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "num": num,
        "Accion_Inmediata": accionInmediata,
        "Descripcion": descripcion,
        "Dialogo": dialogo,
        "Directorio_Archivos": directorioArchivos,
        "Fecha_Entrada": fechaEntrada,
        "Id_Ambito": idAmbito,
        "Id_Centro_Trabajo": idCentroTrabajo,
        "Id_Estatus": idEstatus,
        "Id_Registro": idRegistro,
        "Id_Seccion": idSeccion,
        "Id_Tipo_Comunicacion": idTipoComunicacion,
        "Id_Usuario_Declarante": idUsuarioDeclarante,
        "Id_Usuario_Proyecto_Asignado": idUsuarioProyectoAsignado,
        "Id_Usuario_Responsable_Area_Seccion": idUsuarioResponsableAreaSeccion,
        "Motivo_Rechazo_Validacion": motivoRechazoValidacion,
        "Nombre_Usuario_Declarante": nombreUsuarioDeclarante,
        "Nombre_Usuario_Proyecto_Asignado": nombreUsuarioProyectoAsignado,
        "Nombre_Usuario_Responsable_Area_Seccion":
            nombreUsuarioResponsableAreaSeccion,
        "Requiere_Plan_Accion": requierePlanAccion,
        "Validado_Responsable_Area": validadoResponsableArea,
        "imageUrls": List<dynamic>.from(imageUrls.map((x) => x)),
        "documentUrls": List<dynamic>.from(documentUrls.map((x) => x)),
      };

  factory ComunicacionRiesgo.fromSnapshot(DataSnapshot snapshot) {
    var imageUrlsDynamic =
        snapshot.child("imageUrls").value as List<dynamic>? ?? [];
    var documentUrlsDynamic =
        snapshot.child("documentUrls").value as List<dynamic>? ?? [];

    return ComunicacionRiesgo(
      num: snapshot.child("num").value as int,
      accionInmediata: snapshot.child("Accion_Inmediata").value as String,
      descripcion: snapshot.child("Descripcion").value as String,
      dialogo: snapshot.child("Dialogo").value as String,
      directorioArchivos: snapshot.child("Directorio_Archivos").value as String,
      fechaEntrada: snapshot.child("Fecha_Entrada").value as String,
      idAmbito: snapshot.child("Id_Ambito").value as String,
      idCentroTrabajo: snapshot.child("Id_Centro_Trabajo").value as String,
      idEstatus: snapshot.child("Id_Estatus").value as String,
      idRegistro: snapshot.child("Id_Registro").value as int,
      idSeccion: snapshot.child("Id_Seccion").value as String,
      idTipoComunicacion:
          snapshot.child("Id_Tipo_Comunicacion").value as String,
      idUsuarioDeclarante:
          snapshot.child("Id_Usuario_Declarante").value as String,
      idUsuarioProyectoAsignado:
          snapshot.child("Id_Usuario_Proyecto_Asignado").value as String,
      idUsuarioResponsableAreaSeccion:
          snapshot.child("Id_Usuario_Responsable_Area_Seccion").value as String,
      motivoRechazoValidacion:
          snapshot.child("Motivo_Rechazo_Validacion").value as String,
      nombreUsuarioDeclarante:
          snapshot.child("Nombre_Usuario_Declarante").value as String,
      nombreUsuarioProyectoAsignado:
          snapshot.child("Nombre_Usuario_Proyecto_Asignado").value as String,
      nombreUsuarioResponsableAreaSeccion: snapshot
          .child("Nombre_Usuario_Responsable_Area_Seccion")
          .value as String,
      requierePlanAccion: snapshot.child("Requiere_Plan_Accion").value as bool,
      validadoResponsableArea:
          snapshot.child("Validado_Responsable_Area").value as String,
      imageUrls: List<String>.from(imageUrlsDynamic.map((x) => x.toString())),
      documentUrls:
          List<String>.from(documentUrlsDynamic.map((x) => x.toString())),
    );
  }
}

List<EstadosRiesgo> estadosRiesgoFromJson(String str) =>
    List<EstadosRiesgo>.from(
        json.decode(str).map((x) => EstadosRiesgo.fromJson(x)));

String estadosRiesgoToJson(List<EstadosRiesgo> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class EstadosRiesgo {
  final String textoEstadoRiesgo;
  final String idEstadoRiesgo;

  EstadosRiesgo({
    required this.textoEstadoRiesgo,
    required this.idEstadoRiesgo,
  });

  factory EstadosRiesgo.fromJson(Map<String, dynamic> json) => EstadosRiesgo(
        textoEstadoRiesgo: json["Texto_Estado_Riesgo"],
        idEstadoRiesgo: json["id_Estado_Riesgo"],
      );

  Map<String, dynamic> toJson() => {
        "Texto_Estado_Riesgo": textoEstadoRiesgo,
        "id_Estado_Riesgo": idEstadoRiesgo,
      };

  factory EstadosRiesgo.fromSnapshot(DataSnapshot snapshot) {
    return EstadosRiesgo(
      textoEstadoRiesgo: snapshot.child("Texto_Estado_Riesgo").value as String,
      idEstadoRiesgo: snapshot.child("id_Estado_Riesgo").value as String,
    );
  }
}

List<AmbitoRiesgo> ambitoRiesgoFromJson(String str) => List<AmbitoRiesgo>.from(
    json.decode(str).map((x) => AmbitoRiesgo.fromJson(x)));

String ambitoRiesgoToJson(List<AmbitoRiesgo> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AmbitoRiesgo {
  final String ambito;
  final String idAmbitoRiesgo;

  AmbitoRiesgo({
    required this.ambito,
    required this.idAmbitoRiesgo,
  });

  factory AmbitoRiesgo.fromJson(Map<String, dynamic> json) => AmbitoRiesgo(
        ambito: json["Ambito"],
        idAmbitoRiesgo: json["Id_ambito_riesgo"],
      );

  Map<String, dynamic> toJson() => {
        "Ambito": ambito,
        "Id_ambito_riesgo": idAmbitoRiesgo,
      };

  factory AmbitoRiesgo.fromSnapshot(DataSnapshot snapshot) {
    return AmbitoRiesgo(
      ambito: snapshot.child("Ambito").value as String,
      idAmbitoRiesgo: snapshot.child("Id_ambito_riesgo").value as String,
    );
  }
}
