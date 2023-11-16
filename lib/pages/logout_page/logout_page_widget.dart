import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LogoutPageWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Aquí puedes personalizar la apariencia de la página de cierre de sesión
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
            Text("Cerrando sesión",
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
}
