import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_sim_country_code/flutter_sim_country_code.dart';

import './sistema.dart';
import './utils/permisos.dart' as permisos;
import './utils/personalizacion.dart' as prs;
import './utils/utils.dart' as utils;
import 'pages/planck/about_page.dart';
import 'pages/planck/archivos_page.dart';
import 'pages/planck/catalogo_page.dart';
import 'pages/planck/contacto_page.dart';
import 'pages/planck/contrasenia_page.dart';
import 'pages/planck/notificacion_page.dart';
import 'pages/planck/perfil_page.dart';
import 'pages/planck/registrar_page.dart';
import 'pages/planck/sessiones_page.dart';
import 'preference/push_provider.dart';
import 'preference/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await PreferenciasUsuario().init();
  final prefs = PreferenciasUsuario();
  await utils.getDeviceDetails();
  PushProvider();
  if (prefs.idCliente == '' || prefs.idCliente == Sistema.ID_CLIENTE) {
    await permisos.ingresar();
  }
  try {
    prefs.simCountryCode = await FlutterSimCountryCode.simCountryCode;
  } catch (exception) {
    print('page: main.dart catch $exception');
    prefs.simCountryCode = 'EC';
  }
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final prefs = PreferenciasUsuario();

  @override
  Widget build(BuildContext context) {
    String ruta = '';
    if (prefs.auth == '') {
      ruta = 'principal';
    } else {
      ruta = 'catalogo';
    }
    print(prefs.dominio);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: prs.colorAppBar,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    return MaterialApp(
      title: Sistema.aplicativoTitle,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [const Locale('es', 'ES')],
      locale: Locale('es', 'ES'),
      initialRoute: ruta,
      debugShowCheckedModeBanner: Sistema.isTestMode,
      routes: {
        '': (BuildContext context) => CatalogoPage(),
        'catalogo': (BuildContext context) => CatalogoPage(),
        'principal': (BuildContext context) => RegistrarPage(),
        'registrar': (BuildContext context) => RegistrarPage(),
        'contrasenia': (BuildContext context) => ContraseniaPage(),
        'perfil': (BuildContext context) => PerfilPage(),
        'contacto': (BuildContext context) => ContactoPage(),
        'archivos': (BuildContext context) => ArchivosPage(),
        'sessiones': (BuildContext context) => SessionesPage(),
        'about': (BuildContext context) => AboutPage(),
        'notificacion': (BuildContext context) => NotificacionPage(),
      },
      theme: ThemeData(
          primaryColor: prs.colorAppBar,
          appBarTheme: AppBarTheme(
              elevation: 0.7, centerTitle: true, color: prs.colorAppBar)),
    );
  }
}
