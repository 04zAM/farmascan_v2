import 'dart:convert';

UserData userDataFromJson(String str) => UserData.fromJson(json.decode(str));

String userDataToJson(UserData data) => json.encode(data.toJson());

class UserData {
  String respuesta;
  Mensaje mensaje;

  UserData({
    required this.respuesta,
    required this.mensaje,
  });

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
        respuesta: json["respuesta"],
        mensaje: Mensaje.fromJson(json["mensaje"]),
      );

  Map<String, dynamic> toJson() => {
        "respuesta": respuesta,
        "mensaje": mensaje.toJson(),
      };
}

class Mensaje {
  String nombre;
  String cedula;
  String farmacia;
  String idbodega;
  String sucursal;
  String compania;
  String centroCosto;
  String nombreCorto;
  List<Atribucione> atribuciones;

  Mensaje({
    required this.nombre,
    required this.cedula,
    required this.farmacia,
    required this.idbodega,
    required this.sucursal,
    required this.compania,
    required this.centroCosto,
    required this.nombreCorto,
    required this.atribuciones,
  });

  factory Mensaje.fromJson(Map<String, dynamic> json) => Mensaje(
        nombre: json["nombre"],
        cedula: json["cedula"],
        farmacia: json["farmacia"],
        idbodega: json["idbodega"],
        sucursal: json["sucursal"],
        compania: json["compania"],
        centroCosto: json["centro_costo"],
        nombreCorto: json["NombreCorto"],
        atribuciones: List<Atribucione>.from(
            json["atribuciones"].map((x) => Atribucione.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "nombre": nombre,
        "cedula": cedula,
        "farmacia": farmacia,
        "idbodega": idbodega,
        "sucursal": sucursal,
        "compania": compania,
        "centro_costo": centroCosto,
        "NombreCorto": nombreCorto,
        "atribuciones": List<dynamic>.from(atribuciones.map((x) => x.toJson())),
      };
}

class Atribucione {
  String aplicacion;
  String modulo;
  String transaccion;

  Atribucione({
    required this.aplicacion,
    required this.modulo,
    required this.transaccion,
  });

  factory Atribucione.fromJson(Map<String, dynamic> json) => Atribucione(
        aplicacion: json["Aplicacion"],
        modulo: json["Modulo"],
        transaccion: json["Transaccion"],
      );

  Map<String, dynamic> toJson() => {
        "Aplicacion": aplicacion,
        "Modulo": modulo,
        "Transaccion": transaccion,
      };
}
