import 'package:app_farma_scan_v2/index.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dashboard_page_model.dart';
export 'dashboard_page_model.dart';

class DashboardPageWidget extends StatefulWidget {
  const DashboardPageWidget({Key? key}) : super(key: key);

  @override
  _DashboardPageWidgetState createState() => _DashboardPageWidgetState();
}

class _DashboardPageWidgetState extends State<DashboardPageWidget>
    with TickerProviderStateMixin {
  late DashboardPageModel _model;

  late SharedPreferences prefs;

  bool _isLoading = true;

  List<String> imageURLs = [
    'https://www.farmaenlace.com/wp-content/uploads/2022/07/logo-economicas.png',
    'https://www.farmaenlace.com/wp-content/uploads/2022/07/logo-medicity.png',
  ];

  late String nombre = '';
  late String cedula = '';
  late String farmacia = '';
  late String idbodega = '';
  late String sucursal = '';
  late String compania = '';
  late String centroCosto = '';
  late String nombreCorto = '';

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = {
    'containerOnPageLoadAnimation1': AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      effects: [
        FadeEffect(
          curve: Curves.easeInOut,
          delay: 0.ms,
          duration: 600.ms,
          begin: 0.0,
          end: 1.0,
        ),
        MoveEffect(
          curve: Curves.easeInOut,
          delay: 0.ms,
          duration: 600.ms,
          begin: Offset(30.0, 0.0),
          end: Offset(0.0, 0.0),
        ),
      ],
    ),
    'containerOnPageLoadAnimation2': AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      effects: [
        FadeEffect(
          curve: Curves.easeInOut,
          delay: 0.ms,
          duration: 600.ms,
          begin: 0.0,
          end: 1.0,
        ),
        MoveEffect(
          curve: Curves.easeInOut,
          delay: 0.ms,
          duration: 600.ms,
          begin: Offset(50.0, 0.0),
          end: Offset(0.0, 0.0),
        ),
      ],
    ),
  };

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DashboardPageModel());

    setupAnimations(
      animationsMap.values.where((anim) =>
          anim.trigger == AnimationTrigger.onActionTrigger ||
          !anim.applyInitialState),
      this,
    );

    _getUserData();
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  void _getUserData() async {
    prefs = await SharedPreferences.getInstance();
    //Esperar 5 segundos
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      nombre = prefs.getString('nombre')!;
      cedula = prefs.getString('cedula')!;
      farmacia = prefs.getString('farmacia')!;
      idbodega = prefs.getString('idbodega')!;
      sucursal = prefs.getString('sucursal')!;
      compania = prefs.getString('compania')!;
      centroCosto = prefs.getString('centroCosto')!;
      nombreCorto = prefs.getString('nombreCorto')!;
      _isLoading = false;
    });
  }

  Widget buildNameAvatar() {
    final nombre = prefs.getString('nombre')!;
    final nombres = nombre.split(' ');
    final primerNombre = nombres.isNotEmpty ? nombres[0] : '';
    final segundoNombre = nombres.length > 1 ? nombres[1] : '';

    // Toma las primeras letras de ambos nombres
    final iniciales = primerNombre.isNotEmpty
        ? primerNombre[0].toUpperCase() +
            (segundoNombre.isNotEmpty ? segundoNombre[0].toUpperCase() : '')
        : '';

    return Container(
      width: 40.0,
      height: 40.0,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors
            .blue, // Puedes cambiar el color de fondo según tus preferencias
      ),
      alignment: Alignment.center,
      child: Text(
        iniciales,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.0, // Ajusta el tamaño de fuente según tus preferencias
          fontWeight: FontWeight.bold,
        ),
      ),
    );
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
      onWillPop: () async {
        return false;
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(_model.unfocusNode),
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: Color(0xFFF1F5F8),
          drawer: Drawer(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  height: 150, // Establece la altura que desees
                  color: Color(0xFF14181B),
                  alignment: Alignment.center,
                  child: Text(
                    "Menú",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(FontAwesomeIcons.clipboardList),
                  title: Text("Ingreso manual de propiedades"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ManualDocsPageWidget(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(FontAwesomeIcons.barcode),
                  title: Text("Detectar código de barras"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BarcodeDocsPageWidget(),
                      ),
                    );
                  },
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Text('v2.0.0',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontFamily: 'Readex Pro')),
                    ),
                  ),
                ),
              ],
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color(0xFFF1F4F8),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            16.0, 44.0, 16.0, 0.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            FlutterFlowIconButton(
                              borderColor: Colors.transparent,
                              borderRadius: 30.0,
                              borderWidth: 1.0,
                              buttonSize: 44.0,
                              icon: Icon(
                                Icons.menu_rounded,
                                color: Color(0xFF14181B),
                                size: 24.0,
                              ),
                              onPressed: () {
                                scaffoldKey.currentState!.openDrawer();
                              },
                            ),
                            InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () {
                                final RenderBox overlay = Overlay.of(context)
                                    .context
                                    .findRenderObject() as RenderBox;
                                final offset = Offset(40.0, 90.0);
                                final menuPosition =
                                    overlay.localToGlobal(offset);

                                showMenu(
                                  context: context,
                                  position: RelativeRect.fromLTRB(
                                      menuPosition.dx, menuPosition.dy, 0, 0),
                                  items: [
                                    PopupMenuItem(
                                      child: ListTile(
                                        title: Text("Cerrar Sesión"),
                                        onTap: () {
                                          prefs.clear();
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      LoginPageWidget()));
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              },
                              child: Container(
                                width: 40.0,
                                height: 40.0,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors
                                      .blue, // Puedes cambiar el color de fondo según tus preferencias
                                ),
                                alignment: Alignment.center,
                                child: buildNameAvatar(),
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            24.0, 16.0, 16.0, 0.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Hola,',
                              style: FlutterFlowTheme.of(context)
                                  .displaySmall
                                  .override(
                                    fontFamily: 'Outfit',
                                    color: Color(0xFF14181B),
                                    fontSize: 28.0,
                                    fontWeight: FontWeight.normal,
                                  ),
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  2.0, 0.0, 0.0, 0.0),
                              child: Text(
                                nombre,
                                style: FlutterFlowTheme.of(context)
                                    .displaySmall
                                    .override(
                                      fontFamily: 'Outfit',
                                      color: Color(0xFF4B39EF),
                                      fontSize: 28.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            24.0, 0.0, 24.0, 0.0),
                        child: Text(
                          cedula,
                          style:
                              FlutterFlowTheme.of(context).labelMedium.override(
                                    fontFamily: 'Plus Jakarta Sans',
                                    color: Color(0xFF57636C),
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            20.0, 12.0, 20.0, 12.0),
                        child: Container(
                          width: double.infinity,
                          height: 110.0,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 4.0,
                                color: Color(0x34090F13),
                                offset: Offset(0.0, 2.0),
                              )
                            ],
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                12.0, 8.0, 12.0, 8.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 4.0),
                                  child: Text(
                                    nombreCorto,
                                    style: FlutterFlowTheme.of(context)
                                        .labelSmall
                                        .override(
                                          fontFamily: 'Plus Jakarta Sans',
                                          color: Color(0xFF57636C),
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                ),
                                Text(
                                  farmacia,
                                  style: FlutterFlowTheme.of(context)
                                      .titleLarge
                                      .override(
                                        fontFamily: 'Outfit',
                                        color: Color(0xFF14181B),
                                        fontSize: 22.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                                Expanded(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0.0, 4.0, 0.0, 0.0),
                                        child: Text(
                                          centroCosto,
                                          style: FlutterFlowTheme.of(context)
                                              .labelMedium
                                              .override(
                                                fontFamily: 'Plus Jakarta Sans',
                                                color: Color(0xFF57636C),
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0.0, 4.0, 0.0, 0.0),
                                        child: Text(
                                          idbodega,
                                          style: FlutterFlowTheme.of(context)
                                              .headlineLarge
                                              .override(
                                                fontFamily: 'Outfit',
                                                color: Color(0xFF14181B),
                                                fontSize: 32.0,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 0.0, 0.0),
                  child: Text(
                    'Mis Módulos',
                    style: FlutterFlowTheme.of(context).headlineSmall.override(
                          fontFamily: 'Outfit',
                          color: Color(0xFF0F1113),
                          fontSize: 20.0,
                          fontWeight: FontWeight.normal,
                        ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 198.0,
                  decoration: BoxDecoration(
                    color: Color(0xFFF1F5F8),
                  ),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    primary: false,
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ManualDocsPageWidget()),
                          );
                        },
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              16.0, 12.0, 12.0, 12.0),
                          child: Container(
                            width: 230.0,
                            height: 50.0,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 4.0,
                                  color: Color(0x34090F13),
                                  offset: Offset(0.0, 2.0),
                                )
                              ],
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 155.0,
                                  decoration: BoxDecoration(
                                    color:
                                        FlutterFlowTheme.of(context).secondary,
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(0.0),
                                      bottomRight: Radius.circular(0.0),
                                      topLeft: Radius.circular(12.0),
                                      topRight: Radius.circular(12.0),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        12.0, 12.0, 12.0, 12.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 36.0,
                                          height: 36.0,
                                          decoration: BoxDecoration(
                                            color: Color(0x98FFFFFF),
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          alignment:
                                              AlignmentDirectional(0.0, 0.0),
                                          child: Icon(
                                            Icons.edit_note_sharp,
                                            color: FlutterFlowTheme.of(context)
                                                .secondary,
                                            size: 20.0,
                                          ),
                                        ),
                                        Text(
                                          'Registro manual de propiedades',
                                          style: FlutterFlowTheme.of(context)
                                              .titleMedium
                                              .override(
                                                fontFamily: 'Outfit',
                                                color: Colors.white,
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                        Text(
                                          'Varios procesos',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily: 'Plus Jakarta Sans',
                                                color: Colors.white,
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ).animateOnPageLoad(
                              animationsMap['containerOnPageLoadAnimation1']!),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BarcodeDocsPageWidget()),
                          );
                        },
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 12.0, 16.0, 12.0),
                          child: Container(
                            width: 230.0,
                            height: 50.0,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 4.0,
                                  color: Color(0x34090F13),
                                  offset: Offset(0.0, 2.0),
                                )
                              ],
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 155.0,
                                  decoration: BoxDecoration(
                                    color:
                                        FlutterFlowTheme.of(context).tertiary,
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(0.0),
                                      bottomRight: Radius.circular(0.0),
                                      topLeft: Radius.circular(12.0),
                                      topRight: Radius.circular(12.0),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        12.0, 12.0, 12.0, 12.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 36.0,
                                          height: 36.0,
                                          decoration: BoxDecoration(
                                            color: Color(0x98FFFFFF),
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          alignment:
                                              AlignmentDirectional(0.0, 0.0),
                                          child: FaIcon(
                                            FontAwesomeIcons.barcode,
                                            color: FlutterFlowTheme.of(context)
                                                .primaryText,
                                            size: 20.0,
                                          ),
                                        ),
                                        Text(
                                          'Escaner de código de barras',
                                          style: FlutterFlowTheme.of(context)
                                              .titleMedium
                                              .override(
                                                fontFamily: 'Outfit',
                                                color: Colors.white,
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                        Text(
                                          'Cupones, Convenios, Salidas de caja',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily: 'Plus Jakarta Sans',
                                                color: Colors.white,
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ).animateOnPageLoad(
                              animationsMap['containerOnPageLoadAnimation2']!),
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 0.0, 0.0),
                  child: Text(
                    'Noticias importantes',
                    style: FlutterFlowTheme.of(context).headlineSmall.override(
                          fontFamily: 'Outfit',
                          color: Color(0xFF0F1113),
                          fontSize: 20.0,
                          fontWeight: FontWeight.normal,
                        ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 0.0, 0.0),
                  child: Container(
                    height: 100, // Establece la altura del contenedor
                    child: ListView.builder(
                      scrollDirection: Axis
                          .horizontal, // Permite el desplazamiento horizontal
                      itemCount: imageURLs
                          .length, // Reemplaza esto con la cantidad de imágenes que tengas
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                                25.0), // Ajusta el radio según tu preferencia
                          ),
                          padding: EdgeInsets.all(5),
                          width: 200,
                          margin: EdgeInsets.only(right: 15),
                          child: Image.network(
                            imageURLs[index],
                            width: 160,
                            height: 80,
                            fit: BoxFit.contain,
                          ),
                        );
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
