// To parse this JSON data, do
//
//     final perfilxUsuario = perfilxUsuarioFromJson(jsonString);

import 'dart:convert';

List<PerfilxUsuario> perfilxUsuarioFromJson(String str) => List<PerfilxUsuario>.from(json.decode(str).map((x) => PerfilxUsuario.fromJson(x)));

String perfilxUsuarioToJson(List<PerfilxUsuario> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PerfilxUsuario {
    final bool? puCargaManual;
    final int? puPerfil;
    final int? puUsuario;

    PerfilxUsuario({
        this.puCargaManual,
        this.puPerfil,
        this.puUsuario,
    });

    factory PerfilxUsuario.fromJson(Map<String, dynamic> json) => PerfilxUsuario(
        puCargaManual: json["puCargaManual"],
        puPerfil: json["puPerfil"],
        puUsuario: json["puUsuario"],
    );

    Map<String, dynamic> toJson() => {
        "puCargaManual": puCargaManual,
        "puPerfil": puPerfil,
        "puUsuario": puUsuario,
    };
}
