// To parse this JSON data, do
//
//     final usuario = usuarioFromJson(jsonString);

import 'dart:convert';

List<Usuario> usuarioFromJson(String str) =>
    List<Usuario>.from(json.decode(str).map((x) => Usuario.fromJson(x)));

String usuarioToJson(List<Usuario> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Usuario {
  final bool usActivo;
  final bool usAvisosEmail;
  final String usCentroTrabajo;
  final int usCodProveedor;
  final int usCodigo;
  final String usFecAlta;
  final String usFecBaja;
  final String usId;
  final String usMail;
  final String usNombre;
  final String usNombreAgencia;
  final String usPin;
  final String usPwd;
  final int usPuestoTrabajo;
  final String usRecovery;

  Usuario({
    required this.usActivo,
    required this.usAvisosEmail,
    required this.usCentroTrabajo,
    required this.usCodProveedor,
    required this.usCodigo,
    required this.usFecAlta,
    required this.usFecBaja,
    required this.usId,
    required this.usMail,
    required this.usNombre,
    required this.usNombreAgencia,
    required this.usPin,
    required this.usPwd,
    required this.usPuestoTrabajo,
    required this.usRecovery,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
        usActivo: json["usActivo"],
        usAvisosEmail: json["usAvisosEmail"],
        usCentroTrabajo: json["usCentroTrabajo"],
        usCodProveedor: json["usCodProveedor"],
        usCodigo: json["usCodigo"],
        usFecAlta: json["usFecAlta"],
        usFecBaja: json["usFecBaja"],
        usId: json["usId"],
        usMail: json["usMail"],
        usNombre: json["usNombre"],
        usNombreAgencia: json["usNombreAgencia"],
        usPin: json["usPIN"],
        usPwd: json["usPWD"],
        usPuestoTrabajo: json["usPuestoTrabajo"],
        usRecovery: json["usRecovery"],
      );

  Map<String, dynamic> toJson() => {
        "usActivo": usActivo,
        "usAvisosEmail": usAvisosEmail,
        "usCentroTrabajo": usCentroTrabajo,
        "usCodProveedor": usCodProveedor,
        "usCodigo": usCodigo,
        "usFecAlta": usFecAlta,
        "usFecBaja": usFecBaja,
        "usId": usId,
        "usMail": usMail,
        "usNombre": usNombre,
        "usNombreAgencia": usNombreAgencia,
        "usPIN": usPin,
        "usPWD": usPwd,
        "usPuestoTrabajo": usPuestoTrabajo,
        "usRecovery": usRecovery,
      };
}
