import 'package:app_farma_scan_v2/flutter_flow/flutter_flow_widgets.dart';
import 'package:app_farma_scan_v2/index.dart';
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
    final List<dynamic> orderDocs = [];

    for (DocumentFieldsData document in documentStructureArray) {
      if (document.farmascanMl.isEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GalleryPageWidget(
              documents: documentStructureArray,
              orderDocs: [],
            ),
          ),
        );
      } else {
        for (int i = 0; i < document.farmascanMl.length; i++) {
          String message = document.farmascanMl[i].fmlMensaje;
          final item = {
            'mensaje': message,
            'ocr': document.farmascanMl[i].fmlValidarReglasOcr,
            'predict': document.farmascanMl[i].fmlValidarModeloPrediccion,
            'codigo': document.farmascanMl[i].fmlDocumentoCodigo,
          };

          if (!orderDocs
              .contains(orderDocs.where((e) => e['mensaje'] == message))) {
            orderDocs.add(item);
          }
        }
      }
    }

    orderDocs.sort((a, b) {
      final preferencias = {
        'Comprobante de venta': 1,
        'Factura': 2,
        'Cupón': 3,
        'Receta': 4,
        'Correo': 5
      };

      final mensajeA = a['mensaje'].toLowerCase();
      final mensajeB = b['mensaje'].toLowerCase();

      final ordenA = preferencias.keys.firstWhere(
          (key) => mensajeA.contains(key.toLowerCase()),
          orElse: () => 'null');

      final ordenB = preferencias.keys.firstWhere(
          (key) => mensajeB.contains(key.toLowerCase()),
          orElse: () => 'null');

      if (ordenA != 'null' && ordenB != 'null') {
        return (preferencias[ordenA] as num)
            .compareTo(preferencias[ordenB] as num);
      } else if (ordenA != 'null') {
        return -1;
      } else if (ordenB != 'null') {
        return 1;
      } else {
        return a['mensaje'].compareTo(b['mensaje']);
      }
    });

    int index = 1;
    for (int i = 0; i < orderDocs.length; i++) {
      if (!messagesShown.contains(orderDocs[i]['mensaje'])) {
        messagesShown.add(orderDocs[i]['mensaje']);
        orderMessage +=
            '${index++}. ${capitalizeFirstLetter(orderDocs[i]['mensaje'])}\n';
      }
    }

    QuickAlert.show(
        barrierDismissible: false,
        context: context,
        type: QuickAlertType.info,
        title: 'Atención!',
        widget: Text(orderMessage,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'Readex Pro',
                  fontSize: 16.0,
                )),
        showCancelBtn: true,
        confirmBtnText: 'Continuar',
        cancelBtnText: 'Atras',
        confirmBtnColor: Color.fromARGB(255, 255, 201, 70),
        onConfirmBtnTap: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => GalleryPageWidget(
                  documents: documentStructureArray,
                  orderDocs: orderDocs,
                ),
              ),
              (route) => false,
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
                      style: TextStyle(fontSize: 14, color: Colors.black)),
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
    if (documentStructureArray.isEmpty) {
      return GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(_model.unfocusNode),
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          appBar: AppBar(
            backgroundColor: Colors.indigo,
            automaticallyImplyLeading: true,
            title: Text(
              'Documentos a digitalizar',
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
            child: Stack(
              children: [
                Container(
                  color: Colors.white,
                  width: double.infinity,
                  height: double.infinity,
                  padding: EdgeInsets.all(15.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //Imagen tipo gif de error
                      Center(
                        child: Image.asset(
                          'assets/lottie_animations/not_found_page.gif',
                          width: 300,
                          height: 180,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Center(
                        child: Text(
                          'Atención!',
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'Readex Pro',
                                    fontSize: 18.0,
                                    color: Colors.red,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: Text(
                          'Error al obtener la estructura de los documentos. Por favor verifique la parametrización o procedimiento almacenado en base de datos.',
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'Readex Pro',
                                    fontSize: 18.0,
                                  ),
                          textAlign: TextAlign.justify,
                        ),
                      ),
                      SizedBox(height: 30),
                      FFButtonWidget(
                        text: 'Regresar',
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DashboardPageWidget()),
                        ),
                        options: FFButtonOptions(
                          width: 200.0,
                          height: 50.0,
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 0.0),
                          iconPadding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 0.0),
                          color: Colors.red,
                          textStyle:
                              FlutterFlowTheme.of(context).titleSmall.override(
                                    fontFamily: 'Readex Pro',
                                    color: Colors.white,
                                  ),
                          elevation: 3.0,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else if (_isLoading == true) {
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
          backgroundColor: Colors.indigo,
          automaticallyImplyLeading: true,
          title: Text(
            'Documentos a digitalizar',
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        dynamicCards.length,
                        (index) => Container(
                          width: 12.0,
                          height: 12.0,
                          margin: EdgeInsets.symmetric(horizontal: 4.0),
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? Color(0xFF6126E0)
                                : Color(0xFF9E9E9E),
                            shape: BoxShape.circle,
                          ),
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
                child: Visibility(
                  visible: _currentPage == dynamicCards.length - 1,
                  child: FloatingActionButton(
                    onPressed: _currentPage == dynamicCards.length - 1
                        ? _getDocumentsOrder
                        : null,
                    child: Icon(Icons.photo_library, color: Colors.white),
                    backgroundColor: Color(0xFF6126E0),
                    tooltip: 'Agregar Imágenes',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
