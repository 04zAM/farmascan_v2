import 'package:app_farma_scan_v2/index.dart';
import 'package:app_farma_scan_v2/models/documentFieldsData_model.dart';
import 'package:app_farma_scan_v2/services/api_service.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:quickalert/quickalert.dart';

import '../documents_page/documents_page_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'barcode_docs_page_model.dart';
export 'barcode_docs_page_model.dart';

class BarcodeDocsPageWidget extends StatefulWidget {
  const BarcodeDocsPageWidget({Key? key}) : super(key: key);

  @override
  _BarcodeDocsPageWidgetState createState() => _BarcodeDocsPageWidgetState();
}

class _BarcodeDocsPageWidgetState extends State<BarcodeDocsPageWidget> {
  late BarcodeDocsPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final apiService = ApiService();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BarcodeDocsPageModel());

    _model.textController ??= TextEditingController();
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  Future<void> _scanBarcode() async {
    String barcodeScanResult = await FlutterBarcodeScanner.scanBarcode(
      "#93EC22",
      "Regresar",
      false,
      ScanMode.BARCODE,
    );

    if (barcodeScanResult != "-1") {
      _buscarDocumento(barcodeScanResult);
    }
  }

  Future<void> _buscarDocumento(String nroComprobante) async {
    nroComprobante = nroComprobante.toUpperCase();
    try {
      setState(() {
        _isLoading = true;
      });
      final response = await apiService.getDocumentType(nroComprobante);
      if (response['respuesta'].toString().toLowerCase() == "ok") {
        List<Map<String, dynamic>> documents = [];
        List<String> fields = response['mensaje'].split(';');

        for (String field in fields) {
          List<String> parts = field.split('|');
          if (parts.length == 2) {
            int? docId = int.tryParse(parts[0]);
            if (docId != null) {
              final document = await apiService.getDocument(docId.toString());
              final departamento = document.departamentoCodigo.toString();
              final catalogodocuments =
                  await apiService.getDocumentsByDepartment(departamento);
              final sql = catalogodocuments
                  .firstWhere((element) => element.catCodigo == docId)
                  .catOcr;
              documents.add({
                'cat_codigo': docId,
                'nro_factura': nroComprobante,
                'cat_sql': sql
              });
            }
          }
        }

        List documentsInfo = [];
        List<DocumentFieldsData> documentsStuctures = [];

        for (Map<String, dynamic> document in documents) {
          final getDocumentInfo = await apiService.getBarcodeDocument(
              document['nro_factura'], document['cat_sql']);
          documentsInfo.add(getDocumentInfo);

          final getDocumentTemplate =
              await apiService.getDocument(document['cat_codigo'].toString());

          documentsStuctures.add(getDocumentTemplate);
        }

        //Crear un diccionario de documentsInfo
        Map<String, dynamic> searchMapDI = {};
        documentsInfo.forEach((map) {
          map.forEach((key, value) {
            searchMapDI[key] = value;
          });
        });

        //Actualizar datos en propiedades del modelo
        searchMapDI.forEach((key, value) {
          for (DocumentFieldsData document in documentsStuctures) {
            for (Propiedade propiedad in document.propiedades) {
              if (propiedad.prdCodigo == int.tryParse(key)) {
                propiedad.datos = value;
              }
            }
          }
        });
        setState(() {
          _isLoading = false;
        });

        String mensaje = response['mensaje'];

        // Dividir el mensaje en líneas
        List<String> lineas = mensaje.split(';');

        // Crear un nuevo mensaje con números de línea
        String nuevoMensaje = '';
        for (int i = 0; i < lineas.length; i++) {
          List<String> partes = lineas[i].split('|');
          if (partes.length > 1) {
            nuevoMensaje += '${i + 1}. ${partes[1]}\n';
          }
        }

        QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            title: 'Documentos Encontrados',
            widget: Text(capitalizeFirstLetter(nuevoMensaje),
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Readex Pro',
                      fontSize: 16.0,
                    )),
            confirmBtnText: 'Aceptar',
            confirmBtnColor: Colors.indigo,
            onConfirmBtnTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DocumentsPageWidget(
                            documentsStructureList: documentsStuctures,
                          )),
                ));
      } else {
        setState(() {
          _isLoading = false;
        });
        QuickAlert.show(
          context: context,
          type: QuickAlertType.info,
          text: response['mensaje'],
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        text: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) {
      return text;
    }

    return text.toLowerCase().split(' ').map((word) {
      if (word.isNotEmpty) {
        return '${word[0].toUpperCase()}${word.substring(1)}';
      }
      return '';
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LoadingAnimationWidget.stretchedDots(
                color: Colors.indigo,
                size: 75,
              ),
              SizedBox(height: 16), // Espacio entre la animación y el mensaje
              Text("Cargando",
                  style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Readex Pro',
                      color: Colors.indigo,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none)),
            ],
          ),
        ),
      );
    }
    return WillPopScope(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(_model.unfocusNode),
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            appBar: AppBar(
              backgroundColor: Color(0xFF6126E0),
              automaticallyImplyLeading: true,
              title: Text(
                'Documentos Automáticos',
                style: FlutterFlowTheme.of(context).headlineMedium.override(
                      fontFamily: 'Inter',
                      color: Colors.white,
                      fontSize: 18.0,
                    ),
              ),
              actions: [],
              centerTitle: false,
              elevation: 2.0,
            ),
            body: SafeArea(
              top: true,
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(25.0, 25.0, 25.0, 25.0),
                child: Container(
                  width: MediaQuery.sizeOf(context).width * 1.0,
                  height: MediaQuery.sizeOf(context).height * 1.0,
                  decoration: BoxDecoration(),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ingrese el Nro. de Documento:',
                        textAlign: TextAlign.start,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Readex Pro',
                              fontSize: 18.0,
                            ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0, 8.0, 8.0, 8.0),
                              child: Container(
                                width: double.infinity,
                                height: 50.0,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText,
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      8.0, 0.0, 8.0, 0.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            4.0, 0.0, 4.0, 0.0),
                                        child: Icon(
                                          Icons.search_rounded,
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                          size: 24.0,
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  4.0, 0.0, 0.0, 0.0),
                                          child: TextFormField(
                                            controller: _model.textController,
                                            onChanged: (_) =>
                                                EasyDebounce.debounce(
                                              '_model.textController',
                                              Duration(milliseconds: 2000),
                                              () => setState(() {}),
                                            ),
                                            obscureText: false,
                                            decoration: InputDecoration(
                                              enabledBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Color(0x00000000),
                                                  width: 1.0,
                                                ),
                                                borderRadius:
                                                    const BorderRadius.only(
                                                  topLeft: Radius.circular(4.0),
                                                  topRight:
                                                      Radius.circular(4.0),
                                                ),
                                              ),
                                              focusedBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Color(0x00000000),
                                                  width: 1.0,
                                                ),
                                                borderRadius:
                                                    const BorderRadius.only(
                                                  topLeft: Radius.circular(4.0),
                                                  topRight:
                                                      Radius.circular(4.0),
                                                ),
                                              ),
                                              errorBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Color(0x00000000),
                                                  width: 1.0,
                                                ),
                                                borderRadius:
                                                    const BorderRadius.only(
                                                  topLeft: Radius.circular(4.0),
                                                  topRight:
                                                      Radius.circular(4.0),
                                                ),
                                              ),
                                              focusedErrorBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Color(0x00000000),
                                                  width: 1.0,
                                                ),
                                                borderRadius:
                                                    const BorderRadius.only(
                                                  topLeft: Radius.circular(4.0),
                                                  topRight:
                                                      Radius.circular(4.0),
                                                ),
                                              ),
                                            ),
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium,
                                            validator: _model
                                                .textControllerValidator
                                                .asValidator(context),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          FFButtonWidget(
                            onPressed: () {
                              _buscarDocumento(_model.textController.text);
                            },
                            text: 'Buscar',
                            options: FFButtonOptions(
                              width: 80.0,
                              height: 36.0,
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 0.0),
                              iconPadding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 0.0),
                              color: Color(0xFF4B39EF),
                              textStyle: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
                                    fontFamily: 'Lexend Deca',
                                    color: Colors.white,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.normal,
                                  ),
                              elevation: 2.0,
                              borderSide: BorderSide(
                                color: Colors.transparent,
                                width: 1.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 25.0, 0.0, 0.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.crisis_alert_sharp,
                              color: Color(0xFF7C8791),
                              size: 90.0,
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 24.0, 0.0, 0.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Información importante',
                                    textAlign: TextAlign.center,
                                    style: FlutterFlowTheme.of(context)
                                        .headlineSmall
                                        .override(
                                          fontFamily: 'Outfit',
                                          color: Color(0xFF090F13),
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 15.0, 0.0, 0.0),
                                  child: Text(
                                    '- Para convenios  y cupones por favor ingrese las iniciales 002F y luego el número de documento sin guiones.',
                                    textAlign: TextAlign.justify,
                                    style:
                                        FlutterFlowTheme.of(context).bodyMedium,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 15.0, 0.0, 0.0),
                                  child: Text(
                                    'Ejemplo: OO2F893001000087569 ',
                                    textAlign: TextAlign.justify,
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Readex Pro',
                                          color: FlutterFlowTheme.of(context)
                                              .tertiary,
                                        ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 15.0, 0.0, 0.0),
                                  child: Text(
                                    '- Para salidas de caja por favor ingresar al inicio del código de solicitud las letras SC. ',
                                    textAlign: TextAlign.justify,
                                    style:
                                        FlutterFlowTheme.of(context).bodyMedium,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 15.0, 0.0, 25.0),
                                  child: Text(
                                    'Ejemplo: SC00001',
                                    textAlign: TextAlign.justify,
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Readex Pro',
                                          color: FlutterFlowTheme.of(context)
                                              .tertiary,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 12.0, 0.0, 0.0),
                              child: FFButtonWidget(
                                onPressed: () {
                                  _scanBarcode();
                                },
                                text: 'Escanear',
                                options: FFButtonOptions(
                                  width: 170.0,
                                  height: 50.0,
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 0.0),
                                  iconPadding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 0.0),
                                  color: Color(0xFF4B39EF),
                                  textStyle: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        fontFamily: 'Lexend Deca',
                                        color: Colors.white,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.normal,
                                      ),
                                  elevation: 2.0,
                                  borderSide: BorderSide(
                                    color: Colors.transparent,
                                    width: 1.0,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        onWillPop: () async {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return DashboardPageWidget();
          }));
          return true;
        });
  }
}
