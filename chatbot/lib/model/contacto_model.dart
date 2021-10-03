import 'package:flutter/material.dart';

class ContactoModel {
  String nombre;
  String celular;
  String etiqueta;

  ContactoModel({
    this.nombre: '',
    this.celular: '',
    this.etiqueta: '',
  });

  factory ContactoModel.fromJson(Map<String, dynamic> json) => ContactoModel(
        nombre: json["nombre"],
        celular: json["celular"],
        etiqueta: json["etiqueta"],
      );

  Color color(String et) {
    List palabras = et.toUpperCase().trim().split('_');
    int? valor = 1;
    int leng = 9;
    if (palabras.length == 1) {
      valor = (palabras[0].codeUnits[0]) % leng;
    } else if (palabras.length == 2) {
      valor = (palabras[0].codeUnits[0] + palabras[1].codeUnits[0]) % leng;
    } else if (palabras.length == 3) {
      valor = (palabras[0].codeUnits[0] +
              palabras[1].codeUnits[0] +
              palabras[2].codeUnits[0]) %
          leng;
    }
    switch (valor) {
      case 1:
        return hexToColor('#4CAF50');
      case 2:
        return hexToColor('#9C27B0');
      case 3:
        return hexToColor('#3F51B5');
      case 4:
        return hexToColor('#FF5722');
      case 5:
        return hexToColor('#FF9800');
      case 6:
        return hexToColor('#E91E63');
      case 7:
        return hexToColor('#795548');
      case 8:
        return hexToColor('#009688');
      case 9:
        return hexToColor('#00BCD4');
      default:
        return hexToColor('#000000');
    }
  }

  Color hexToColor(String code) {
    return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }

  Widget etiquetas(context) {
    List etiquetas = etiqueta.split(',');
    List<TextSpan> children = [];
    if (etiquetas[0].isEmpty) return Container();
    etiquetas.forEach((element) {
      final String et = element.toString().trim();
      children
          .add(TextSpan(text: '[ $et ] ', style: TextStyle(color: color(et))));
    });
    return RichText(
        text: TextSpan(
            style: DefaultTextStyle.of(context).style, children: children));
  }
}
