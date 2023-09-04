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
  Aplicacion aplicacion;
  Modulo modulo;
  String transaccion;

  Atribucione({
    required this.aplicacion,
    required this.modulo,
    required this.transaccion,
  });

  factory Atribucione.fromJson(Map<String, dynamic> json) => Atribucione(
        aplicacion: aplicacionValues.map[json["Aplicacion"]]!,
        modulo: moduloValues.map[json["Modulo"]]!,
        transaccion: json["Transaccion"],
      );

  Map<String, dynamic> toJson() => {
        "Aplicacion": aplicacionValues.reverse[aplicacion],
        "Modulo": moduloValues.reverse[modulo],
        "Transaccion": transaccion,
      };
}

enum Aplicacion { PV }

final aplicacionValues = EnumValues({"PV": Aplicacion.PV});

enum Modulo {
  MOD_DIGITALIZACION,
  MOD_PLANIFICACION,
  MOD_RECEPCION,
  M_BI_FARMACIAS,
  M_CAJA,
  M_FACTURACION,
  M_INVENTARIO,
  M_REPORTES
}

final moduloValues = EnumValues({
  "mod_digitalizacion": Modulo.MOD_DIGITALIZACION,
  "mod_planificacion": Modulo.MOD_PLANIFICACION,
  "mod_recepcion": Modulo.MOD_RECEPCION,
  "m_BiFarmacias": Modulo.M_BI_FARMACIAS,
  "m_caja": Modulo.M_CAJA,
  "m_facturacion": Modulo.M_FACTURACION,
  "m_inventario": Modulo.M_INVENTARIO,
  "m_reportes": Modulo.M_REPORTES
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
