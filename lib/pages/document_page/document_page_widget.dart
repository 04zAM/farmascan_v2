import 'package:app_farma_scan_v2/flutter_flow/flutter_flow_widgets.dart';
import 'package:app_farma_scan_v2/models/documentFieldsData_model.dart';
import 'package:app_farma_scan_v2/pages/gallery_page/gallery_page_widget.dart';
import 'package:app_farma_scan_v2/services/api_service.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:quickalert/quickalert.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'document_page_model.dart';
export 'document_page_model.dart';

class DocumentPageWidget extends StatefulWidget {
  final String catCodigo;

  const DocumentPageWidget({Key? key, required this.catCodigo})
      : super(key: key);

  @override
  _DocumentPageWidgetState createState() => _DocumentPageWidgetState();
}

class _DocumentPageWidgetState extends State<DocumentPageWidget> {
  late DocumentPageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  final ApiService apiService = ApiService();
  late String catCodigo;
  bool _isLoadingFields = false;
  bool _isButtonEnabled = false;
  late DocumentFieldsData documentFields;
  late List<Widget> dynamicFields = [];
  List<TextEditingController> textControllers = [];
  List<FocusNode> textsFocus = [];
  int currentTextFieldIndex = 0;

  @override
  void initState() {
    super.initState();
    catCodigo = widget.catCodigo;
    _model = createModel(context, () => DocumentPageModel());
    _getDocument();
  }

  @override
  void dispose() {
    _model.dispose();
    for (var controller in textControllers) {
      controller.dispose();
    }
    for (var focus in textsFocus) {
      focus.dispose();
    }
    super.dispose();
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

  void _getDocument() async {
    setState(() {
      _isLoadingFields = true;
    });
    final response = await apiService.getDocument(catCodigo);
    setState(() {
      documentFields = response;
      _createDynamicFields();
      _isLoadingFields = false;
    });
  }

  void _checkFields() {
    bool emptyField = false;
    for (var controller in textControllers) {
      if (controller.text.isEmpty) {
        emptyField = true;
        break;
      }
    }
    setState(() {
      _isButtonEnabled =
          !emptyField; // Si no encontró campos vacíos, habilita el botón
    });
  }

  void _createDynamicFields() {
    documentFields.propiedades.asMap().forEach((index, field) {
      final controller = TextEditingController();
      final textFocus = FocusNode();

      if (field.tpdTipoDato == 4) {
        textControllers.add(controller);
        textsFocus.add(textFocus);
        final dateField = Padding(
          padding: EdgeInsets.only(bottom: 15.0, top: 15.0),
          child: TextFormField(
            controller: controller,
            focusNode: textFocus,
            onEditingComplete: _handleEditingComplete,
            obscureText: false,
            readOnly: true,
            decoration: InputDecoration(
              labelText: capitalizeFirstLetter(field.prdNombre) + ':',
              labelStyle: FlutterFlowTheme.of(context).bodyLarge,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: FlutterFlowTheme.of(context).alternate,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(12.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: FlutterFlowTheme.of(context).primary,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(12.0),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: FlutterFlowTheme.of(context).primary,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(12.0),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: FlutterFlowTheme.of(context).primary,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            style: FlutterFlowTheme.of(context).bodyMedium,
            onTap: () async {
              currentTextFieldIndex = textsFocus.indexOf(textFocus);
              DateTime? selectedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );
              if (selectedDate != null) {
                controller.text =
                    selectedDate.toLocal().toString().split(' ')[0];
                _checkFields();
              }
            },
          ),
        );
        dynamicFields.add(dateField);
      } else {
        textControllers.add(controller);
        textsFocus.add(textFocus);
        final textField = Padding(
          padding: EdgeInsets.only(bottom: 15.0, top: 15.0),
          child: TextFormField(
            controller: controller,
            focusNode: textFocus,
            onEditingComplete: _handleEditingComplete,
            onTap: () {
              currentTextFieldIndex = textsFocus.indexOf(textFocus);
            },
            obscureText: false,
            onChanged: (newValue) {
              setState(() {
                _checkFields();
              });
            },
            decoration: InputDecoration(
              labelText: capitalizeFirstLetter(field.prdNombre) + ':',
              labelStyle: FlutterFlowTheme.of(context).bodyLarge,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: FlutterFlowTheme.of(context).alternate,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(12.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: FlutterFlowTheme.of(context).primary,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(12.0),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: FlutterFlowTheme.of(context).primary,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(12.0),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: FlutterFlowTheme.of(context).primary,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            style: FlutterFlowTheme.of(context).bodyMedium,
          ),
        );
        dynamicFields.add(textField);
      }
    });
  }

  void _handleEditingComplete() {
    _moveToNextTextField(1); // Avanzar al siguiente campo de texto
  }

  void _moveToNextTextField(int step) {
    final newIndex = currentTextFieldIndex + step;

    if (newIndex >= 0 && newIndex < textsFocus.length) {
      currentTextFieldIndex = newIndex;
      FocusScope.of(context).requestFocus(textsFocus[currentTextFieldIndex]);
    } else {
      FocusScope.of(context).unfocus();
    }
  }

  void _setDocumentFields() {
    documentFields.propiedades.forEach((field) {
      field.datos =
          textControllers[documentFields.propiedades.indexOf(field)].text;
    });
  }

  void _getDocumentsOrder() async {
    if (documentFields.farmascanMl.isEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GalleryPageWidget(
            document: documentFields,
          ),
        ),
      );
    } else {
      String orderMessage =
          'Estimado usuario recuerde que el orden correcto de los documentos a digitalizar es:\n\n';

      for (int i = 0; i < documentFields.farmascanMl.length; i++) {
        orderMessage +=
            '${i + 1}. ${capitalizeFirstLetter(documentFields.farmascanMl[i].fmlMensaje)}\n';
      }

      QuickAlert.show(
          context: context,
          type: QuickAlertType.info,
          widget: Text(orderMessage,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Readex Pro',
                    fontSize: 16.0,
                  )),
          showCancelBtn: true,
          confirmBtnText: 'Siguiente',
          cancelBtnText: 'Atras',
          confirmBtnColor: Color(0xFF6126E0),
          onConfirmBtnTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GalleryPageWidget(
                    document: documentFields,
                  ),
                ),
              ));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingFields == true) {
      return Container(
        color: Colors.white,
        child: Center(
          child: LoadingAnimationWidget.stretchedDots(
            color: Colors.indigo,
            size: 100,
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
          backgroundColor: Color(0xFF6126E0),
          automaticallyImplyLeading: true,
          title: Text(
            'Ingreso de Datos',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily: 'Inter',
                  color: Colors.white,
                  fontSize: 22.0,
                ),
          ),
          actions: [],
          centerTitle: false,
          elevation: 2.0,
        ),
        body: SafeArea(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            padding: EdgeInsets.all(15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    documentFields.nombre,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Readex Pro',
                          fontSize: 26.0,
                        ),
                  ),
                ),
                Expanded(child: ListView(children: dynamicFields)),
                if (_isButtonEnabled == true)
                  Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 25.0, 0.0, 0.0),
                    child: _isButtonEnabled == false
                        ? const SizedBox() // No muestra el botón si documentSelected.catCodigo == 0
                        : FFButtonWidget(
                            onPressed: () async {
                              _setDocumentFields();
                              _getDocumentsOrder();
                            },
                            text: 'Seleccionar',
                            options: FFButtonOptions(
                              height: 40.0,
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  24.0, 0.0, 24.0, 0.0),
                              iconPadding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 0.0),
                              color: Color(0xFF6126E0),
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
    );
  }
}
