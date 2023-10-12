import 'dart:io';

import 'package:app_farma_scan_v2/flutter_flow/flutter_flow_theme.dart';
import 'package:app_farma_scan_v2/index.dart';
import 'package:app_farma_scan_v2/models/documentFieldsData_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:quickalert/quickalert.dart';

class GalleryPageWidget extends StatefulWidget {
  final DocumentFieldsData document;
  const GalleryPageWidget({Key? key, required this.document}) : super(key: key);

  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPageWidget> {
  List<File> _images = [];
  final List<File> _tempImages = [];
  late DocumentFieldsData document;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDocument();
  }

  void _loadDocument() {
    setState(() {
      _isLoading = true;
    });
    document = widget.document;
    setState(() {
      _isLoading = false;
    });
  }

  void _loadImagesFromGallery() async {
    final pickedFiles = await ImagePicker().pickMultiImage();
    setState(() {
      _tempImages
          .addAll(pickedFiles.map((pickedFile) => File(pickedFile.path)));
      _images = List.from(_tempImages);
    });
  }

  void _loadImageFromCamera() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _tempImages.add(File(pickedFile.path));
        _images = List.from(_tempImages);
      });
    }
  }

  void _uploadImages() async {
    setState(() {
      _isLoading = true;
    });
    //coger las imagenes del tablero y agregarlas al documento en imagenes
    document.imagenes.add({"nombre": ''});
    //Quicktype
    QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: 'Digitalización enviada',
        widget: Text(
            'Se ha enviado información al servidor con código documental: 1545675',
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
    setState(() {
      _isLoading = false;
    });
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
          child: LoadingAnimationWidget.stretchedDots(
            color: Colors.indigo,
            size: 100,
          ),
        ),
      );
    }
    return Scaffold(
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
                  onPressed: _uploadImages,
                  tooltip: 'Enviar documento',
                  backgroundColor: Colors.orange,
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
    );
  }
}
