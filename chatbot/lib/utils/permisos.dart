import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../model/cliente_model.dart';
import '../model/notificacion_model.dart';
import '../preference/shared_preferences.dart';
import '../providers/cliente_provider.dart';
import '../providers/notificacion_provider.dart';
import '../sistema.dart';
import '../utils/cache.dart' as cache;
import '../utils/personalizacion.dart' as prs;
import '../utils/utils.dart' as utils;

final PreferenciasUsuario prefs = PreferenciasUsuario();
final ClienteProvider _clienteProvider = ClienteProvider();
final NotificacionProvider _notificacionProvider = NotificacionProvider();

Future<ClienteModel> ingresar() async {
  prefs.idCliente = Sistema.ID_CLIENTE;
  prefs.auth = Sistema.AUTH_CLIENTE;
  await utils.getDeviceDetails(uuid: Sistema.idUuid);
  ClienteModel clienteModel = ClienteModel();
  clienteModel.img =
      'https://image.freepik.com/vector-gratis/asociacion-afiliados-ganar-dinero-estrategia-mercadeo_115790-146.jpg';
  clienteModel.idCliente = prefs.idCliente;
  clienteModel.correo = 'invitado@ticosolutions.com';
  clienteModel.nombres = 'Invitado TicOsolutions';
  prefs.clienteModel = clienteModel;
  return clienteModel;
}

cerrasSesion(BuildContext context) {
  prefs.idCliente = '';
  prefs.auth = '';
  prefs.sms = '';
  prefs.empezamos = false;
  return Navigator.of(context)
      .pushNamedAndRemoveUntil('principal', (Route<dynamic> route) => false);
}

mostrarConfigurarNotificaciones(
    BuildContext context, NotificacionModel notificacion) {
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          insetPadding:
              EdgeInsets.only(left: 20.0, right: 20.0, top: 70.0, bottom: 40.0),
          contentPadding: EdgeInsets.all(0.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          title: Text(notificacion.hint,
              overflow: TextOverflow.fade, textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(height: 10.0),
              cache.fadeImage(notificacion.img, days: 1),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text(notificacion.omitir),
              onPressed: () {
                _notificacionProvider.marcar(notificacion.idMensaje, 0);
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  primary: prs.colorButtonSecondary,
                  elevation: 2.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0))),
              label: Text(notificacion.boton),
              icon: Icon(FontAwesomeIcons.handPointUp),
              onPressed: () {
                _notificacionProvider.marcar(notificacion.idMensaje, 1);
                notificacion.accion(context);
              },
            ),
          ],
        );
      });
}

verificarSession(BuildContext context) async {
  if (prefs.isExplorar) return;
  _clienteProvider.ver((estado, error, push, NotificacionModel notificacion) {
    if (notificacion.idMensaje != '0') {
      return mostrarConfigurarNotificaciones(context, notificacion);
    }
    if (estado == 1) {
      if (push == 1) getCheckNotificationPermStatus(context);
      return;
    } else {
      cerrasSesion(context);
    }
  });
}

var permGranted = "granted";
var permDenied = "denied";
var permUnknown = "unknown";

String getCheckNotificationPermStatus(BuildContext context) {
  return permGranted;
}
