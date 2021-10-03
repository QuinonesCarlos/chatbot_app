import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/cliente_model.dart';
import '../preference/shared_preferences.dart';
import '../sistema.dart';
import '../utils/utils.dart' as utils;

class RegistroProvider {
  final PreferenciasUsuario prefs = PreferenciasUsuario();
  final String _urlRegistrar = 'registro/registrar';

  registrar(ClienteModel clienteModel, String codigoPais, String smn,
      Function response) async {
    await utils.getDeviceDetails();
    try {
      final resp = await http.post(Uri.parse(prefs.dominio + _urlRegistrar),
          headers: utils.headers,
          body: {
            'celular': clienteModel.celular.toString(),
            'correo': clienteModel.correo.toString(),
            'clave': clienteModel.clave.toString(),
            'nombres': clienteModel.nombres.toString(),
            'apellidos': clienteModel.apellidos.toString(),
            'cedula': clienteModel.cedula.toString(),
            'celularValidado': clienteModel.celularValidado.toString(),
            'correoValidado': clienteModel.correoValidado.toString(),
            'simCountryCode': prefs.simCountryCode,
            'codigoPais': codigoPais,
            'token': prefs.token,
            'smn': smn.toString(),
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) {
        prefs.auth = decodedResp['auth'];
        clienteModel = ClienteModel.fromJson(decodedResp['cliente']);
        prefs.idCliente = clienteModel.idCliente.toString();
        prefs.clienteModel = clienteModel;
        return response(1, clienteModel);
      }
      return response(0, decodedResp['error']);
    } catch (err) {
      print('regitro_provider error: $err');
      return response(0, Sistema.MENSAJE_INTERNET);
    }
  }
}
