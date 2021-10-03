import 'dart:io';

import 'package:universal_platform/universal_platform.dart';

class Sistema {
  static const String ID_CLIENTE = '100050';
  static String idUuid = '100050-GV@TXP5S&CI3RC020EWWTQYT7-2-1000001/JP';
  static const String AUTH_CLIENTE = '/LKHJGASLJKHG/97647/LKHGJH/LKGJLH';
  static const String MENSAJE_INTERNET =
      'Tu conexión a internet no es buena por favor intenta de nuevo más tarde.';
  static const int TARGET_WIDTH_PERFIL = 400;
  static const int TARGET_WIDTH_ARCHIVO = 1200;

  //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  static bool isTestMode = false;

  //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

  static const aplicativoCuriosity = 'CHECK';
  static const idAplicativoCuriosity = 1000001;
  static const aplicativoTitleCuriosity = 'Check';

  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

  static const _aplicativo = aplicativoCuriosity;
  static const _idAplicativo = idAplicativoCuriosity;
  static const aplicativoTitle = aplicativoTitleCuriosity;

  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

  static String get aplicativo => _aplicativo;

  static int get idAplicativo => _idAplicativo;

  static get storage => 'https://firebasestorage.googleapis.com/v0/b/';

  static get isAndroid => UniversalPlatform.isAndroid;

  static get isIOS => UniversalPlatform.isIOS;

  static get isWeb => UniversalPlatform.isWeb;

  String operatingSystem() {
    return (Sistema.isAndroid
            ? Platform.operatingSystem
            : Sistema.isIOS
                ? Platform.operatingSystem
                : 'WEB')
        .toString();
  }
}
