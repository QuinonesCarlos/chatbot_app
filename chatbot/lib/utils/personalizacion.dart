import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

Color hexToColor(String code) {
  return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
}

InputDecoration decorationSearch(String labelText) {
  return InputDecoration(
    labelStyle: TextStyle(color: colorTextTitle),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: colorLineBorder, width: 1.0),
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: colorLinearProgress, width: 1.0),
    ),
    prefixIcon: Icon(Icons.search, size: 27.0, color: colorLinearProgress),
    labelText: labelText,
  );
}

InputDecoration decoration(String labelText, Widget? prefixIcon,
    {Widget? suffixIcon}) {
  return InputDecoration(
    labelStyle: TextStyle(color: colorTextInputLabel),
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    counterText: '',
    errorStyle: TextStyle(color: Colors.red),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: colorLineBorder, width: 1.0),
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: colorLinearProgress, width: 1.0),
    ),
    contentPadding: EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0),
    labelText: labelText,
  );
}

const String colorSecondary = '#2da867'; //Purpura
get colorAppBar => hexToColor('#29a068');

get colorButtonSecondary => hexToColor(colorSecondary);

get colorButtonPrimary => hexToColor('#FFFFFF');

get colorTextButtonPrimary => hexToColor(colorSecondary);

get colorLinearProgress => hexToColor(colorSecondary);

get colorTextTitle => hexToColor('#0E0525');

get colorTextDescription => hexToColor('#212A37');

get colorTextInputLabel => hexToColor(colorSecondary);

get colorLineBorder => hexToColor('#DDDDDD');

get colorIcons => hexToColor(colorSecondary);

get colorIconsAppBar => hexToColor("#FFFFFF");

get iconoGoogle =>
    Icon(FontAwesomeIcons.google, color: Colors.white, size: 30.0);

get iconoCorreo => Icon(Icons.email, color: colorIcons);

get iconoNombres => Icon(FontAwesomeIcons.peopleArrows, color: colorIcons);

get anchoFormulario {
  return 500.0;
}

get ancho {
  return 1100.0;
}

get iconoContrasenia =>
    Icon(FontAwesomeIcons.key, color: colorIcons, size: 22.0);

get iconoContraseniaNueva =>
    Icon(FontAwesomeIcons.unlockAlt, color: colorIcons, size: 22.0);

get iconoAbout => Icon(FontAwesomeIcons.atlassian, color: colorIcons);

get iconoContacto => Icon(Icons.contact_phone, size: 35.0, color: Colors.white);

get iconoContactos => Icon(Icons.contacts, size: 26.0, color: colorIcons);

get iconoArchivos => Icon(Icons.file_copy, size: 26.0, color: colorIcons);

get iconoContactosMenu => Icon(Icons.contacts, size: 26.0, color: Colors.white);

get iconoNotificacion =>
    Icon(FontAwesomeIcons.bell, color: colorIcons, size: 25.0);
