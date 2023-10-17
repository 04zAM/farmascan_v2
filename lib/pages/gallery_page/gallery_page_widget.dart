import 'dart:convert';
import 'dart:io';

import 'package:app_farma_scan_v2/flutter_flow/flutter_flow_theme.dart';
import 'package:app_farma_scan_v2/index.dart';
import 'package:app_farma_scan_v2/models/documentFieldsData_model.dart';
import 'package:app_farma_scan_v2/services/api_service.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:image/image.dart' as img;

class GalleryPageWidget extends StatefulWidget {
  final List<DocumentFieldsData> documents;
  const GalleryPageWidget({Key? key, required this.documents})
      : super(key: key);

  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPageWidget> {
  List<File> _images = [];
  final List<File> _tempImages = [];
  late List<DocumentFieldsData> documents;
  bool _isLoading = false;
  List<Map<String, String>> _base64Images = [];
  final ApiService apiService = ApiService();
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  void _loadDocuments() async {
    setState(() {
      _isLoading = true;
    });
    documents = widget.documents;
    setState(() {
      _isLoading = false;
    });
  }

  // dividir esta funcion para que cargue de mejor manera y convierta las imagenes a jpg
  void _loadImagesFromGallery() async {
    setState(() {
      _isLoading = true;
    });
    final pickedFiles = await ImagePicker().pickMultiImage();
    for (var pickedFile in pickedFiles) {
      final file = File(pickedFile.path);
      final decodedImage = img.decodeImage(await file.readAsBytes());

      if (decodedImage != null) {
        final resizedImage = img.copyResize(decodedImage, width: 1024);
        _tempImages.add(File(pickedFile.path)
          ..writeAsBytesSync(img.encodeJpg(resizedImage)));
      } else {
        QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: 'Error',
            widget: Text(
                'No se pudo cargar la imagen, por favor intente de nuevo. Formatos permitidos JPG, PNG.',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Readex Pro',
                      fontSize: 16.0,
                    )),
            confirmBtnText: 'Aceptar',
            confirmBtnColor: Color(0xFF6126E0),
            onConfirmBtnTap: () => Navigator.pop(context));
      }
    }
    _images = List.from(_tempImages);
    setState(() {
      _isLoading = false;
    });
  }

  void _loadImageFromCamera() async {
    try {
      final pickedFiles = await CunningDocumentScanner.getPictures();
      setState(() {
        _isLoading = true;
      });

      if (pickedFiles != null) {
        setState(() {
          _tempImages.addAll(pickedFiles.map((pickedFile) => File(pickedFile)));
          _images = List.from(_tempImages);
        });
      } else {
        // Manejo de errores si pickedFiles es nulo (puede ser un indicativo de que no se seleccionaron imágenes)
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error',
          widget: Text(
            'No se seleccionaron imágenes desde la cámara.',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'Readex Pro',
                  fontSize: 16.0,
                ),
          ),
          confirmBtnText: 'Aceptar',
          confirmBtnColor: Color(0xFF6126E0),
          onConfirmBtnTap: () => Navigator.pop(context),
        );
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Error',
        widget: Text(
          'Se produjo un error al cargar imágenes desde la cámara.',
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'Readex Pro',
                fontSize: 16.0,
              ),
        ),
        confirmBtnText: 'Aceptar',
        confirmBtnColor: Color(0xFF6126E0),
        onConfirmBtnTap: () => Navigator.pop(context),
      );
    }
  }

  void _imagestoBase64() {
    _base64Images.clear();

    for (File image in _images) {
      // Leer la imagen
      List<int> imageBytes = image.readAsBytesSync();
      String base64Image = base64Encode(imageBytes);

      // Crear plantilla de guardado
      Map<String, String> imagen = {
        "nombre": "",
        "tipo": "JPG",
        "base64": base64Image,
        "origen": "",
        "vista": ""
      };

      // Convertir a base64
      _base64Images.add(imagen);
    }
  }

  void _completeData(DocumentFieldsData document) async {
    prefs = await SharedPreferences.getInstance();
    document.imagenes = _base64Images;
    document.devolverPropietario = 'S';
    document.ipRegistra = prefs.getString('ipPharma')!;
    document.usuarioRegistra = prefs.getString('nombreCorto')!;
    document.centroCosto = prefs.getString('centroCosto')!;
    document.propietario.ciPasRuc = prefs.getString('cedula')!;
    document.propietario.tipoPropietario = 'EMPLEADO';
    document.origen = 'M';
  }

  void _uploadImages() async {
    setState(() {
      _isLoading = true;
    });
    List<String> digiCodes = [];
    List<String> errorCodes = [];
    _imagestoBase64();
    for (DocumentFieldsData document in documents) {
      _completeData(document);
      Map<String, dynamic> response = await apiService.postDocuments(document);
      if (response['status_code'] == 200) {
        digiCodes.add(response['mensaje']);
      } else {
        errorCodes.add(response['mensaje']);
      }
    }

    if (digiCodes.isNotEmpty) {
      QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Digitalización enviada',
          widget: Text(
              'Se ha enviado información al servidor con códigos documentales: ${digiCodes.join(', ')}',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Readex Pro',
                    fontSize: 16.0,
                  )),
          confirmBtnText: 'Aceptar',
          confirmBtnColor: Color(0xFF6126E0),
          onConfirmBtnTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DashboardPageWidget()),
              ));
    }

    if (errorCodes.isNotEmpty) {
      List<String> uniqueErrorCodes = [];
      for (String error in errorCodes) {
        if (!uniqueErrorCodes.contains(error)) {
          uniqueErrorCodes.add(error);
        }
      }
      errorCodes = uniqueErrorCodes;

      String errorMessage =
          'Existen los siguientes errores en la digitalización:\n\n';
      for (int i = 0; i < errorCodes.length; i++) {
        errorMessage += '${i + 1}. ${errorCodes[i]}\n';
      }

      QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error',
          widget: Text('$errorMessage',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Readex Pro',
                    fontSize: 16.0,
                  )),
          confirmBtnText: 'Aceptar',
          confirmBtnColor: Color(0xFF6126E0),
          onConfirmBtnTap: () => Navigator.pop(
                context,
              ));
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _sendDigitalization() async {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: 'Atención!',
      widget: Text('Está seguro que desea enviar la digitalización?',
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'Readex Pro',
                fontSize: 16.0,
              )),
      showCancelBtn: true,
      confirmBtnText: 'Enviar',
      cancelBtnText: 'Cancelar',
      confirmBtnColor: Color(0xFF6126E0),
      onConfirmBtnTap: () {
        Navigator.pop(context);
        _uploadImages();
      },
    );
  }

  void _clearImages() {
    setState(() {
      _images.clear();
      _tempImages.clear();
    });
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
      _tempImages.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading == true) {
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
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'Tablero de Imágenes',
              style: FlutterFlowTheme.of(context).headlineMedium.override(
                    fontFamily: 'Inter',
                    color: Colors.white,
                    fontSize: 22.0,
                  ),
            ),
            backgroundColor: Color(0xFF6126E0),
          ),
          body: Padding(
            padding: const EdgeInsets.all(10.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: _images.length,
              itemBuilder: (BuildContext context, int index) {
                final image = _images[index];
                return Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Implement any action when an image is tapped
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.file(image, fit: BoxFit.cover),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.white),
                          onPressed: () => _removeImage(index),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.fromLTRB(35, 0, 0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FloatingActionButton(
                      onPressed: _clearImages,
                      tooltip: 'Limpiar imágenes',
                      backgroundColor: Colors.red,
                      child: const Icon(Icons.delete_sweep),
                      heroTag: 'clear_images',
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FloatingActionButton(
                      onPressed: _images.isEmpty
                          ? () => QuickAlert.show(
                                context: context,
                                type: QuickAlertType.error,
                                title: 'Error',
                                widget: Text(
                                    'No se han cargado imágenes para enviar.',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Readex Pro',
                                          fontSize: 16.0,
                                        )),
                                confirmBtnText: 'Aceptar',
                                confirmBtnColor: Color(0xFF6126E0),
                                onConfirmBtnTap: () => Navigator.pop(context),
                              )
                          : _sendDigitalization,
                      tooltip: 'Enviar documento',
                      backgroundColor:
                          _images.isEmpty ? Colors.orange[200] : Colors.orange,
                      child: const Icon(Icons.send_and_archive),
                      heroTag: 'send_images',
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FloatingActionButton(
                      onPressed: _loadImagesFromGallery,
                      tooltip: 'Cargar desde la galería',
                      backgroundColor: Colors.indigo,
                      child: const Icon(Icons.photo_library),
                      heroTag: 'load_gallery',
                    ),
                    const SizedBox(height: 16),
                    FloatingActionButton(
                      onPressed: _loadImageFromCamera,
                      tooltip: 'Cargar desde la cámara',
                      backgroundColor: const Color.fromARGB(255, 11, 161, 175),
                      child: const Icon(Icons.camera_alt),
                      heroTag: 'load_camera',
                    ),
                  ],
                ),
              ],
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
