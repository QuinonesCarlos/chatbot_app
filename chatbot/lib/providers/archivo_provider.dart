import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:dio/dio.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime_type/mime_type.dart';

import '../model/archivo_model.dart';
import '../preference/shared_preferences.dart';
import '../sistema.dart';
import '../utils/utils.dart' as utils;

class ArchivoProvider {
  final PreferenciasUsuario prefs = PreferenciasUsuario();

  final String _urlListar = 'archivo/listar';
  final String _urlSubirImagen = 'archivo/subir';
  final String _urlEditar = 'archivo/editar';
  final String _urlEliminar = 'archivo/eliminar';
  final String _urlOrnernar = 'archivo/ordenar';

  Future<bool> editar(ArchivoModel archivoModel) async {
    final resp = await http.post(Uri.parse(prefs.dominio + _urlEditar),
        headers: utils.headers,
        body: {
          'idCliente': prefs.idCliente,
          'idArchivo': archivoModel.idArchivo.toString(),
          'detalle': archivoModel.detalle.toString(),
          'auth': prefs.auth,
        });
    Map<String, dynamic> decodedResp = json.decode(resp.body);
    if (decodedResp['estado'] == 1) {
      return true;
    }
    return false;
  }

  Future<bool> subirWeb(
      List<int> value, dynamic nombreImagen, String detalle) async {
    try {
      FormData formData = FormData.fromMap({
        "archivo": MultipartFile.fromBytes(value, filename: nombreImagen),
      });
      var headers = utils.headers;
      headers['archivo'] = nombreImagen.toString();
      headers['idcliente'] = prefs.idCliente.toString();
      headers['detalle'] = detalle.toString();
      headers['type'] = 'jpg';
      await Dio().post(
        prefs.dominio + _urlSubirImagen,
        data: formData,
        options: Options(headers: headers),
      );
      return false;
    } catch (err) {
      print('promocion_provider error: $err');
    }
    return false;
  }

  Future<bool> subirMovil(
      io.File imagen, dynamic nombreImagen, String detalle) async {
    ImageProperties properties =
        await FlutterNativeImage.getImageProperties(imagen.path);
    io.File compressedFile = await FlutterNativeImage.compressImage(imagen.path,
        targetWidth: Sistema.TARGET_WIDTH_ARCHIVO,
        targetHeight: (properties.height! *
                Sistema.TARGET_WIDTH_ARCHIVO /
                properties.width!)
            .round());
    try {
      final mimeType = mime(compressedFile.path)!.split('/'); //image/jpeg
      FormData formData = new FormData.fromMap({
        "archivo": await MultipartFile.fromFile(compressedFile.path,
            contentType: MediaType(mimeType[0], mimeType[1]))
      });
      var headers = utils.headers;
      headers['archivo'] = nombreImagen.toString();
      headers['idcliente'] = prefs.idCliente.toString();
      headers['detalle'] = detalle.toString();
      headers['type'] = mimeType[1].toString();
      await Dio().post(
        prefs.dominio + _urlSubirImagen,
        data: formData,
        options: Options(headers: headers),
      );
      return false;
    } catch (err) {
      print('archivo_provider error: $err');
    }
    return false;
  }

  Future<bool> ordenar(String ids) async {
    var client = http.Client();
    try {
      final resp = await client.post(Uri.parse(prefs.dominio + _urlOrnernar),
          headers: utils.headers,
          body: {
            'idCliente': prefs.idCliente,
            'auth': prefs.auth,
            'ids': ids.toString(),
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) return true;
    } catch (err) {
      print('archivo_provider error: $err');
    } finally {
      client.close();
    }
    return false;
  }

  Future<bool> eliminar(ArchivoModel archivoModel) async {
    final resp = await http.post(Uri.parse(prefs.dominio + _urlEliminar),
        headers: utils.headers,
        body: {
          'idCliente': prefs.idCliente,
          'idArchivo': archivoModel.idArchivo.toString(),
          'auth': prefs.auth,
        });
    Map<String, dynamic> decodedResp = json.decode(resp.body);
    if (decodedResp['estado'] == 1) {
      return true;
    }
    return false;
  }

  Future<List<ArchivoModel>> listar() async {
    var client = http.Client();
    List<ArchivoModel> archivoesResponse = [];
    try {
      final resp = await client.post(Uri.parse(prefs.dominio + _urlListar),
          headers: utils.headers,
          body: {
            'idCliente': prefs.idCliente,
            'auth': prefs.auth,
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) {
        for (var item in decodedResp['archivoes']) {
          archivoesResponse.add(ArchivoModel.fromJson(item));
        }
      }
    } catch (err) {
      print('archivo_provider error: $err');
    } finally {
      client.close();
    }
    return archivoesResponse;
  }
}
