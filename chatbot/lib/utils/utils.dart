import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:platform_info/platform_info.dart';

import '../preference/shared_preferences.dart';
import '../sistema.dart';
import '../utils/global.dart';
import '../utils/personalizacion.dart' as prs;

final PreferenciasUsuario prefs = PreferenciasUsuario();

late String marca = '';
late String modelo = '';
late String so = '';
late String imei = '';
late String iPD = '';
late String pysics = '';

String clean(String cadena) {
  return cadena
      .toString()
      .replaceAll('’', '')
      .replaceAll('\'', '')
      .replaceAll('\"', '')
      .replaceAll(new RegExp(r"[^\s\w]"), '');
}

get headers => {
      "idaplicativo": '${Sistema.idAplicativo}',
      "vs": "0.0.112",
      "idplataforma": Sistema.isAndroid
          ? '1'
          : Sistema.isIOS
              ? '2'
              : '3',
      "system": Sistema().operatingSystem(),
      "marca": clean(marca),
      "modelo": clean(modelo),
      "so": clean(so),
      "iph": clean(iPD),
      "red": GLOBAL.connectivityResult,
      "referencia": "12.03.91",
      "imei": clean(imei),
      "key": clean(pysics),
    };

String generateMd5(String input) {
  return md5.convert(utf8.encode(input)).toString();
}

Future<bool> getDeviceDetails({String uuid: ''}) async {
  final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  if (Sistema.isAndroid) {
    var build = await deviceInfoPlugin.androidInfo;
    marca = build.manufacturer;
    modelo = build.display;
    so = build.version.sdkInt.toString();
    iPD = build.isPhysicalDevice.toString();
    if (uuid == '') {
      pysics = generateMd5('${build.androidId}');
      imei = generateMd5('$marca-$pysics-$modelo-${Sistema.idAplicativo}');
    } else {
      pysics = generateMd5('$uuid');
      imei = generateMd5('$marca-$pysics-$modelo-${Sistema.idAplicativo}');
    }
  } else if (Sistema.isIOS) {
    var data = await deviceInfoPlugin.iosInfo;

    marca = data.model;
    modelo = data.name;
    so = data.systemVersion.toString();
    iPD = data.isPhysicalDevice.toString();

    if (uuid == '') {
      pysics = generateMd5('${data.identifierForVendor}');
      imei = generateMd5('$marca-$pysics-$modelo-${Sistema.idAplicativo}');
    } else {
      pysics = generateMd5('$uuid');
      imei = generateMd5('$marca-$pysics-$modelo-${Sistema.idAplicativo}');
    }
  } else if (Sistema.isWeb) {
    final Platform _platform = Platform.instance;
    marca = _platform.version.toLowerCase();
    if (marca.lastIndexOf('opr/') > 0) {
      marca = 'Opera';
    } else if (marca.lastIndexOf('firefox/') > 0) {
      marca = 'Firefox';
    } else if (marca.lastIndexOf('edg/') > 0) {
      marca = 'Microsoft Edge';
    } else if (marca.lastIndexOf('chrome/') > 0) {
      marca = 'Chrome';
    } else {
      marca = 'Desconocido';
    }
    so = 'WEB';
    modelo = marca;
    iPD = 'true';
    pysics = PreferenciasUsuario().uuid;
    print(pysics);
    imei = generateMd5('$marca-$pysics-$modelo-${Sistema.idAplicativo}');
  }
  return true;
}

mostrarSnackBar(BuildContext context, String mensaje,
    {int milliseconds: 5200}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mensaje), duration: Duration(microseconds: milliseconds)));
}

mostrarProgress(BuildContext context, {bool barrierDismissible: false}) {
  showDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) {
      return Center(child: CircularProgressIndicator());
    },
  );
}

Widget progressIndicator(String mensaje) {
  return Container(
    width: 400.0,
    padding: EdgeInsets.all(50.0),
    child: Center(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: Colors.white,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black26,
              offset: Offset(1.0, 1.0),
            ),
          ],
        ),
        height: 70.0,
        child: Row(
          children: <Widget>[
            SizedBox(width: 20.0),
            CircularProgressIndicator(),
            SizedBox(width: 25.0),
            Text(mensaje),
          ],
        ),
      ),
    ),
  );
}

Widget crearCelular(String simCountryCode, Function onInputChanged,
    {String celular: ''}) {
  return InternationalPhoneNumberInput(
    onInputChanged: (PhoneNumber phoneNumber) {
      prefs.simCountryCode = phoneNumber.isoCode;
      onInputChanged(phoneNumber.toString());
    },
    validator: (value) {
      if (value!.trim().length < 8) return 'Mínimo 8 caracteres';
      return null;
    },
    inputDecoration: prs.decoration('Celular', null),
    keyboardType: TextInputType.phone,
    ignoreBlank: true,
    autoValidateMode: AutovalidateMode.disabled,
    formatInput: false,
    selectorConfig: SelectorConfig(selectorType: PhoneInputSelectorType.DIALOG),
    errorMessage: 'Celular incorrecto',
    initialValue: PhoneNumber(isoCode: simCountryCode, phoneNumber: celular),
  );
}

Widget estrellas(double initialRating, Function onRatingChanged,
    {double size: 45.0}) {
  return Center(
      child: RatingBar.builder(
    initialRating: initialRating,
    minRating: 1,
    direction: Axis.horizontal,
    allowHalfRating: true,
    itemCount: 5,
    itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
    itemBuilder: (context, _) => Icon(
      Icons.star,
      color: Colors.amber,
    ),
    onRatingUpdate: onRatingChanged as void Function(double),
  ));
}
