import 'package:app_farma_scan_v2/index.dart';
import 'package:app_farma_scan_v2/models/departmentData_model.dart';
import 'package:app_farma_scan_v2/models/documentData_model.dart';
import 'package:app_farma_scan_v2/services/api_service.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'package:flutter/material.dart';
import 'manual_docs_page_model.dart';
export 'manual_docs_page_model.dart';

class ManualDocsPageWidget extends StatefulWidget {
  const ManualDocsPageWidget({Key? key}) : super(key: key);

  @override
  _ManualDocsPageWidgetState createState() => _ManualDocsPageWidgetState();
}

class _ManualDocsPageWidgetState extends State<ManualDocsPageWidget> {
  late ManualDocsPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final apiService = ApiService();
  final listDepartmentsData = <DepartmentData>[];
  late DepartmentData departmentSelected = DepartmentData(
      ambAmbiente: '', ambCentroCosto: '', ambCodigo: '', comCodigo: '');

  final listDocumentsData = <DocumentData>[];
  late DocumentData documentSelected = DocumentData(
      ambCodigo: 0,
      catCodigo: 0,
      catDescripcion: '',
      catMovil: '',
      catNombre: '',
      catNombreCorto: '',
      catObligatorio: '',
      catOcr: '',
      comCodigo: 0);

  bool _isLoadingDepartment = false;
  bool _isLoadingDocument = true;

  @override
  void initState() {
    super.initState();
    _getDepartamentos();
    _model = createModel(context, () => ManualDocsPageModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  void _getDepartamentos() async {
    setState(() {
      _isLoadingDepartment = true;
    });
    final response = await apiService.getDepartamentos();
    setState(() {
      listDepartmentsData.clear();
      listDepartmentsData.addAll(response);
      _isLoadingDepartment = false;
    });
  }

  void _getDocumentByDepartment(String departmentCode) async {
    setState(() {
      _isLoadingDocument = true;
    });
    final response = await apiService.getDocumentsByDepartment(departmentCode);
    setState(() {
      listDocumentsData.clear();
      listDocumentsData.addAll(response);
      _isLoadingDocument = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingDepartment == true) {
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
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(_model.unfocusNode),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: Colors.indigo,
          automaticallyImplyLeading: true,
          title: Text(
            'Documentos Manuales',
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Seleccione un departamento:',
                    textAlign: TextAlign.start,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Readex Pro',
                          fontSize: 22.0,
                        ),
                  ),
                  Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 15.0, 0.0, 0.0),
                    child: FlutterFlowDropDown<String>(
                      controller: _model.dropDownValueController1 ??=
                          FormFieldController<String>(null),
                      options: listDepartmentsData
                          .map((e) => e.ambAmbiente)
                          .toList(),
                      onChanged: (val) {
                        documentSelected = DocumentData(
                            ambCodigo: 0,
                            catCodigo: 0,
                            catDescripcion: '',
                            catMovil: '',
                            catNombre: '',
                            catNombreCorto: '',
                            catObligatorio: '',
                            catOcr: '',
                            comCodigo: 0);
                        departmentSelected = listDepartmentsData.firstWhere(
                            (element) => element.ambAmbiente == val);
                        setState(() {
                          _model.dropDownValue1 = departmentSelected;
                        });
                        _getDocumentByDepartment(departmentSelected.ambCodigo);
                      },
                      width: 454.0,
                      height: 50.0,
                      textStyle: FlutterFlowTheme.of(context).bodyMedium,
                      hintText: 'Despliegue para seleccionar...',
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: FlutterFlowTheme.of(context).secondaryText,
                        size: 24.0,
                      ),
                      fillColor:
                          FlutterFlowTheme.of(context).secondaryBackground,
                      elevation: 2.0,
                      borderColor: FlutterFlowTheme.of(context).alternate,
                      borderWidth: 2.0,
                      borderRadius: 8.0,
                      margin:
                          EdgeInsetsDirectional.fromSTEB(16.0, 4.0, 16.0, 4.0),
                      hidesUnderline: true,
                      isSearchable: false,
                    ),
                  ),
                  Visibility(
                    visible: _isLoadingDocument,
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 35.0, 0.0, 0.0),
                          child: Visibility(
                            visible: _model.dropDownValue1 == null,
                            child: Text(
                              'Seleccione un departamento antes de continuar',
                              textAlign: TextAlign.start,
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: 'Readex Pro',
                                    fontSize: 12.0,
                                    color: Colors.orange,
                                  ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        LoadingAnimationWidget.stretchedDots(
                          color: Colors.indigoAccent,
                          size: 50,
                        ),
                      ],
                    ),
                    replacement: Column(
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 35.0, 0.0, 0.0),
                          child: Text(
                            'Seleccione un documento:',
                            textAlign: TextAlign.start,
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'Readex Pro',
                                  fontSize: 22.0,
                                ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 15.0, 0.0, 0.0),
                          child: FlutterFlowDropDown<String>(
                            controller: _model.dropDownValueController2 ??=
                                FormFieldController<String>(null),
                            options: listDocumentsData
                                .map((e) => e.catNombre)
                                .toList(),
                            onChanged: (val) {
                              documentSelected = listDocumentsData.firstWhere(
                                  (element) => element.catNombre == val);
                              setState(() =>
                                  _model.dropDownValue2 = documentSelected);
                            },
                            width: 432.0,
                            height: 50.0,
                            textStyle: FlutterFlowTheme.of(context).bodyMedium,
                            hintText: 'Despliegue para seleccionar...',
                            icon: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: FlutterFlowTheme.of(context).secondaryText,
                              size: 24.0,
                            ),
                            fillColor: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            elevation: 2.0,
                            borderColor: FlutterFlowTheme.of(context).alternate,
                            borderWidth: 2.0,
                            borderRadius: 8.0,
                            margin: EdgeInsetsDirectional.fromSTEB(
                                16.0, 4.0, 16.0, 4.0),
                            hidesUnderline: true,
                            isSearchable: false,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 25.0, 0.0, 0.0),
                    child: documentSelected.catCodigo == 0
                        ? const SizedBox() // No muestra el botón si documentSelected.catCodigo == 0
                        : FFButtonWidget(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DocumentPageWidget(
                                    catCodigo:
                                        documentSelected.catCodigo.toString(),
                                  ),
                                ),
                              );
                            },
                            text: 'Seleccionar',
                            options: FFButtonOptions(
                              height: 40.0,
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  24.0, 0.0, 24.0, 0.0),
                              iconPadding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 0.0),
                              color: Colors.indigo,
                              textStyle: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
                                    fontFamily: 'Readex Pro',
                                    color: Colors.white,
                                  ),
                              elevation: 3.0,
                              borderSide: BorderSide(
                                color: Colors.transparent,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
