import 'dart:convert';

List<DocumentData> documentDataFromJson(String str) => List<DocumentData>.from(
    json.decode(str).map((x) => DocumentData.fromJson(x)));

String documentDataToJson(List<DocumentData> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DocumentData {
  int catCodigo;
  String catNombre;
  String catDescripcion;
  String catNombreCorto;
  String catObligatorio;
  String catMovil;
  int comCodigo;
  int ambCodigo;
  String catOcr;

  DocumentData({
    required this.catCodigo,
    required this.catNombre,
    required this.catDescripcion,
    required this.catNombreCorto,
    required this.catObligatorio,
    required this.catMovil,
    required this.comCodigo,
    required this.ambCodigo,
    required this.catOcr,
  });

  factory DocumentData.fromJson(Map<String, dynamic> json) => DocumentData(
        catCodigo: json["cat_codigo"] ?? 0,
        catNombre: json["cat_nombre"] ?? '',
        catDescripcion: json["cat_descripcion"] ?? '',
        catNombreCorto: json["cat_nombre_corto"] ?? '',
        catObligatorio: json["cat_obligatorio"] ?? '',
        catMovil: json["cat_movil"] ?? '',
        comCodigo: json["com_codigo"] ?? 0,
        ambCodigo: json["amb_codigo"] ?? 0,
        catOcr: json["cat_ocr"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "cat_codigo": catCodigo,
        "cat_nombre": catNombre,
        "cat_descripcion": catDescripcion,
        "cat_nombre_corto": catNombreCorto,
        "cat_obligatorio": catObligatorio,
        "cat_movil": catMovil,
        "com_codigo": comCodigo,
        "amb_codigo": ambCodigo,
        "cat_ocr": catOcr,
      };
}
