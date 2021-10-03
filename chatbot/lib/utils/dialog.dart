import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/personalizacion.dart' as prs;

mostrar(BuildContext context, String mensaje,
    {Function? fIzquierda,
    String mIzquierda: 'ACEPTAR',
    Function? fBotonIDerecha,
    String mBotonDerecha: 'CANCELAR',
    String titulo: 'Importante',
    Color color: Colors.redAccent,
    Color colorTitulo: Colors.black,
    IconData icon: Icons.cancel}) {
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          title: Text(
            titulo.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(color: colorTitulo),
          ),
          content: Container(
            width: 350.0,
            child: Text(mensaje.toString()),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(mIzquierda),
              onPressed: () {
                if (fIzquierda == null) {
                  Navigator.of(context).pop();
                } else {
                  fIzquierda();
                }
              },
            ),
            (fBotonIDerecha == null)
                ? Container()
                : ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        primary: prs.colorButtonSecondary,
                        elevation: 2.0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0))),
                    label: Text(mBotonDerecha),
                    icon: Icon(icon, size: 18.0),
                    onPressed: fBotonIDerecha as void Function()?,
                  ),
          ],
        );
      });
}
