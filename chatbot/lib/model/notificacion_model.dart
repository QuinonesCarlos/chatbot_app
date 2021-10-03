import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/cache.dart' as cache;

class NotificacionModel {
  String idMensaje;
  String hint;
  String detalle;
  String img;
  String omitir;
  String boton;
  String datos;

  NotificacionModel({
    this.idMensaje: '0',
    this.hint: '',
    this.detalle: '',
    this.img: '',
    this.boton: '',
    this.omitir: '',
    this.datos: '',
  });

  factory NotificacionModel.fromJson(Map<String, dynamic> json) =>
      NotificacionModel(
        idMensaje: json["id_mensaje"] == null ? '0' : '${json["id_mensaje"]}',
        omitir: json["omitir"] == null ? 'OMITIR' : json["omitir"],
        boton: json["boton"] == null ? 'ACEPTAR' : json["boton"],
        hint: json["hint"] == null ? '' : json["hint"],
        detalle: json["detalle"] == null ? '' : json["detalle"],
        img: json["img"] == null ? '' : cache.img(json["img"]),
        datos: json["datos"] == null ? '' : json["datos"],
      );

  accion(BuildContext context) async {
    Map<String, dynamic>? decodedResp = jsonDecode(datos);
    if (decodedResp == null) {
      return;
    } else if (decodedResp['tipo'].toString() == '1') {
      Navigator.pop(context);
      _launchURL(decodedResp['url'].toString());
    } else {
      Navigator.pop(context);
      return;
    }
  }

  _launchURL(String url) async {
    var encoded = Uri.encodeFull(url);
    if (await canLaunch(encoded)) {
      await launch(encoded);
    } else {
      print('Could not open the url.');
    }
  }
}
