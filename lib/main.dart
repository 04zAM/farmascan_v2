import 'package:app_farma_scan_v2/index.dart';
import 'package:app_farma_scan_v2/pages/logout_page/logout_page_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'flutter_flow/flutter_flow_theme.dart';
import 'flutter_flow/internationalization.dart';
import 'package:shared_preferences/shared_preferences.dart';


bool _isLoggedin = false;

void main() async {
  WidgetsBinding instance = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(
    widgetsBinding: instance,
  );
  usePathUrlStrategy();
  await FlutterFlowTheme.initialize();
  verifySharedPreferences();

  runApp(MyApp());
}

void verifySharedPreferences() async {
  final prefs = await SharedPreferences.getInstance();
  if(prefs.getKeys().isNotEmpty){
    _isLoggedin = true;
  }
  FlutterNativeSplash.remove();
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;
  ThemeMode _themeMode = FlutterFlowTheme.themeMode;

  @override
  void initState() {
    super.initState();
  }

  void setLocale(String language) {
    setState(() => _locale = createLocale(language));
  }

  void setThemeMode(ThemeMode mode) => setState(() {
        _themeMode = mode;
        FlutterFlowTheme.saveThemeMode(mode);
      });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FarmaScan',
      localizationsDelegates: [
        FFLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: _locale,
      supportedLocales: const [
        Locale('es'),
      ],
      themeMode: _themeMode,
      routes: {
        '/': (context) => LoginPageWidget(),
        '/dashboard': (context) => DashboardPageWidget(),
        '/logout': (context) => LogoutPageWidget(),
      },
      initialRoute: _isLoggedin ? '/dashboard' : '/',
    );
  }
}
