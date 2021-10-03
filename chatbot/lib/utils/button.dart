import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/personalizacion.dart' as prs;

Widget bootonIcon(String label, Icon icon, Function? onPressed) {
  return Container(
    padding: EdgeInsets.all(10.0),
    child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            primary: prs.colorButtonPrimary,
            onPrimary: prs.colorTextButtonPrimary,
            elevation: 1.0,
            shape: RoundedRectangleBorder(
                side: BorderSide(
                    color: prs.colorTextButtonPrimary,
                    width: 1.0,
                    style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(10.0))),
        child: Container(
          margin: EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[SizedBox(width: 20.0), Text(label), icon],
          ),
        ),
        onPressed: onPressed as void Function()?),
  );
}

Widget booton(String label, Function onPressed) {
  return Container(
    padding: EdgeInsets.all(10.0),
    child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            primary: prs.colorButtonPrimary,
            onPrimary: prs.colorTextButtonPrimary,
            elevation: 1.0,
            shape: RoundedRectangleBorder(
                side: BorderSide(
                    color: prs.colorTextButtonPrimary,
                    width: 1.0,
                    style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(10.0))),
        child: Container(
          margin: EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[Text(label)],
          ),
        ),
        onPressed: onPressed as void Function()?),
  );
}

Widget confirmar(String label, Function onPressed) {
  return Container(
    padding: EdgeInsets.all(10.0),
    child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            primary: prs.colorTextButtonPrimary,
            onPrimary: prs.colorButtonPrimary,
            elevation: 1.0,
            shape: RoundedRectangleBorder(
                side: BorderSide(
                    color: prs.colorTextButtonPrimary,
                    style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(10.0))),
        child: Container(
          margin: EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[Text(label)],
          ),
        ),
        onPressed: onPressed as void Function()?),
  );
}
