import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../model/cliente_model.dart';
import '../../preference/shared_preferences.dart';
import '../../providers/cliente_provider.dart';
import '../../sistema.dart';
import '../../utils/button.dart' as btn;
import '../../utils/personalizacion.dart' as prs;
import '../../utils/redes_sociales.dart' as rs;
import '../../utils/utils.dart' as utils;
import '../../widgets/modal_progress_hud.dart';

class LoginPage extends StatefulWidget {
  final TabController tabController;

  LoginPage(this.tabController) : super();

  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ClienteProvider _clienteProvider = ClienteProvider();
  final prefs = PreferenciasUsuario();
  String smn = '';

  ClienteModel cliente = ClienteModel();
  bool _saving = false;

  GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  void initState() {
    super.initState();
    _escucharLoginGoogle();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: ModalProgressHUD(
          inAsyncCall: _saving,
          child: SingleChildScrollView(
            child: Center(
                child:
                    Container(child: _contenido(), width: prs.anchoFormulario)),
          ),
        ));
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
                                  color: prs.colorLinearProgress,
                                  fontSize: 20.0)),
                          Divider(
                              color: prs.colorLinearProgress, thickness: 3.0)
                        ],
                      ),
                      onPressed: () {},
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
                                  color: prs.colorTextTitle, fontSize: 20.0)),
                          SizedBox(height: 20.0),
                        ],
                      ),
                      onPressed: () {
                        widget.tabController.animateTo(1,
                            duration: Duration(seconds: 3),
                            curve: Curves.elasticInOut);
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              Center(
                child: Text('Bienvenido',
                    style: TextStyle(
                        color: prs.colorTextTitle,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
              ),
              SizedBox(height: 20.0),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    _crearCelular(),
                    SizedBox(height: 10.0),
                    _crearPassword(),
                    SizedBox(height: 10.0),
                  ],
                ),
              ),
              SizedBox(height: 10.0),
              btn.booton('INICIAR SESI??N', _autenticarClave),
              SizedBox(height: 10.0),
              TextButton(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text('??Olvidaste tu contrase??a? ',
                        textAlign: TextAlign.center),
                    Text('??Recuperar!', style: TextStyle(color: Colors.indigo)),
                  ],
                ),
                onPressed: () => Navigator.pushNamed(context, 'contrasenia'),
              ),
              // SizedBox(height: 10.0),
              // Center(child: Text('- O -')),
              // SizedBox(height: 20.0),
              // Sistema.isWeb
              //     ? Container()
              //     : Row(
              //         crossAxisAlignment: CrossAxisAlignment.center,
              //         mainAxisAlignment: MainAxisAlignment.center,
              //         children: [
              //           rs.buttonGoogle('Continuar con Google', prs.iconoGoogle,
              //               _iniciarSessionGoogle),
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
                      Text('Regresar', style: TextStyle(color: Colors.indigo)),
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
          ),
        ),
      ],
    );
  }

  bool isCelularValido = true;
  String codigoPais = '+593';

  _onChangedCelular(phone) {
    cliente.celular = phone;
  }

  Widget _crearCelular() {
    return Row(
      children: [
        SizedBox(width: 5.0),
        Expanded(
          child: utils.crearCelular(prefs.simCountryCode, _onChangedCelular),
        )
      ],
    );
  }

  Widget _crearPassword() {
    return TextFormField(
        obscureText: true,
        maxLength: 12,
        decoration: prs.decoration('Contrase??a', null),
        onSaved: (value) => cliente.clave = value!,
        validator: (value) {
          if (value!.trim().length < 4) return 'M??nimo 4 caracteres';
          return null;
        });
  }

  _autenticarClave() {
    FocusScope.of(context).requestFocus(FocusNode());
    _saving = true;
    setState(() {});
    if (cliente.celular.toString().length <= 8 ||
        cliente.clave.toString().length <= 3) {
      _formKey.currentState!.validate();
      _saving = false;
      setState(() {});
      return;
    }
    if (!isCelularValido) {
      _saving = false;
      setState(() {});
      return;
    }
    _formKey.currentState!.save();
    _clienteProvider.autenticarClave(codigoPais, cliente.celular.toString(),
        utils.generateMd5(cliente.clave), (estado, clienteModel) {
      _saving = false;
      if (mounted) setState(() {});
      if (estado == 0) return _mostrarSnackBar(clienteModel);
      rs.ingresar(context, clienteModel);
    });
  }

  _autenticarGoogle(context, correo, img, idGoogle, nombres, apellidos) async {
    _saving = true;
    setState(() {});
    await rs.autenticarGoogle(context, _googleSignIn, codigoPais, smn, correo,
        img, idGoogle, nombres, apellidos);
    _saving = false;
    if (mounted) setState(() {});
  }

  _iniciarSessionGoogle() async {
    _saving = true;
    setState(() {});
    try {
      await _googleSignIn.signIn();
    } catch (err) {
      print('login_page error: $err');
    } finally {
      _saving = false;
      if (mounted) setState(() {});
    }
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

  _mostrarSnackBar(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mensaje),
      action: SnackBarAction(
        label: 'Recuperar cuenta',
        onPressed: () => Navigator.pushNamed(context, 'contrasenia'),
      ),
    ));
  }
}
