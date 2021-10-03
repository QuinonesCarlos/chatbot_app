import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/session_model.dart';
import '../preference/shared_preferences.dart';
import '../sistema.dart';
import '../utils/utils.dart' as utils;

class SessionProvider {
  final PreferenciasUsuario prefs = PreferenciasUsuario();

  final String _urlCerrar = 'session/cerrar';
  final String _urlSessiones = 'session/listar';

  Future cerrar(Function response,
      {dynamic idPlataforma, dynamic imei, bool all: false}) async {
    var client = http.Client();
    try {
      final resp = await client.post(Uri.parse(prefs.dominio + _urlCerrar),
          headers: utils.headers,
          body: {
            'idCliente': prefs.idCliente,
            'auth': prefs.auth,
            'idPlataforma': idPlataforma.toString(),
            'imei': imei.toString(),
            'all': all ? '1' : '0',
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) return response(1, decodedResp['error']);
      return response(0, decodedResp['error']);
    } catch (err) {
      print('cliente_provider error: $err');
    } finally {
      client.close();
    }
    return response(0, Sistema.MENSAJE_INTERNET);
  }

  Future<List<SessionModel>> listar() async {
    var client = http.Client();
    List<SessionModel> sessionesResponse = [];
    try {
      final resp = await client.post(Uri.parse(prefs.dominio + _urlSessiones),
          headers: utils.headers,
          body: {
            'idCliente': prefs.idCliente,
            'auth': prefs.auth,
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);

      if (decodedResp['estado'] == 1) {
        for (var item in decodedResp['sessiones']) {
          sessionesResponse.add(SessionModel.fromJson(item));
        }
      }
    } catch (err) {
      print('cliente_provider error: $err');
    } finally {
      client.close();
    }
    return sessionesResponse;
  }
}
