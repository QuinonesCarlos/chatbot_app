import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../model/cliente_model.dart';
import '../model/notificacion_model.dart';
import '../preference/push_provider.dart';
import '../preference/shared_preferences.dart';
import '../sistema.dart';
import '../utils/upload.dart' as upload;
import '../utils/utils.dart' as utils;

class ClienteProvider {
  final PreferenciasUsuario prefs = PreferenciasUsuario();

  final String _urlVer = 'cliente/ver';
  final String _urlAutenticarClave = 'cliente/autenticar-clave';
  final String _urlAutenticarGoogle = 'cliente/autenticar-google';
  final String _urlActualizarToken = 'cliente/actualizar-token';
  final String _recuperarContrasenia = 'cliente/recuperar-contrasenia';
  final String _urlEditar = 'cliente/editar';
  final String _urlCambiarContrasenia = 'cliente/cambiar-contrasenia';
  final String _urlCambiarImagen = 'cliente/cambiar-imagen';
  final String _urlGenero = 'cliente/genero';

  genero(ClienteModel cliente) async {
    var client = http.Client();
    try {
      final resp = await client.post(Uri.parse(prefs.dominio + _urlGenero),
          headers: utils.headers,
          body: {
            'idCliente': prefs.idCliente,
            'auth': prefs.auth,
            'sexo': cliente.sexo.toString(),
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) prefs.clienteModel = cliente;
    } catch (err) {
      print('cliente_provider error: $err');
    } finally {
      client.close();
    }
  }

  cambiarImagen(dynamic img, Function response) async {
    var client = http.Client();
    try {
      final resp = await client.post(
          Uri.parse(prefs.dominio + _urlCambiarImagen),
          headers: utils.headers,
          body: {
            'idCliente': prefs.idCliente,
            'auth': prefs.auth,
            'img': img.toString(),
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

  Future<String> subirArchivoMobil(File imagen, String nombreImagen) async {
    try {
      return await upload.subirArchivoMobil(
          imagen, 'uss/$nombreImagen', Sistema.TARGET_WIDTH_PERFIL);
    } catch (err) {
      print('cliente_provider error: $err');
    }
    return '';
  }

  cambiarContrasenia(dynamic contraseniaAnterior, dynamic contraseniaNueva,
      Function response) async {
    var client = http.Client();
    try {
      final resp = await client.post(
          Uri.parse(prefs.dominio + _urlCambiarContrasenia),
          headers: utils.headers,
          body: {
            'idCliente': prefs.idCliente,
            'auth': prefs.auth,
            'contraseniaAnterior': contraseniaAnterior.toString(),
            'contraseniaNueva': contraseniaNueva.toString(),
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

  editar(ClienteModel cliente, Function response) async {
    var client = http.Client();
    try {
      final resp = await client.post(Uri.parse(prefs.dominio + _urlEditar),
          headers: utils.headers,
          body: {
            'idCliente': prefs.idCliente,
            'auth': prefs.auth,
            'celular': cliente.celular.toString(),
            'correo': cliente.correo.toString(),
            'nombres': cliente.nombres.toString(),
            'fechaNacimiento': cliente.fechaNacimiento.toString(),
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) {
        ClienteModel clienteModel =
            ClienteModel.fromJson(decodedResp['cliente']);
        prefs.clienteModel = clienteModel;
        return response(1, decodedResp['error']);
      }
      return response(0, decodedResp['error']);
    } catch (err) {
      print('cliente_provider error: $err');
    } finally {
      client.close();
    }
    return response(0, Sistema.MENSAJE_INTERNET);
  }

  recuperarContrasenia(
      ClienteModel clienteModel, int tipo, Function response) async {
    var client = http.Client();
    try {
      final resp = await client.post(
          Uri.parse(prefs.dominio + _recuperarContrasenia),
          headers: utils.headers,
          body: {
            'celular': clienteModel.celular.toString(),
            'correo': clienteModel.correo.toString(),
            'tipo': tipo.toString(),
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

  ver(Function response) async {
    var client = http.Client();
    NotificacionModel notificacionModel = NotificacionModel();
    int push = 0;
    try {
      final resp = await client.post(Uri.parse(prefs.dominio + _urlVer),
          headers: utils.headers,
          body: {
            'idCliente': prefs.idCliente,
            'auth': prefs.auth,
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      try {
        if (decodedResp.containsKey('nt'))
          notificacionModel = NotificacionModel.fromJson(decodedResp['nt']);
      } catch (err) {
        print('cliente_provider error: $err');
      }
      if (resp.statusCode == 403)
        return response(0, decodedResp['error'], push, notificacionModel);
      if (decodedResp['estado'] == 1) {
        ClienteModel clienteModel =
            ClienteModel.fromJson(decodedResp['cliente']);
        prefs.clienteModel = clienteModel;
      }

      return response(1, decodedResp['error'], push, notificacionModel);
    } catch (err) {
      print('cliente_provider error: $err');
    } finally {
      client.close();
    }
    return response(1, Sistema.MENSAJE_INTERNET, push, notificacionModel);
  }

  autenticarClave(String codigoPais, String cliente, String clave,
      Function response) async {
    await utils.getDeviceDetails();
    var client = http.Client();
    try {
      final resp = await client.post(
          Uri.parse(prefs.dominio + _urlAutenticarClave),
          headers: utils.headers,
          body: {
            'cliente': cliente,
            'clave': clave,
            'token': prefs.token,
            'simCountryCode': prefs.simCountryCode,
            'codigoPais': codigoPais,
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) {
        prefs.auth = decodedResp['auth'];
        ClienteModel clienteModel =
            ClienteModel.fromJson(decodedResp['cliente']);
        prefs.idCliente = clienteModel.idCliente.toString();
        prefs.clienteModel = clienteModel;
        return response(1, clienteModel);
      }
      return response(0, decodedResp['error']);
    } catch (err) {
      print('cliente_provider error: $err');
    } finally {
      client.close();
    }
    return response(0, Sistema.MENSAJE_INTERNET);
  }

  autenticarGoogle(
      String codigoPais,
      String smn,
      String correo,
      String img,
      String idGoogle,
      String nombres,
      String apellidos,
      Function response) async {
    await utils.getDeviceDetails();
    var client = http.Client();
    try {
      final resp = await client.post(
          Uri.parse(prefs.dominio + _urlAutenticarGoogle),
          headers: utils.headers,
          body: {
            'nombres': nombres.toString(),
            'apellidos': apellidos.toString(),
            'correo': correo.toString(),
            'img': img.toString(),
            'idGoogle': idGoogle.toString(),
            'token': prefs.token,
            'simCountryCode': prefs.simCountryCode,
            'codigoPais': codigoPais,
            'smn': smn.toString()
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) {
        prefs.auth = decodedResp['auth'];
        ClienteModel clienteModel =
            ClienteModel.fromJson(decodedResp['cliente']);
        prefs.idCliente = clienteModel.idCliente.toString();
        prefs.clienteModel = clienteModel;
        return response(1, clienteModel);
      }
      return response(0, decodedResp['error']);
    } catch (err) {
      print('cliente_provider error: $err');
    } finally {
      client.close();
    }
    return response(0, Sistema.MENSAJE_INTERNET);
  }

  Future<bool> actualizarToken() async {
    if (prefs.idCliente == '') return false;
    if (prefs.token == '') {
      await PushProvider().obtenerToken();
      return false;
    }
    try {
      final resp = await http.post(
          Uri.parse(prefs.dominio + _urlActualizarToken),
          headers: utils.headers,
          body: {
            'idCliente': prefs.idCliente,
            'auth': prefs.auth,
            'token': prefs.token
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) return true;
    } catch (err) {
      print('cliente_provider error: $err');
    }
    return false;
  }
}
