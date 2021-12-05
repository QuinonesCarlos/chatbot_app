import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../preference/shared_preferences.dart';
import '../providers/cliente_provider.dart';
import '../utils/cache.dart' as cache;
import '../utils/personalizacion.dart' as prs;
import '../utils/utils.dart' as utils;

class MenuWidget extends StatefulWidget {
  @override
  _MenuWidgetState createState() => _MenuWidgetState();
}

class _MenuWidgetState extends State<MenuWidget> {
  final PreferenciasUsuario prefs = PreferenciasUsuario();
  final ClienteProvider _clienteProvider = ClienteProvider();

  @override
  void initState() {
    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    _encabezado(context),
                    Divider(),
                    Container(
                      padding: EdgeInsets.only(left: 15.0),
                      child: ListTile(
                          dense: true,
                          leading: prs.iconoContactos,
                          title: Text('Contactos'),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, 'contacto');
                          }),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 15.0),
                      child: ListTile(
                          dense: true,
                          leading: prs.iconoArchivos,
                          title: Text('Archivos'),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, 'archivos');
                          }),
                    ),
                  ],
                ),
              ),
            ),
            _pie(),
          ],
        ),
      ),
    );
  }

  Widget _pie() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(left: 15.0),
          child: ListTile(
              dense: true,
              leading: prs.iconoNotificacion,
              title: Text('Notificaciones'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, 'notificacion');
              }),
        ),
        ListTile(
          dense: true,
          leading: prs.iconoAbout,
          title: Text('Acerca de'),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, 'about');
          },
        ),
        Divider(),
        SizedBox(height: 4),
        Text('TicOSolutions', textScaleFactor: 0.8),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _encabezado(BuildContext context) {
    Container tarjeta = Container(
      margin: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 10),
          CircularPercentIndicator(
            radius: 70.0,
            lineWidth: 3.0,
            animation: true,
            percent: 1,
            center: ClipRRect(
              borderRadius: BorderRadius.circular(100.0),
              child: cache.fadeImage(prefs.clienteModel.img,
                  width: 60, height: 60),
            ),
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: prs.colorButtonSecondary,
          ),
          SizedBox(width: 10.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                  width: 175.0,
                  child: Text(prefs.clienteModel.nombres,
                      textScaleFactor: 1.4, overflow: TextOverflow.fade)),
              Container(
                  width: 175.0,
                  child: Text(prefs.clienteModel.correo,
                      textScaleFactor: 0.9,
                      softWrap: false,
                      overflow: TextOverflow.fade,
                      style: TextStyle(color: Colors.indigo))),
            ],
          )
        ],
      ),
    );

    return Stack(
      children: <Widget>[
        tarjeta,
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              splashColor: Colors.blueAccent.withOpacity(0.6),
              onTap: () {
                utils.mostrarProgress(context);
                _clienteProvider.ver((estado, error, push, notificacionModel) {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.pushNamed(context, 'perfil');
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}
