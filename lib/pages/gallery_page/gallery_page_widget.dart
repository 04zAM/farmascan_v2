import 'dart:convert';
import 'dart:io';

import 'package:app_farma_scan_v2/flutter_flow/flutter_flow_theme.dart';
import 'package:app_farma_scan_v2/index.dart';
import 'package:app_farma_scan_v2/models/documentFieldsData_model.dart';
import 'package:app_farma_scan_v2/pages/image_preview_page/image_preview_widget.dart';
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
  final List<dynamic> orderDocs;
  const GalleryPageWidget(
      {Key? key, required this.documents, required this.orderDocs})
      : super(key: key);

  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPageWidget> {
  List<File> _images = [];
  final List<File> _tempImages = [];
  late List<DocumentFieldsData> documents;
  late List<dynamic> orderDocs;
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
    orderDocs = widget.orderDocs;
    deleteDuplicates(orderDocs);
    setState(() {
      _isLoading = false;
    });
  }

  void _loadImagesFromGallery() async {
    setState(() {
      _isLoading = true;
    });
    final pickedFiles = await ImagePicker().pickMultiImage();
    int index = _images.length + pickedFiles.length - 1;
    print("cantidad de imágenes: " + index.toString());
    for (var pickedFile in pickedFiles) {
      final file = File(pickedFile.path);
      var originalImage = img.decodeImage(await file.readAsBytes());
      final originalEncoded = img.encodeJpg(originalImage!);
      final originalImageBase64 = base64Encode(originalEncoded);
      var decodedImage = img.decodeImage(await file.readAsBytes());
      if (decodedImage != null) {
        //girar a las imagenes horizontales y remplazarla en file
        if (decodedImage.width > decodedImage.height) {
          decodedImage = img.copyRotate(decodedImage, angle: 90);
          file.writeAsBytesSync(img.encodeJpg(decodedImage));
        }

        if (orderDocs.isNotEmpty && orderDocs[index]['ocr'] == 'S') {
          String checkOcr = await apiService.postOCR(
            originalImageBase64,
            orderDocs[index]['codigo'],
          );
          if (checkOcr.contains("Vuelva a escanear")) {
            setState(() {
              _isLoading = false;
            });
            QuickAlert.show(
              context: context,
              type: QuickAlertType.error,
              title: 'Error',
              widget: SingleChildScrollView(
                child: Text(
                  'El documento escaneado no corresponde al orden solicitado, por favor verifique.',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Readex Pro',
                        fontSize: 16.0,
                      ),
                ),
              ),
              confirmBtnText: 'Aceptar',
              confirmBtnColor: Color.fromARGB(255, 222, 0, 56),
              onConfirmBtnTap: () => Navigator.pop(context),
            );
          } else {
            index++;
            setState(() {
              _tempImages.add(file);
            });
          }
        } else {
          setState(() {
            _tempImages.add(file);
          });
        }
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
            confirmBtnColor: Color.fromARGB(255, 222, 0, 56),
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
      if (orderDocs.isNotEmpty &&
          _images.length < orderDocs.length &&
          orderDocs[_images.length]['ocr'] == 'S') {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.info,
          title: 'Atención!',
          widget: SingleChildScrollView(
            child: Text(
              'Usted va a digitalizar' +
                  ' ' +
                  ((orderDocs.length > _images.length)
                      ? orderDocs[_images.length]['mensaje']
                      : 'DOCUMENTOS COMPLEMENTARIOS') +
                  '.',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Readex Pro',
                    fontSize: 16.0,
                  ),
            ),
          ),
          confirmBtnText: 'Aceptar',
          confirmBtnColor: Color.fromARGB(255, 255, 201, 70),
          onConfirmBtnTap: () async {
            final pickedFiles = await CunningDocumentScanner.getPictures(true);
            //Cerrar el quickalert
            Navigator.pop(context);
            setState(() {
              _isLoading = true;
            });
            if (pickedFiles != null) {
              final imageBase64 =
                  base64Encode(File(pickedFiles.first).readAsBytesSync());
              String checkOcr = await apiService.postOCR(
                imageBase64,
                orderDocs[_images.length]['codigo'],
              );
              if (checkOcr.contains("Vuelva a escanear")) {
                setState(() {
                  _isLoading = false;
                });
                QuickAlert.show(
                  context: context,
                  type: QuickAlertType.error,
                  title: 'Error',
                  widget: SingleChildScrollView(
                    child: Text(
                      'El documento escaneado no corresponde al orden solicitado, por favor verifique.',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Readex Pro',
                            fontSize: 16.0,
                          ),
                    ),
                  ),
                  confirmBtnText: 'Aceptar',
                  confirmBtnColor: Color.fromARGB(255, 222, 0, 56),
                  onConfirmBtnTap: () => Navigator.pop(context),
                );
              } else {
                setState(() {
                  _isLoading = true;
                });
                for (var pickedFile in pickedFiles) {
                  final file = File(pickedFile);
                  var decodedImage = img.decodeImage(await file.readAsBytes());
                  if (decodedImage!.width > decodedImage.height) {
                    decodedImage = img.copyRotate(decodedImage, angle: 90);
                    file.writeAsBytesSync(img.encodeJpg(decodedImage));
                  }
                }
                setState(() {
                  _tempImages.add(File(pickedFiles.first));
                  _images = List.from(_tempImages);
                  _isLoading = false;
                });
              }
            }
          },
        );
      } else {
        final pickedFiles = await CunningDocumentScanner.getPictures(true);
        if (pickedFiles != null) {
          setState(() {
            _isLoading = true;
          });
          for (var pickedFile in pickedFiles) {
            final file = File(pickedFile);
            var decodedImage = img.decodeImage(await file.readAsBytes());
            if (decodedImage!.width > decodedImage.height) {
              decodedImage = img.copyRotate(decodedImage, angle: 90);
              file.writeAsBytesSync(img.encodeJpg(decodedImage));
            }
          }
          setState(() {
            _tempImages.addAll(pickedFiles.map((e) => File(e)).toList());
            _images = List.from(_tempImages);
            _isLoading = false;
          });
        }
      }
    } catch (e, stackTrace) {
      setState(() {
        _isLoading = false;
      });

      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Error',
        widget: Text(
          'Se produjo un error al cargar imágenes desde la cámara. $e. $stackTrace',
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'Readex Pro',
                fontSize: 16.0,
              ),
        ),
        confirmBtnText: 'Aceptar',
        confirmBtnColor: Color.fromARGB(255, 222, 0, 56),
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

  void _uploadDocuments() async {
    setState(() {
      _isLoading = true;
    });
    List<String> digiCodes = [];
    List<String> infoCodes = [];
    _imagestoBase64();
    for (DocumentFieldsData document in documents) {
      _completeData(document);

      Map<String, dynamic> response = await apiService.postDocuments(document);
      if (response['status_code'] == 200) {
        digiCodes.add('${document.nombre}: ${response['mensaje']}');
      } else {
        infoCodes.add('${document.nombre}\n${response['mensaje']}');
      }
    }

    if (digiCodes.isNotEmpty) {
      String successMessages = '\n';
      for (int i = 0; i < digiCodes.length; i++) {
        successMessages +=
            '${i + 1}. ${digiCodes[i].replaceAll(RegExp(r'[{}\[\],]'), '')}\n';
      }
      QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Digitalización enviada',
          widget: Text(
              'Se ha enviado los siguientes documentos al servidor: \n $successMessages',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Readex Pro',
                    fontSize: 16.0,
                  )),
          confirmBtnText: 'Aceptar',
          confirmBtnColor: const Color.fromARGB(255, 21, 192, 106),
          onConfirmBtnTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DashboardPageWidget()),
              ));
    }

    if (infoCodes.isNotEmpty) {
      List<String> uniqueinfoCodes = [];
      for (String info in infoCodes) {
        if (!uniqueinfoCodes.contains(info)) {
          uniqueinfoCodes.add(info);
        }
      }
      infoCodes = uniqueinfoCodes;

      String infoMessages =
          'Existen las siguientes novedades en las digitalizaciones:\n\n';
      for (int i = 0; i < infoCodes.length; i++) {
        infoMessages +=
            '${i + 1}. ${infoCodes[i].replaceAll(RegExp(r'[{}\[\],]'), '')}\n';
      }

      QuickAlert.show(
        context: context,
        type: QuickAlertType.info,
        title: 'Atención!',
        widget: SingleChildScrollView(
          child: Text(
            '$infoMessages',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'Readex Pro',
                  fontSize: 16.0,
                ),
          ),
        ),
        confirmBtnText: 'Aceptar',
        confirmBtnColor: Color.fromARGB(255, 255, 201, 70),
        onConfirmBtnTap: () => Navigator.pop(context),
      );
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
      confirmBtnColor: Color.fromARGB(255, 50, 205, 187),
      onConfirmBtnTap: () {
        Navigator.pop(context);
        _uploadDocuments();
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

  void deleteDuplicates(List<dynamic> lista) {
    Set<dynamic> mensajesUnicos = Set<dynamic>();
    lista.removeWhere((element) {
      if (element is Map<String, dynamic> && element.containsKey('mensaje')) {
        final mensaje = element['mensaje'];
        final esDuplicado = mensajesUnicos.contains(mensaje);
        mensajesUnicos.add(mensaje);
        return esDuplicado;
      }
      return false;
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
                    fontSize: 18.0,
                  ),
            ),
            backgroundColor: Colors.indigo,
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
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ImagePreview(image: image),
                          ),
                        );
                      },
                      child: Hero(
                        tag:
                            'imageTag$index', // Debe ser único para cada imagen
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.file(image, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                        child: Hero(
                          tag:
                              'deleteIcon$index', // Debe ser único para cada icono de eliminación
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.white),
                            onPressed: () => _removeImage(index),
                            iconSize: 15,
                          ),
                        ),
                      ),
                    )
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
                                    'No se han cargado imágenes en el tablero.',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Readex Pro',
                                          fontSize: 16.0,
                                        )),
                                confirmBtnText: 'Aceptar',
                                confirmBtnColor:
                                    Color.fromARGB(255, 222, 0, 56),
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
