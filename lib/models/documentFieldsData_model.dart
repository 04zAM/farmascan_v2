import 'dart:convert';

DocumentFieldsData documentFieldsDataFromJson(String str) =>
    DocumentFieldsData.fromJson(json.decode(str));

String documentFieldsDataToJson(DocumentFieldsData data) =>
    json.encode(data.toJson());

class DocumentFieldsData {
  int empresaCodigo;
  int departamentoCodigo;
  String nombre;
  int codigo;
  int caja;
  dynamic centroCosto;
  String devolverPropietario;
  String origen;
  String usuarioRegistra;
  String ipRegistra;
  Propietario propietario;
  List<Propiedade> propiedades;
  List<dynamic> imagenes;
  List<FarmascanMl> farmascanMl;

  DocumentFieldsData({
    required this.empresaCodigo,
    required this.departamentoCodigo,
    required this.nombre,
    required this.codigo,
    required this.caja,
    required this.centroCosto,
    required this.devolverPropietario,
    required this.origen,
    required this.usuarioRegistra,
    required this.ipRegistra,
    required this.propietario,
    required this.propiedades,
    required this.imagenes,
    required this.farmascanMl,
  });

  factory DocumentFieldsData.fromJson(Map<String, dynamic> json) =>
      DocumentFieldsData(
        empresaCodigo: json["empresaCodigo"] ?? 0,
        departamentoCodigo: json["departamentoCodigo"] ?? 0,
        nombre: json["nombre"] ?? '',
        codigo: json["codigo"] ?? 0,
        caja: json["caja"] ?? 0,
        centroCosto: json["centroCosto"],
        devolverPropietario: json["devolverPropietario"] ?? '',
        origen: json["origen"] ?? '',
        usuarioRegistra: json["usuarioRegistra"] ?? '',
        ipRegistra: json["ipRegistra"] ?? '',
        propietario: Propietario.fromJson(json["propietario"] ?? {}),
        propiedades: (json["propiedades"] as List<dynamic>?)
                ?.map((x) => Propiedade.fromJson(x))
                .toList() ??
            [],
        imagenes: json["imagenes"] ?? [],
        farmascanMl: (json["farmascanML"] as List<dynamic>?)
                ?.map((x) => FarmascanMl.fromJson(x))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        "empresaCodigo": empresaCodigo,
        "departamentoCodigo": departamentoCodigo,
        "nombre": nombre,
        "codigo": codigo,
        "caja": caja,
        "centroCosto": centroCosto,
        "devolverPropietario": devolverPropietario,
        "origen": origen,
        "usuarioRegistra": usuarioRegistra,
        "ipRegistra": ipRegistra,
        "propietario": propietario.toJson(),
        "propiedades": propiedades.map((x) => x.toJson()).toList(),
        "imagenes": imagenes,
        "farmascanML": farmascanMl.map((x) => x.toJson()).toList(),
      };
}

class FarmascanMl {
  int fmlOrden;
  String fmlMensaje;
  String fmlValidarModeloPrediccion;
  String fmlDocumentoPredecir;
  int fmlDocumentoCodigo;
  String fmlValidarReglasOcr;
  String fmlReglasOcr;
  int fmlNumeroValidoReglasOcr;

  FarmascanMl({
    required this.fmlOrden,
    required this.fmlMensaje,
    required this.fmlValidarModeloPrediccion,
    required this.fmlDocumentoPredecir,
    required this.fmlDocumentoCodigo,
    required this.fmlValidarReglasOcr,
    required this.fmlReglasOcr,
    required this.fmlNumeroValidoReglasOcr,
  });

  factory FarmascanMl.fromJson(Map<String, dynamic> json) => FarmascanMl(
        fmlOrden: json["fml_orden"] ?? 0,
        fmlMensaje: json["fml_mensaje"] ?? '',
        fmlValidarModeloPrediccion: json["fml_validar_modelo_prediccion"] ?? '',
        fmlDocumentoPredecir: json["fml_documento_predecir"] ?? '',
        fmlDocumentoCodigo: json["fml_documento_codigo"] ?? 0,
        fmlValidarReglasOcr: json["fml_validar_reglas_ocr"] ?? '',
        fmlReglasOcr: json["fml_reglas_ocr"] ?? '',
        fmlNumeroValidoReglasOcr: json["fml_numero_valido_reglas_ocr"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "fml_orden": fmlOrden,
        "fml_mensaje": fmlMensaje,
        "fml_validar_modelo_prediccion": fmlValidarModeloPrediccion,
        "fml_documento_predecir": fmlDocumentoPredecir,
        "fml_documento_codigo": fmlDocumentoCodigo,
        "fml_validar_reglas_ocr": fmlValidarReglasOcr,
        "fml_reglas_ocr": fmlReglasOcr,
        "fml_numero_valido_reglas_ocr": fmlNumeroValidoReglasOcr,
      };
}

class Propiedade {
  int catCodigo;
  int prdCodigo;
  String prdNombre;
  int prdPropiedadRaiz;
  int tpdTipoDato;
  String tpdNombre;
  String tpdDescripcion;
  dynamic datos;

  Propiedade({
    required this.catCodigo,
    required this.prdCodigo,
    required this.prdNombre,
    required this.prdPropiedadRaiz,
    required this.tpdTipoDato,
    required this.tpdNombre,
    required this.tpdDescripcion,
    required this.datos,
  });

  factory Propiedade.fromJson(Map<String, dynamic> json) => Propiedade(
        catCodigo: json["cat_codigo"] ?? 0,
        prdCodigo: json["prd_codigo"] ?? 0,
        prdNombre: json["prd_nombre"] ?? '',
        prdPropiedadRaiz: json["prd_propiedad_raiz"] ?? 0,
        tpdTipoDato: json["tpd_tipo_dato"] ?? 0,
        tpdNombre: json["tpd_nombre"] ?? '',
        tpdDescripcion: json["tpd_descripcion"] ?? '',
        datos: json["datos"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "cat_codigo": catCodigo,
        "prd_codigo": prdCodigo,
        "prd_nombre": prdNombre,
        "prd_propiedad_raiz": prdPropiedadRaiz,
        "tpd_tipo_dato": tpdTipoDato,
        "tpd_nombre": tpdNombre,
        "tpd_descripcion": tpdDescripcion,
        "datos": datos,
      };
}

class Propietario {
  dynamic tipoPropietario;
  dynamic ciPasRuc;
  dynamic nombresRazonSocial;
  dynamic direccion;
  dynamic telefono;
  dynamic telefono2;

  Propietario({
    required this.tipoPropietario,
    required this.ciPasRuc,
    required this.nombresRazonSocial,
    required this.direccion,
    required this.telefono,
    required this.telefono2,
  });

  factory Propietario.fromJson(Map<String, dynamic> json) => Propietario(
        tipoPropietario: json["tipoPropietario"] ?? '',
        ciPasRuc: json["ciPasRuc"] ?? '',
        nombresRazonSocial: json["nombresRazonSocial"] ?? '',
        direccion: json["direccion"] ?? '',
        telefono: json["telefono"] ?? '',
        telefono2: json["telefono2"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "tipoPropietario": tipoPropietario,
        "ciPasRuc": ciPasRuc,
        "nombresRazonSocial": nombresRazonSocial,
        "direccion": direccion,
        "telefono": telefono,
        "telefono2": telefono2,
      };
}
