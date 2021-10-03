import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../model/cliente_model.dart';
import '../sistema.dart';

class PreferenciasUsuario {
  static PreferenciasUsuario? _instancia;

  PreferenciasUsuario._internal();

  factory PreferenciasUsuario() {
    if (_instancia == null) {
      _instancia = PreferenciasUsuario._internal();
    }
    return _instancia!;
  }

  init() async {
    try {
      _instancia!.prefs = await SharedPreferences.getInstance();
    } catch (err) {
      print(err);
    }
  }

  SharedPreferences? prefs;

  String get uuid {
    if (prefs!.getString('uuid') == null) {
      prefs!.setString('uuid', Uuid().v4());
    }
    return prefs!.getString('uuid') ?? '';
  }

  set uuid(String value) {
    prefs!.setString('uuid', value);
  }

  String get auth {
    return prefs!.getString('auth') ?? '';
  }

  set auth(String value) {
    prefs!.setString('auth', value);
  }

  String get sms {
    return prefs!.getString('sms') ?? '';
  }

  set sms(String value) {
    prefs!.setString('sms', value);
  }

  set clienteModel(ClienteModel cliente) {
    prefs!.setString('link', cliente.link.toString());
    prefs!.setString('nombres', cliente.nombres.toString());
    prefs!.setString('apellidos', cliente.apellidos.toString());
    prefs!.setString('correo', cliente.correo.toString());
    prefs!.setString('idCliente', cliente.idCliente.toString());
    prefs!.setString('cedula', cliente.cedula.toString());
    prefs!.setString('celular', cliente.celular.toString());
    prefs!.setString('img', cliente.img.toString());

    prefs!.setInt('celularValidado', cliente.celularValidado);
    prefs!.setInt('sexo', cliente.sexo);
    prefs!.setDouble('calificacion', cliente.calificacion);
    prefs!.setInt('calificaciones', cliente.calificaciones);
    prefs!.setInt('registros', cliente.registros);
    prefs!.setInt('puntos', cliente.puntos);
    prefs!.setInt('correctos', cliente.correctos);
    prefs!.setInt('canceladas', cliente.canceladas);
    prefs!.setString('fechaNacimiento', cliente.fechaNacimiento);
  }

  ClienteModel get clienteModel {
    final cliente = ClienteModel();
    cliente.link = prefs!.getString('link') ?? '';
    cliente.nombres = prefs!.getString('nombres') ?? '';
    cliente.apellidos = prefs!.getString('apellidos') ?? '';
    cliente.correo = prefs!.getString('correo') ?? '';
    cliente.cedula = prefs!.getString('cedula') ?? '';
    cliente.celular = prefs!.getString('celular') ?? '';
    cliente.img = prefs!.getString('img') ?? '';

    cliente.celularValidado = prefs!.getInt('celularValidado') ?? 0;
    cliente.sexo = prefs!.getInt('sexo') ?? 0;
    cliente.calificacion = prefs!.getDouble('calificacion') ?? 0.0;
    cliente.calificaciones = prefs!.getInt('calificaciones') ?? 0;
    cliente.registros = prefs!.getInt('registros') ?? 0;
    cliente.puntos = prefs!.getInt('puntos') ?? 0;
    cliente.correctos = prefs!.getInt('correctos') ?? 0;
    cliente.canceladas = prefs!.getInt('canceladas') ?? 0;
    cliente.fechaNacimiento = prefs!.getString('fechaNacimiento') ?? '';
    return cliente;
  }

  get isDemo {
    return clienteModel.correo ==
            'explorar@${Sistema.aplicativoTitle.toLowerCase()}.com' ||
        isExplorar;
  }

  get isExplorar {
    return '' == prefs!.getString('idCliente') ||
        prefs!.getString('idCliente') == Sistema.ID_CLIENTE;
  }

  String get idCliente {
    return prefs!.getString('idCliente') ?? '';
  }

  set idCliente(String value) {
    if (prefs != null) prefs!.setString('idCliente', value);
  }

  String get imei {
    return prefs!.getString('imei') ?? '';
  }

  set imei(String value) {
    if (prefs != null) prefs!.setString('imei', value);
  }

  String get dominio {
    return prefs!.getString('dominio') ?? '';
  }

  set dominio(String value) {
    if (prefs != null) prefs!.setString('dominio', value);
  }

  String get token {
    if (prefs == null) return '';
    return prefs!.getString('token') ?? '';
  }

  set token(String? value) {
    if (prefs != null) prefs!.setString('token', value!);
  }

  bool get empezamos {
    if (prefs == null) return false;
    return prefs!.getBool('empezamos') ?? false;
  }

  set empezamos(bool value) {
    if (prefs != null) prefs!.setBool('empezamos', value);
  }

  String get simCountryCode {
    return prefs!.getString('simCountryCode') ?? 'EC';
  }

  set simCountryCode(String? value) {
    if (prefs != null) prefs!.setString('simCountryCode', value!.toUpperCase());
  }
}
