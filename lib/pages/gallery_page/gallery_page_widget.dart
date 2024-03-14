import 'dart:convert';
import 'dart:io';

import 'package:app_farma_scan_v2/flutter_flow/flutter_flow_theme.dart';
import 'package:app_farma_scan_v2/index.dart';
import 'package:app_farma_scan_v2/models/documentFieldsData_model.dart';
import 'package:app_farma_scan_v2/pages/image_preview_page/image_preview_widget.dart';
import 'package:app_farma_scan_v2/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
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
    try {
      showLoading(context);
      final pickedFiles = await ImagePicker().pickMultiImage(
          maxHeight: 1500,
          maxWidth: 1500,
          imageQuality: 70,);

      if (pickedFiles.isNotEmpty) {
        List<File> fileList = await _processGalleryImages(pickedFiles);

        if (fileList.isEmpty) {
          Navigator.pop(context);
          QuickAlert.show(
            barrierDismissible: false,
            context: context,
            type: QuickAlertType.error,
            title: 'Error',
            widget: SingleChildScrollView(
              child: Text(
                'Seleccione los documentos de acuerdo al orden solicitado.',
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
          Navigator.pop(context);
          setState(() {
            _tempImages.addAll(fileList);
            _images = List.from(_tempImages);
          });
        }
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      Navigator.pop(context);
      QuickAlert.show(
        barrierDismissible: false,
        context: context,
        type: QuickAlertType.error,
        title: 'Error',
        widget: Text(
          'Se produjo un error al cargar imágenes desde la galería. $e',
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

  Future<List<File>> _processGalleryImages(List<XFile> images) async {
    List<File> processedImages = [];
    int index = _images.length;
    if (_images.length != 0) {
      index = _images.length + images.length - 1;
    }
    for (var image in images) {
      final file = File(image.path);
      var decodedImage = img.decodeImage(await file.readAsBytes());

      if (decodedImage!.width > decodedImage.height) {
        decodedImage = img.copyRotate(decodedImage, angle: 90);
        file.writeAsBytesSync(img.encodeJpg(decodedImage));
      }

      if (orderDocs.isNotEmpty &&
          index <= 1 &&
          orderDocs[index]['ocr'] == 'S') {
        var imageJPG = img.encodeJpg(decodedImage);
        final base64Image = base64Encode(imageJPG);
        String checkOcr = await apiService.postOCR(
          base64Image,
          orderDocs[index]['codigo'],
        );
        if (checkOcr.contains("Vuelva a escanear")) {
          return processedImages;
        } else {
          processedImages.add(file);
          index++;
        }
      } else {
        processedImages.add(file);
      }
    }
    return processedImages;
  }

  void _loadImageFromCamera() async {
    try {
      showLoading(context);
      /* List<String> pickedFile;
      pickedFile = await CunningDocumentScanner.getPictures(true) ?? []; */
      XFile? pickedFile = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxHeight: 1500,
        maxWidth: 1500,
      );

      if (pickedFile != null) {
        //Recortar la imagen
        CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
          ],
          uiSettings: [
            AndroidUiSettings(
                toolbarTitle: 'Recortar imagen',
                toolbarColor: Color(0xFF80BC00),
                toolbarWidgetColor: Colors.white,
                initAspectRatio: CropAspectRatioPreset.original,
                lockAspectRatio: false),
            IOSUiSettings(
              title: 'Recortar imagen',
            ),
            WebUiSettings(
              context: context,
            ),
          ],
        );

        if (croppedFile == null) {
          Navigator.pop(context);
          return;
        }
        File imageFile = File(croppedFile.path);

        if (!mounted) return;
        //String imagePath = pickedFile[0];
        // Procesa la imagen en segundo plano
        File image = await _processCameraImages(imageFile);
        setState(() {
          _images.add(image);
          _tempImages.add(image);
        });
        Navigator.pop(context);
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      Navigator.pop(context);
      QuickAlert.show(
        barrierDismissible: false,
        context: context,
        type: QuickAlertType.error,
        title: 'Error',
        widget: Text(
          'Oops ha ocurrido algo inesperado: $e',
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'Readex Pro',
                fontSize: 16.0,
              ),
        ),
        confirmBtnText: 'Aceptar',
        confirmBtnColor: Color.fromARGB(255, 222, 0, 56),
        onConfirmBtnTap: () => Navigator.pop(context),
      );
      throw e;
    }
  }

  Future<File> _processCameraImages(File file) async {
    var decodedImage = img.decodeImage(await file.readAsBytes());

    // Realiza la rotación si es necesario
    if (decodedImage!.width > decodedImage.height) {
      decodedImage = img.copyRotate(decodedImage, angle: 90);
      await file.writeAsBytes(img.encodeJpg(decodedImage));
    }

    // Si no se necesita OCR, devuelve el archivo original
    if (orderDocs.isEmpty ||
        _images.length >= orderDocs.length ||
        orderDocs[_images.length]['ocr'] == 'N') {
      return file;
    }

    // Realiza el OCR si es necesario
    if (orderDocs.isNotEmpty &&
        _images.length <= 1 &&
        orderDocs[_images.length]['ocr'] == 'S') {
      final imageJPG = img.encodeJpg(decodedImage);
      final base64Image = base64Encode(imageJPG);
      String checkOcr = await apiService.postOCR(
        base64Image,
        orderDocs[_images.length]['codigo'],
      );
      if (checkOcr.contains("Vuelva a escanear")) {
        throw 'El orden de los documentos no coincide con el solicitado. Vuelva a escanear los documentos en el orden solicitado.';
      }
    }

    return file;
  }

  static dynamic showLoading(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Center(
            child: LoadingAnimationWidget.staggeredDotsWave(
              color: Colors.white,
              size: 100,
            ),
          );
        });
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
    try {
      setState(() {
        _isLoading = true;
      });
      List<String> digiCodes = [];
      List<String> infoCodes = [];
      _imagestoBase64();
      for (DocumentFieldsData document in documents) {
        try {
          _completeData(document);

          Map<String, dynamic> response =
              await apiService.postDocuments(document);
          if (response['status_code'] == 200) {
            digiCodes.add('${document.nombre}: ${response['mensaje']}');
          } else {
            infoCodes.add('${document.nombre}\n${response['mensaje']}');
          }
        } catch (error) {
          infoCodes.add('${document.nombre}\nError de conexión: $error');
        }
      }

      if (digiCodes.isNotEmpty) {
        String successMessages = '\n';
        for (int i = 0; i < digiCodes.length; i++) {
          successMessages +=
              '${i + 1}. ${digiCodes[i].replaceAll(RegExp(r'[{}\[\],]'), '')}\n';
        }
        setState(() {
          _isLoading = false;
        });
        QuickAlert.show(
          barrierDismissible: false,
          context: context,
          type: QuickAlertType.success,
          title: 'Digitalización enviada',
          widget: Text(
            'Se ha enviado los siguientes documentos al servidor: \n $successMessages',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'Readex Pro',
                  fontSize: 16.0,
                ),
          ),
          confirmBtnText: 'Aceptar',
          confirmBtnColor: const Color.fromARGB(255, 21, 192, 106),
          onConfirmBtnTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DashboardPageWidget()),
          ),
        );
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

        setState(() {
          _isLoading = false;
        });

        QuickAlert.show(
            barrierDismissible: false,
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
            onConfirmBtnTap: () => {
                  if (digiCodes.isEmpty)
                    {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DashboardPageWidget()),
                      )
                    }
                  else
                    {Navigator.pop(context)}
                });
      }
    } catch (error) {
      print('Error: $error');
      QuickAlert.show(
        barrierDismissible: false,
        context: context,
        type: QuickAlertType.error,
        title: 'Error',
        widget: Text(
          'Se produjo un error al enviar las digitalizaciones. $error',
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'Readex Pro',
                fontSize: 16.0,
              ),
        ),
        confirmBtnText: 'Aceptar',
        confirmBtnColor: Color.fromARGB(255, 222, 0, 56),
        onConfirmBtnTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DashboardPageWidget()),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _sendDigitalization() async {
    QuickAlert.show(
      barrierDismissible: false,
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
    // ignore: deprecated_member_use
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
                    Visibility(
                      visible: _images.isNotEmpty,
                      child: FloatingActionButton(
                        onPressed: _clearImages,
                        tooltip: 'Limpiar imágenes',
                        backgroundColor: Colors.red,
                        child:
                            const Icon(Icons.delete_sweep, color: Colors.white),
                        heroTag: 'clear_images',
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Visibility(
                      visible: _images.isNotEmpty,
                      child: FloatingActionButton(
                        onPressed: _images.isEmpty
                            ? () => QuickAlert.show(
                                  barrierDismissible: false,
                                  context: context,
                                  type: QuickAlertType.info,
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
                                      Color.fromARGB(255, 255, 201, 70),
                                  onConfirmBtnTap: () => Navigator.pop(context),
                                )
                            : _sendDigitalization,
                        tooltip: 'Enviar documento',
                        backgroundColor: Colors.orange,
                        child: const Icon(
                          Icons.send_and_archive,
                          color: Colors.white,
                        ),
                        heroTag: 'send_images',
                      ),
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
                      child:
                          const Icon(Icons.photo_library, color: Colors.white),
                      heroTag: 'load_gallery',
                    ),
                    const SizedBox(height: 16),
                    FloatingActionButton(
                      onPressed: () => {
                        if (orderDocs.isNotEmpty &&
                            _images.length < orderDocs.length &&
                            orderDocs[_images.length]['ocr'] == 'S')
                          {
                            QuickAlert.show(
                              barrierDismissible: false,
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
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Readex Pro',
                                        fontSize: 16.0,
                                      ),
                                ),
                              ),
                              confirmBtnText: 'Aceptar',
                              confirmBtnColor:
                                  Color.fromARGB(255, 255, 201, 70),
                              onConfirmBtnTap: () {
                                Navigator.pop(context);
                                _loadImageFromCamera();
                              },
                            )
                          }
                        else
                          {
                            _loadImageFromCamera(),
                          }
                      },
                      tooltip: 'Cargar desde la cámara',
                      backgroundColor: const Color.fromARGB(255, 11, 161, 175),
                      child: const Icon(Icons.camera_alt, color: Colors.white),
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
