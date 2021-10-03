import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../model/cliente_model.dart';
import '../pages/planck/catalogo_page.dart';
import '../providers/cliente_provider.dart';
import '../utils/permisos.dart' as permisos;

final _clienteProvider = ClienteProvider();

Future<bool> autenticarGoogle(
    BuildContext context,
    GoogleSignIn googleSignIn,
    String codigoPais,
    String smn,
    correo,
    img,
    idGoogle,
    nombres,
    apellidos) async {
  FocusScope.of(context).requestFocus(FocusNode());
  await _clienteProvider.autenticarGoogle(
      codigoPais,
      smn,
      correo,
      img.toString().replaceAll('=s96-c', ''),
      idGoogle,
      '$nombres $apellidos',
      '', (estado, clienteModel) {
    googleSignIn.signOut();
    if (estado == 0)
      return; //En caso de error lo registramos con el formulario lleno;
    ingresar(context, clienteModel);
  });
  return false;
}

ingresar(BuildContext context, ClienteModel clienteModel) {
  Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => CatalogoPage()),
      (Route<dynamic> route) {
    return false;
  });
}

autlogin(BuildContext context, {bool isRedirec: false}) async {
  final ClienteModel _cliente = await permisos.ingresar();
  ingresar(context, _cliente);
  return;
}

Widget buttonGoogle(String text, Icon icon, Function onPressed) {
  return RawMaterialButton(
    onPressed: onPressed as void Function()?,
    child: icon,
    shape: CircleBorder(),
    elevation: 1.0,
    fillColor: Colors.redAccent,
    padding: const EdgeInsets.all(13.0),
  );
}
