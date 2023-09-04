import 'dart:convert';

List<DepartmentData> departmentDataFromJson(String str) =>
    List<DepartmentData>.from(
        json.decode(str).map((x) => DepartmentData.fromJson(x)));

String departmentDataToJson(List<DepartmentData> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DepartmentData {
  String comCodigo;
  String ambCodigo;
  String ambAmbiente;
  String ambCentroCosto;

  DepartmentData({
    required this.comCodigo,
    required this.ambCodigo,
    required this.ambAmbiente,
    required this.ambCentroCosto,
  });

  factory DepartmentData.fromJson(Map<String, dynamic> json) => DepartmentData(
        comCodigo: json["com_codigo"].toString(),
        ambCodigo: json["amb_codigo"].toString(),
        ambAmbiente: json["amb_ambiente"],
        ambCentroCosto: json["amb_centro_costo"],
      );

  Map<String, dynamic> toJson() => {
        "com_codigo": comCodigo,
        "amb_codigo": ambCodigo,
        "amb_ambiente": ambAmbiente,
        "amb_centro_costo": ambCentroCosto,
      };
}
