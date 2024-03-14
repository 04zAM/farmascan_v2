import 'dart:io';

import 'package:app_farma_scan_v2/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';

class ImagePreview extends StatelessWidget {
  final File image;

  ImagePreview({required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        automaticallyImplyLeading: true,
        title: Text(
          'Vista previa',
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
      body: Center(
        child: Hero(
          tag:
              'imageTag', // Asegúrate de que coincida con el mismo 'tag' usado en la miniatura
          child: InteractiveViewer(
            panEnabled: true,
            minScale: 0.1, // Escala mínima
            maxScale: 8.0,
            // Escala máxima
            child: Image.file(image),
          ),
        ),
      ),
    );
  }
}
