import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../model/archivo_model.dart';
import '../utils/cache.dart' as cache;
import '../utils/permisos.dart';

class ArchivoCard extends StatelessWidget {
  ArchivoCard({required this.archivoModel, required this.onTab});

  final ArchivoModel archivoModel;
  final Function onTab;

  @override
  Widget build(BuildContext context) {
    return _card(context);
  }

  Widget _card(BuildContext context) {
    final card = Container(
      height: 110.0,
      child: Card(
        elevation: 2.0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Row(
          children: <Widget>[_avatar(), _contenido(), SizedBox(width: 10.0)],
        ),
      ),
    );
    return Stack(
      children: <Widget>[
        card,
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
                splashColor: Colors.blueAccent.withOpacity(0.6),
                onTap: () => onTab(archivoModel)),
          ),
        ),
      ],
    );
  }

  Widget _avatar() {
    return ClipRRect(
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
      child: cache.fadeImage('${prefs.dominio}${archivoModel.archivo}',
          width: 100, height: 110),
    );
  }

  Widget _contenido() {
    return Expanded(
      child: Container(
        height: 110,
        padding: EdgeInsets.only(left: 10.0, top: 5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 4),
            Text('Detalle:', style: TextStyle(fontSize: 9)),
            Text('${archivoModel.detalle}',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('Archivo:', style: TextStyle(fontSize: 9)),
            Text('${archivoModel.archivo}',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
