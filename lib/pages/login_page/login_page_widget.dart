import 'package:app_farma_scan_v2/index.dart';
import 'package:app_farma_scan_v2/services/api_service.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'login_page_model.dart';
export 'login_page_model.dart';

class LoginPageWidget extends StatefulWidget {
  const LoginPageWidget({Key? key}) : super(key: key);

  @override
  _LoginPageWidgetState createState() => _LoginPageWidgetState();
}

class _LoginPageWidgetState extends State<LoginPageWidget> {
  late LoginPageModel _model;
  late SharedPreferences prefs;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  final apiService = ApiService();
  bool _isLoading = false;

  final _focusNode1 = FocusNode();
  final _focusNode2 = FocusNode();
  final _focusNode3 = FocusNode();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LoginPageModel());

    _model.textController1 ??= TextEditingController();
    _model.textController2 ??= TextEditingController();
    _model.textController3 ??= TextEditingController();
  }

  @override
  void dispose() {
    _model.dispose();
    _focusNode1.dispose();
    _focusNode2.dispose();
    _focusNode3.dispose();
    super.dispose();
  }

  void _loginUser() async {
    prefs = await SharedPreferences.getInstance();
    String ipPharma = _model.textController1.text.trim();
    String username = _model.textController2.text.trim();
    String password = _model.textController3.text.trim();

    try {
      setState(() {
        _isLoading = true;
      });

      if (ipPharma == 'test' && username == 'google' && password == '1234') {
        prefs.setString('ipPharma', ipPharma);
        prefs.setString(
            'nombre', capitalizeFirstLetter('google'));
        prefs.setString('cedula', '1234567890');

        prefs.setString('farmacia', 'Farmacia Prueba');

        prefs.setString('idbodega', '190');

        prefs.setString('sucursal', '001');

        prefs.setString('compania', '001');

        prefs.setString('centroCosto', '190');

        prefs.setString('nombreCorto', 'google');
      } else {
        final userData =
            await apiService.loginUser(ipPharma, username, password);
        prefs.setString('ipPharma', ipPharma);
        prefs.setString(
            'nombre', capitalizeFirstLetter(userData.mensaje.nombre));
        prefs.setString('cedula', userData.mensaje.cedula);

        prefs.setString('farmacia', userData.mensaje.farmacia);

        prefs.setString('idbodega', userData.mensaje.idbodega);

        prefs.setString('sucursal', userData.mensaje.sucursal);

        prefs.setString('compania', userData.mensaje.compania);

        prefs.setString('centroCosto', userData.mensaje.centroCosto);

        prefs.setString('nombreCorto', userData.mensaje.nombreCorto);
      }

      Navigator.push(context,
          MaterialPageRoute(builder: (context) => DashboardPageWidget()));

      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });

      QuickAlert.show(
        barrierDismissible: false,
        context: context,
        type: QuickAlertType.info,
        title: 'Atención',
        text: error.toString().replaceAll('Exception: ', ''),
        confirmBtnText: 'Aceptar',
        confirmBtnColor: Color.fromARGB(255, 255, 201, 70),
      );
    }
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

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        // Evitar que el botón de retroceso de la barra de navegación funcione
        return false;
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(_model.unfocusNode),
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
          body: SafeArea(
            top: true,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    height: 140.0,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(16.0),
                        bottomRight: Radius.circular(16.0),
                        topLeft: Radius.circular(0.0),
                        topRight: Radius.circular(0.0),
                      ),
                    ),
                    alignment: AlignmentDirectional(-1.0, 0.0),
                    child: Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(25.0, 25.0, 25.0, 0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.asset(
                          'assets/images/logo-farmaenlace.png',
                          width: MediaQuery.sizeOf(context).width * 1.0,
                          height: MediaQuery.sizeOf(context).height * 1.0,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional(0.0, 0.0),
                    child: Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(32.0, 5, 32.0, 32.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hola, te damos la bienvenida',
                            style: FlutterFlowTheme.of(context).displaySmall,
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 12.0, 0.0, 24.0),
                            child: Text(
                              'Ingresa tus credenciales para comenzar a digitalizar...',
                              style: FlutterFlowTheme.of(context).labelMedium,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 16.0),
                            child: TextFormField(
                              controller: _model.textController1,
                              focusNode: _focusNode1,
                              onEditingComplete: () {
                                FocusScope.of(context)
                                    .requestFocus(_focusNode2);
                              },
                              obscureText: false,
                              decoration: InputDecoration(
                                labelText: 'IP Farmacia',
                                labelStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'Readex Pro',
                                      color: Colors.blueGrey.shade300,
                                    ),
                                hintStyle:
                                    FlutterFlowTheme.of(context).bodyLarge,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.blueGrey.shade300,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color.fromARGB(255, 150, 220, 50),
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.red,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.orange,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                              ),
                              style: FlutterFlowTheme.of(context).bodyMedium,
                              validator: _model.textController1Validator
                                  .asValidator(context),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 16.0),
                            child: TextFormField(
                              controller: _model.textController2,
                              focusNode: _focusNode2,
                              onEditingComplete: () {
                                FocusScope.of(context)
                                    .requestFocus(_focusNode3);
                              },
                              obscureText: false,
                              decoration: InputDecoration(
                                labelText: 'Usuario',
                                labelStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'Readex Pro',
                                      color: Colors.blueGrey.shade300,
                                    ),
                                hintStyle:
                                    FlutterFlowTheme.of(context).bodyLarge,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.blueGrey.shade300,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color.fromARGB(255, 150, 220, 50),
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.red,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.orange,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                              ),
                              style: FlutterFlowTheme.of(context).bodyMedium,
                              validator: _model.textController2Validator
                                  .asValidator(context),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 16.0),
                            child: TextFormField(
                              controller: _model.textController3,
                              focusNode: _focusNode3,
                              onEditingComplete: () {
                                _loginUser();
                                FocusScope.of(context).unfocus();
                              },
                              obscureText: !_model.passwordVisibility,
                              decoration: InputDecoration(
                                labelText: 'Contraseña',
                                labelStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'Readex Pro',
                                      color: Colors.blueGrey.shade300,
                                    ),
                                hintStyle:
                                    FlutterFlowTheme.of(context).bodyLarge,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.blueGrey.shade300,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color.fromARGB(255, 150, 220, 50),
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.red,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.orange,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                suffixIcon: InkWell(
                                  onTap: () => setState(
                                    () => _model.passwordVisibility =
                                        !_model.passwordVisibility,
                                  ),
                                  child: Icon(
                                    _model.passwordVisibility
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: Color.fromARGB(255, 150, 220, 50),
                                    size: 22,
                                  ),
                                ),
                              ),
                              style: FlutterFlowTheme.of(context).bodyMedium,
                              validator: _model.textController3Validator
                                  .asValidator(context),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 16.0),
                                    child: _isLoading
                                        ? LoadingAnimationWidget.stretchedDots(
                                            color: Color.fromARGB(
                                                255, 150, 220, 50),
                                            size: 50,
                                          )
                                        : FFButtonWidget(
                                            onPressed: () {
                                              _loginUser();
                                            },
                                            text: 'Iniciar Sesión',
                                            options: FFButtonOptions(
                                              width: 200.0,
                                              height: 50.0,
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(0.0, 0.0, 0.0, 0.0),
                                              iconPadding: EdgeInsetsDirectional
                                                  .fromSTEB(0.0, 0.0, 0.0, 0.0),
                                              color: Color.fromARGB(
                                                  255, 150, 220, 50),
                                              textStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .titleSmall
                                                      .override(
                                                        fontFamily:
                                                            'Readex Pro',
                                                        color: Colors.white,
                                                      ),
                                              elevation: 3.0,
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                            ),
                                          ),
                                  ),
                                  Padding(
                                      padding: EdgeInsets.all(20.0),
                                      child: Image.asset(
                                        'assets/images/farmascan.jpg',
                                        fit: BoxFit.cover,
                                        width: 125,
                                      )),
                                  Text(
                                    'v2.0.1',
                                    textAlign: TextAlign.start,
                                    style:
                                        FlutterFlowTheme.of(context).bodyMedium,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
