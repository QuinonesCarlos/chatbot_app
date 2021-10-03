import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../model/cliente_model.dart';
import '../../preference/shared_preferences.dart';
import '../../providers/registro_provider.dart';
import '../../sistema.dart';
import '../../utils/button.dart' as btn;
import '../../utils/personalizacion.dart' as prs;
import '../../utils/redes_sociales.dart' as rs;
import '../../utils/utils.dart' as utils;
import '../../utils/validar.dart' as val;
import '../../widgets/modal_progress_hud.dart';
import 'login_page.dart';

class RegistrarPage extends StatefulWidget {
  @override
  _RegistrarPageState createState() => _RegistrarPageState();
}

class _RegistrarPageState extends State<RegistrarPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final RegistroProvider _registroProvider = RegistroProvider();
  final prefs = PreferenciasUsuario();
  bool _isTerminos = false;
  bool _isErrorTerm = false;

  ClienteModel _cliente = ClienteModel();
  bool _saving = false;

  GoogleSignIn _googleSignIn = GoogleSignIn();

  bool isCelularValido = true;
  String codigoPais = '+593';
  List<String>? countries;
  String smn = '';
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
    _cliente.codigoPais = '+593';
    _cliente.correoValidado = 0;
    _cliente.celularValidado = 0;
    _escucharLoginGoogle();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          LoginPage(_tabController),
          ModalProgressHUD(
            inAsyncCall: _saving,
            child: SingleChildScrollView(
              child: Center(
                  child: Container(
                      child: _contenido(), width: prs.anchoFormulario)),
            ),
          ),
        ],
      ),
    );
  }

  Column _contenido() {
    return Column(
      children: <Widget>[
        SizedBox(height: 5.0),
        Container(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 80.0),
            child: Column(
              children: <Widget>[
                Container(
                    child: Image(
                        image: AssetImage('assets/chatbot.png'), width: 120.0)),
                SizedBox(height: 40.0),
                Row(
                  children: [
                    Container(
                      width: 150.0,
                      child: TextButton(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text('Login',
                                style: TextStyle(
                                    color: prs.colorTextTitle, fontSize: 20.0)),
                            SizedBox(height: 20.0),
                          ],
                        ),
                        onPressed: () {
                          _tabController.animateTo(0,
                              duration: Duration(seconds: 3),
                              curve: Curves.elasticInOut);
                        },
                      ),
                    ),
                    Container(
                      width: 150.0,
                      child: TextButton(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text('Registrarse',
                                style: TextStyle(
                                    color: prs.colorLinearProgress,
                                    fontSize: 20.0)),
                            Divider(
                                color: prs.colorLinearProgress, thickness: 3.0)
                          ],
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.0),
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      _crearNombres(),
                      SizedBox(height: 10.0),
                      _crearCorreo(),
                      SizedBox(height: 10.0),
                      _crearCelular(),
                      SizedBox(height: 10.0),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Checkbox(
                      value: _isTerminos,
                      activeColor: Colors.green,
                      onChanged: (term) {
                        _isTerminos = term!;
                        _isErrorTerm = !_isTerminos;
                        setState(() {});
                      },
                    ),
                    TextButton(
                      child: Text(
                        'Aceptar términos y condiciones',
                        style: TextStyle(
                            color: _isErrorTerm ? Colors.red : Colors.black),
                      ),
                      onPressed: () {
                        _isTerminos = !_isTerminos;
                        _isErrorTerm = !_isTerminos;
                        setState(() {});
                      },
                    ),
                    GestureDetector(
                        child: Text('VER',
                            style: TextStyle(
                                color: Colors.indigo,
                                decoration: TextDecoration.underline)),
                        onTap: _terminos),
                  ],
                ),
                btn.booton('REGISTRARSE', _registrar),
                // SizedBox(height: 10.0),
                // Center(child: Text('- O -')),
                // SizedBox(height: 20.0),
                // Sistema.isWeb
                //     ? Container()
                //     : Row(
                //         crossAxisAlignment: CrossAxisAlignment.center,
                //         mainAxisAlignment: MainAxisAlignment.center,
                //         children: [
                //           rs.buttonGoogle('Continuar con Google',
                //               prs.iconoGoogle, _iniciarSessionGoogle),
                //         ],
                //       ),
                SizedBox(height: 20.0),
                Visibility(
                  // visible: Sistema.isIOS,
                  child: TextButton(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text('Regresar',
                            style: TextStyle(color: Colors.indigo)),
                      ],
                    ),
                    onPressed: () async {
                      _saving = true;
                      setState(() {});
                      await rs.autlogin(context);
                      _saving = false;
                      setState(() {});
                    },
                  ),
                ),
                SizedBox(height: 20.0),
              ],
            )),
      ],
    );
  }

  _terminos() {
    _launchURL('https://www.planck.biz/terminos-y-condiciones');
  }

  _launchURL(url) async {
    var encoded = Uri.encodeFull(url);
    if (await canLaunch(encoded)) {
      await launch(encoded);
    } else {
      print('Could not open the url.');
    }
  }

  Widget _crearNombres() {
    return TextFormField(
        maxLength: 70,
        initialValue: _cliente.nombres,
        textCapitalization: TextCapitalization.words,
        keyboardType: TextInputType.text,
        decoration: prs.decoration('Nombre completo', null),
        onSaved: (value) => _cliente.nombres = value!,
        validator: val.validarNombre);
  }

  _onChangedCelular(phone) {
    codigoPais = '+593';
    _cliente.celular = phone;
  }

  Widget _crearCelular() {
    return utils.crearCelular(prefs.simCountryCode, _onChangedCelular);
  }

  Widget _crearCorreo() {
    return TextFormField(
        keyboardType: TextInputType.emailAddress,
        maxLength: 60,
        decoration: prs.decoration('Correo', null),
        onSaved: (value) => _cliente.correo = value!,
        validator: val.validarCorreo);
  }

  _registrar() async {
    FocusScope.of(context).requestFocus(FocusNode());
    _saving = true;
    setState(() {});
    _formKey.currentState!.save();
    if (_cliente.celular.toString().length <= 8 ||
        val.validarNombre(_cliente.nombres.toString()) != null ||
        val.validarCorreo(_cliente.correo.toString()) != null) {
      _formKey.currentState!.validate();

      _saving = false;
      if (!_isTerminos) {
        _isErrorTerm = true;
      }
      setState(() {});
      return;
    }

    if (!_isTerminos) {
      _saving = false;
      _isErrorTerm = true;
      setState(() {});
      return;
    }

    Future.delayed(const Duration(milliseconds: 400), () async {
      if (isCelularValido) {
        _formKey.currentState!.save();
        _cliente.clave = utils.generateMd5(_cliente.celular
            .toString()
            .substring(_cliente.celular.toString().length - 5,
                _cliente.celular.toString().length - 1));
        _registroProvider.registrar(_cliente, codigoPais, smn,
            (estado, clienteModel) {
          _saving = false;
          setState(() {});
          if (estado == 0) return utils.mostrarSnackBar(context, clienteModel);
          rs.ingresar(context, clienteModel);
        });
      } else {
        _saving = false;
        setState(() {});
      }
    });
  }

  void _autenticarGoogle(
      context, correo, img, idGoogle, nombres, apellidos) async {
    _saving = true;
    setState(() {});
    await rs.autenticarGoogle(context, _googleSignIn, codigoPais, smn, correo,
        img, idGoogle, nombres, apellidos);
    _saving = false;
    setState(() {});
  }

  Future<void> _iniciarSessionGoogle() async {
    _saving = true;
    setState(() {});
    try {
      await _googleSignIn.signIn();
    } catch (err) {
      print('registrar_page error: $err');
    }
    _saving = false;
    setState(() {});
  }

  _escucharLoginGoogle() {
    _googleSignIn.onCurrentUserChanged
        .listen((GoogleSignInAccount? currentUser) {
      if (currentUser != null) {
        var nombres = currentUser.displayName!.split(' ');
        String nombre = '';
        if (nombres.length > 0) {
          nombre = nombres[0];
        }
        String apellido = '';
        if (nombres.length > 1) {
          for (var i = 1; i < nombres.length; i++) {
            apellido += nombres[i] + ' ';
          }
        }
        _autenticarGoogle(context, currentUser.email, currentUser.photoUrl,
            currentUser.id, nombre, apellido);
      }
    });
  }
}
