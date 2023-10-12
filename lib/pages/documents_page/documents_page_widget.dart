import 'package:app_farma_scan_v2/models/documentFieldsData_model.dart';
import 'package:app_farma_scan_v2/pages/gallery_page/gallery_page_widget.dart';
import 'package:app_farma_scan_v2/services/api_service.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:quickalert/quickalert.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'documents_page_model.dart';
export 'documents_page_model.dart';

class DocumentsPageWidget extends StatefulWidget {
  final List<DocumentFieldsData> documentsStructureList;

  const DocumentsPageWidget({Key? key, required this.documentsStructureList})
      : super(key: key);

  @override
  _DocumentsPageWidgetState createState() => _DocumentsPageWidgetState();
}

class _DocumentsPageWidgetState extends State<DocumentsPageWidget> {
  late DocumentsPageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  final ApiService apiService = ApiService();
  late List<DocumentFieldsData> documentStructureArray;
  bool _isLoading = false;
  List<Widget> dynamicCards = [];

  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    documentStructureArray = widget.documentsStructureList;
    _model = createModel(context, () => DocumentsPageModel());
    getdynamicCards();
  }

  @override
  void dispose() {
    _model.dispose();
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

  void _getDocumentsOrder() async {
    String orderMessage =
        'Estimado usuario recuerde que el orden correcto de los documentos a digitalizar es:\n\n';
    Set<String> messagesShown = Set<String>();

    for (DocumentFieldsData document in documentStructureArray) {
      if (document.farmascanMl.isEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GalleryPageWidget(
              document: document,
            ),
          ),
        );
      } else {
        for (int i = 0; i < document.farmascanMl.length; i++) {
          String message = document.farmascanMl[i].fmlMensaje;
          if (!messagesShown.contains(message)) {
            orderMessage +=
                '${messagesShown.length + 1}. ${capitalizeFirstLetter(message)}\n';
            messagesShown.add(message);
          }
        }
      }
    }

    QuickAlert.show(
        context: context,
        type: QuickAlertType.confirm,
        title: 'Atención!',
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
                  document: documentStructureArray[0],
                ),
              ),
            ));
  }

  void getdynamicCards() {
    setState(() {
      _isLoading = true;
    });

    dynamicCards.clear(); // Limpia el arreglo antes de agregar nuevas tarjetas.

    for (DocumentFieldsData document in documentStructureArray) {
      List<Widget> cards = [];
      List<Widget> fields = [];
      for (var propiedad in document.propiedades) {
        fields.add(
          Container(
            width: double.infinity,
            margin: EdgeInsets.fromLTRB(15, 5, 15, 10),
            padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
            decoration: BoxDecoration(
              color: Color(0xFFEEEEEE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(capitalizeFirstLetter(propiedad.prdNombre) + ':',
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Text(capitalizeFirstLetter(propiedad.datos),
                      style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ),
        );
      }
      cards.add(
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
          ),
          padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
          margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
          child: Padding(
            padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    document.nombre,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                    height:
                        10), // Espacio adicional entre el título y los campos
                SingleChildScrollView(
                  // Utilizamos SingleChildScrollView aquí
                  child: Column(
                    children: fields,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      dynamicCards.add(
        SingleChildScrollView(
          child: Column(
            children: cards,
          ),
        ),
      );

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading == true) {
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
            'Documentos a digitalizar',
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
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                padding: EdgeInsets.all(15.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        'Verifique la información antes de digitalizar:',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Readex Pro',
                              fontSize: 18.0,
                            ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: PageView(
                        children: dynamicCards
                            .map((card) => SingleChildScrollView(
                                  child: card,
                                ))
                            .toList(),
                        onPageChanged: (int page) {
                          setState(() {
                            _currentPage = page;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 20,
                right: 20,
                child: FloatingActionButton(
                  onPressed: _currentPage == dynamicCards.length - 1
                      ? _getDocumentsOrder
                      : null,
                  child: Icon(Icons.photo_library),
                  backgroundColor: _currentPage == dynamicCards.length - 1
                      ? Color(0xFF6126E0)
                      : Colors.indigo[200],
                  tooltip: _currentPage == dynamicCards.length - 1
                      ? 'Agregar Imágenes'
                      : '',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}