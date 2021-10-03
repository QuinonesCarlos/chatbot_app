import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/notificacion_model.dart';
import '../preference/shared_preferences.dart';
import '../utils/utils.dart' as utils;

class NotificacionProvider {
  final PreferenciasUsuario prefs = PreferenciasUsuario();

  final String _urlListar = 'notificacion/listar';
  final String _urlMarcar = 'notificacion/marcar';

  Future<List<NotificacionModel>> listar() async {
    var client = http.Client();
    List<NotificacionModel> notificacionesResponse = [];
    try {
      final resp = await client.post(Uri.parse(prefs.dominio + _urlListar),
          headers: utils.headers,
          body: {
            'idCliente': prefs.idCliente,
            'auth': prefs.auth,
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) {
        for (var item in decodedResp['notificaciones']) {
          notificacionesResponse.add(NotificacionModel.fromJson(item));
        }
      }
    } catch (err) {
      print('notificacion_provider error: $err');
    } finally {
      client.close();
    }
    return notificacionesResponse;
  }

  marcar(String idMensaje, int accion) async {
    var client = http.Client();
    try {
      await client.post(Uri.parse(prefs.dominio + _urlMarcar),
          headers: utils.headers,
          body: {
            'idCliente': prefs.idCliente,
            'auth': prefs.auth,
            'idMensaje': idMensaje,
            'accion': accion.toString(),
          });
    } catch (err) {
      print('cliente_provider error: $err');
    } finally {
      client.close();
    }
  }
}
