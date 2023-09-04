import 'package:app_farma_scan_v2/models/documentFieldsData_model.dart';
import 'package:app_farma_scan_v2/services/api_service.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

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
  late DocumentFieldsData documentFields;
  late List<Widget> dynamicFields = [];
  List<TextEditingController> textControllers = [];

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

  void _createDynamicFields() {
    documentFields.propiedades.forEach((field) {
      if (field.tpdTipoDato == 4) {
        final dateField = TextFormField(
          decoration: InputDecoration(
            labelText: capitalizeFirstLetter(field.prdNombre) + ':',
          ),
          onTap: () async {
            DateTime? selectedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
            );
            if (selectedDate != null) {
              setState(() {
                field.datos = selectedDate;
              });
            }
          },
        );
        dynamicFields.add(dateField);
      } else {
        final controller = TextEditingController();
        textControllers.add(controller);
        final textField = Padding(
          padding: EdgeInsets.only(
              bottom: 15.0, top: 15.0), // Solo ajustamos el padding inferior
          child: TextFormField(
            controller: controller,
            obscureText: false,
            decoration: InputDecoration(
              labelText: capitalizeFirstLetter(field.prdNombre) + ':',
              labelStyle: FlutterFlowTheme.of(context)
                  .bodyLarge, // Usamos labelStyle en lugar de hintStyle
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: FlutterFlowTheme.of(context).alternate,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(12.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0x00000000),
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(12.0),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0x00000000),
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(12.0),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0x00000000),
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
                // Otros widgets aquí
              ],
            ),
          ),
        ),
      ),
    );
  }
}
