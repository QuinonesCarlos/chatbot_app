import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/whatsapp_model.dart';
import '../preference/shared_preferences.dart';
import '../sistema.dart';
import '../utils/utils.dart' as utils;

class WhatsappProvider {
  final PreferenciasUsuario prefs = PreferenciasUsuario();

  final String _urlListar = 'whatsapp/listar';
  final String _urlEliminar = 'whatsapp/eliminar';
  final String _urlProbar = 'whatsapp/probar';
  final String _urlEnviar = 'whatsapp/enviar';
  final String _urlLink = 'whatsapp/link';
  final String _urlVerificar = 'whatsapp/verificar';

  link(String whatsapp, Function respuesta) async {
    var client = http.Client();

    try {
      final resp = await client.post(Uri.parse(prefs.dominio + _urlLink),
          headers: utils.headers,
          body: {
            'idCliente': prefs.idCliente,
            'auth': prefs.auth,
            'whatsapp': whatsapp
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) {
        return respuesta(1, '');
      }
      return respuesta(0, decodedResp['error']);
    } catch (err) {
      print('whatsapp_provider error: $err');
    } finally {
      client.close();
    }
    return respuesta(0, Sistema.MENSAJE_INTERNET);
  }

  Future<int> verificar(String etiqueta) async {
    var client = http.Client();
    int total = 0;
    try {
      final resp = await client.post(Uri.parse(prefs.dominio + _urlVerificar),
          headers: utils.headers,
          body: {
            'idCliente': prefs.idCliente,
            'auth': prefs.auth,
            'etiqueta': etiqueta
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) {
        total = int.parse(decodedResp['total'].toString());
      }
    } catch (err) {
      print('whatsapp_provider error: $err');
    } finally {
      client.close();
    }
    return total;
  }

  enviar(dynamic aEnviar, String? alias, String whatsapp, String etiquetas,
      String? campania, String? archivo) async {
    var client = http.Client();
    try {
      await client.post(Uri.parse(prefs.dominio + _urlEnviar),
          headers: utils.headers,
          body: {
            'idCliente': prefs.idCliente,
            'etiquetas': etiquetas,
            'campania': campania,
            'whatsapp': whatsapp,
            'alias': alias,
            'archivo': archivo,
            'aEnviar': aEnviar.toString(),
            'auth': prefs.auth,
          });
    } catch (err) {
      print('whatsapp_provider error: $err');
    } finally {
      client.close();
    }
  }

  probar(String whatsapp, String celular, String? mensaje, String? archivo,
      Function response) async {
    var client = http.Client();
    try {
      final resp = await client.post(Uri.parse(prefs.dominio + _urlProbar),
          headers: utils.headers,
          body: {
            'idCliente': prefs.idCliente,
            'whatsapp': whatsapp,
            'celular': celular,
            'mensaje': mensaje,
            'archivo': archivo,
            'auth': prefs.auth,
          });

      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) return response(1, decodedResp['error']);
      return response(0, decodedResp['error']);
    } catch (err) {
      print('whatsapp_provider error: $err');
    } finally {
      client.close();
    }
    return response(0, Sistema.MENSAJE_INTERNET);
  }

  Future<bool> eliminar(WhatsappModel whatsappModel) async {
    final resp = await http.post(Uri.parse(prefs.dominio + _urlEliminar),
        headers: utils.headers,
        body: {
          'idCliente': prefs.idCliente,
          'celular': whatsappModel.celular.toString(),
          'auth': prefs.auth,
        });
    Map<String, dynamic> decodedResp = json.decode(resp.body);
    if (decodedResp['estado'] == 1) {
      return true;
    }
    return false;
  }

  Future<List<WhatsappModel>> listar(String fecha) async {
    var client = http.Client();
    List<WhatsappModel> whatsappesResponse = [];
    try {
      final resp = await client.post(Uri.parse(prefs.dominio + _urlListar),
          headers: utils.headers,
          body: {
            'idCliente': prefs.idCliente,
            'auth': prefs.auth,
            'fecha': fecha,
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) {
        for (var item in decodedResp['whatsapps']) {
          whatsappesResponse.add(WhatsappModel.fromJson(item));
        }
      }
    } catch (err) {
      print('whatsapp_provider error: $err');
    } finally {
      client.close();
    }
    return whatsappesResponse;
  }
}
