import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/etiqueta_model.dart';
import '../preference/shared_preferences.dart';
import '../utils/utils.dart' as utils;

class EtiquetaProvider {
  final PreferenciasUsuario prefs = PreferenciasUsuario();

  final String _urlListar = 'etiqueta/listar';
  final String _urlRegistrar = 'etiqueta/registrar';
  final String _urlEliminar = 'etiqueta/eliminar';

  Future<bool> registrar(EtiquetaModel etiquetaModel) async {
    final resp = await http.post(Uri.parse(prefs.dominio + _urlRegistrar),
        headers: utils.headers,
        body: {
          'idCliente': prefs.idCliente,
          'etiqueta': etiquetaModel.etiqueta.toString(),
          'auth': prefs.auth,
        });
    Map<String, dynamic> decodedResp = json.decode(resp.body);
    if (decodedResp['estado'] == 1) {
      return true;
    }
    return false;
  }

  Future<bool> eliminar(EtiquetaModel etiquetaModel) async {
    final resp = await http.post(Uri.parse(prefs.dominio + _urlEliminar),
        headers: utils.headers,
        body: {
          'idCliente': prefs.idCliente,
          'etiqueta': etiquetaModel.etiqueta.toString(),
          'auth': prefs.auth,
        });
    Map<String, dynamic> decodedResp = json.decode(resp.body);
    if (decodedResp['estado'] == 1) {
      return true;
    }
    return false;
  }

  Future<List<EtiquetaModel>> listar() async {
    var client = http.Client();
    List<EtiquetaModel> etiquetasResponse = [];
    try {
      final resp = await client.post(Uri.parse(prefs.dominio + _urlListar),
          headers: utils.headers,
          body: {
            'idCliente': prefs.idCliente,
            'auth': prefs.auth,
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) {
        for (var item in decodedResp['etiquetas']) {
          etiquetasResponse.add(EtiquetaModel.fromJson(item));
        }
      }
    } catch (err) {
      print('etiquetas_provider error: $err');
    } finally {
      client.close();
    }
    return etiquetasResponse;
  }
}
