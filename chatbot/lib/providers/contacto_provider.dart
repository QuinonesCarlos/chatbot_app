import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/contacto_model.dart';
import '../preference/shared_preferences.dart';
import '../utils/utils.dart' as utils;

class ContactoProvider {
  final PreferenciasUsuario prefs = PreferenciasUsuario();

  final String _urlListar = 'contacto/listar';
  final String _urlRegistrar = 'contacto/registrar';
  final String _urlEliminar = 'contacto/eliminar';

  Future<bool> registrar(ContactoModel contactoModel) async {
    final resp = await http.post(Uri.parse(prefs.dominio + _urlRegistrar),
        headers: utils.headers,
        body: {
          'idCliente': prefs.idCliente,
          'nombre': contactoModel.nombre.toString(),
          'celular': contactoModel.celular.toString(),
          'etiqueta': contactoModel.etiqueta.toString(),
          'auth': prefs.auth,
        });
    Map<String, dynamic> decodedResp = json.decode(resp.body);
    if (decodedResp['estado'] == 1) {
      return true;
    }
    return false;
  }

  Future<bool> eliminar(ContactoModel contactoModel) async {
    final resp = await http.post(Uri.parse(prefs.dominio + _urlEliminar),
        headers: utils.headers,
        body: {
          'idCliente': prefs.idCliente,
          'celular': contactoModel.celular.toString(),
          'auth': prefs.auth,
        });
    Map<String, dynamic> decodedResp = json.decode(resp.body);
    if (decodedResp['estado'] == 1) {
      return true;
    }
    return false;
  }

  bool _cargando = false;

  listar(bool isClean, int pagina, String criterio, Function response) async {
    var client = http.Client();
    List<ContactoModel> contactosResponse = [];
    int total = 0;
    if (isClean || pagina == 0) {
      _cargando = false;
    }
    if (_cargando) return [];
    _cargando = true;
    try {
      final resp = await client.post(Uri.parse(prefs.dominio + _urlListar),
          headers: utils.headers,
          body: {
            'idCliente': prefs.idCliente,
            'auth': prefs.auth,
            'pagina': pagina.toString(),
            'criterio': criterio
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) {
        total = int.parse(decodedResp['total'].toString());
        for (var item in decodedResp['contactos']) {
          contactosResponse.add(ContactoModel.fromJson(item));
        }
      }
    } catch (err) {
      print('contactos_provider error: $err');
    } finally {
      client.close();
      _cargando = false;
    }
    if (contactosResponse.length <= 0) _cargando = true;
    return response(contactosResponse, total);
  }
}
