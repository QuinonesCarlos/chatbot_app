import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/dialog.dart' as dlg;
import '../../widgets/modal_progress_hud.dart';
import '../model/whatsapp_model.dart';
import '../preference/shared_preferences.dart';
import '../providers/whatsapp_provider.dart';
import '../sistema.dart';
import '../utils/button.dart' as btn;
import '../utils/personalizacion.dart' as prs;
import '../utils/utils.dart' as utils;

class WhatsappCelularDialog extends StatefulWidget {
  final WhatsappModel whatsapp;

  WhatsappCelularDialog(this.whatsapp);

  @override
  _WhatsappCelularDialogState createState() => _WhatsappCelularDialogState();
}

class _WhatsappCelularDialogState extends State<WhatsappCelularDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final prefs = PreferenciasUsuario();
  final WhatsappProvider _whatsappProvider = WhatsappProvider();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrar WhatsApp'),
      ),
      body: ModalProgressHUD(
        inAsyncCall: _saving,
        child: Center(
            child: Container(child: _body(), width: prs.anchoFormulario)),
      ),
    );
  }

  _onChangedCelular(phone) {
    widget.whatsapp.celular = phone;
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

  Widget _crearAlias() {
    return TextFormField(
      keyboardType: TextInputType.name,
      textCapitalization: TextCapitalization.words,
      initialValue: widget.whatsapp.alias,
      validator: (value) {
        if (value!.trim().length < 4) return 'Mínimo 4 caracteres';
        return null;
      },
      onSaved: (value) {
        widget.whatsapp.alias = value!;
      },
      decoration: prs.decoration('Alias e.g. Matriz', null),
    );
  }

  Widget _body() {
    return Column(
      children: <Widget>[
        Expanded(
          child: Form(
              key: _formKey,
              child: Container(
                padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      _crearAlias(),
                      SizedBox(height: 20.0),
                      _crearCelular(),
                      SizedBox(height: 30.0),
                      Text(
                          'Ingresa al LINK generado y escanea el QR con el WhatsApp que deseas registrar.',
                          style: TextStyle(color: Colors.red)),
                      SizedBox(height: 10.0),
                      Text(
                          'Escanea el QR solo con el WhatsApp que te pertenezca.\nTU eres el RESPONSABLE LEGAL de su USO.',
                          style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              )),
        ),
        btn.bootonIcon(
            'ABRIR LINK AQUI', Icon(Icons.open_in_browser_sharp), _abrir),
        btn.bootonIcon('COMPARTIR LINK', Icon(Icons.share), _compartir),
      ],
    );
  }

  Future<String> _generarLink() async {
    FocusScope.of(context).requestFocus(FocusNode());
    _formKey.currentState!.save();

    if (widget.whatsapp.alias.length <= 4) {
      _formKey.currentState!.validate();
      return '';
    }

    if (widget.whatsapp.celular.length <= 8) {
      dlg.mostrar(context, 'Ingresa el numero de WhatsApp a registrar');
      return '';
    }
    _saving = true;
    setState(() {});
    widget.whatsapp.celular =
        widget.whatsapp.celular.replaceAll(' ', '').replaceAll('+', '');
    String idplataforma = utils.headers['idplataforma'];
    String imei = utils.headers['imei'];
    String auth = prefs.auth.toString().replaceAll('/', '-PLANCK-');
    String linkLargo =
        '${prefs.dominio}whatsapp/qr/${prefs.idCliente}/$auth/$idplataforma/$imei/${widget.whatsapp.celular}/${widget.whatsapp.alias}/${Sistema.idAplicativo}';
    return linkLargo;
  }

  _abrir() async {
    String link = await _generarLink();
    if (link == '') return;
    await _whatsappProvider.link(widget.whatsapp.celular,
        (estado, mensaje) async {
      _saving = false;
      if (estado <= 0) {
        setState(() {});
        dlg.mostrar(context, mensaje,
            titulo: 'ALERTA', colorTitulo: Colors.red);
      } else {
        Navigator.of(context).pop();
        var encoded = Uri.encodeFull(link);
        if (await canLaunch(encoded)) {
          await launch(encoded);
        } else {
          print('Could not open the url.');
        }
      }
    });
  }

  _compartir() async {
    String link = await _generarLink();
    if (link == '') return;
    await _whatsappProvider.link(widget.whatsapp.celular, (estado, mensaje) {
      _saving = false;
      if (estado <= 0) {
        setState(() {});
        dlg.mostrar(context, mensaje,
            titulo: 'ALERTA', colorTitulo: Colors.red);
      } else {
        Navigator.of(context).pop();
        Share.share(Uri.decodeFull(link));
      }
    });
  }
}
