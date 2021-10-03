import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import '../../bloc/archivo_bloc.dart';
import '../../libs/flutter_tagging/configurations.dart';
import '../../libs/flutter_tagging/tagging.dart';
import '../../model/archivo_model.dart';
import '../../model/contacto_model.dart';
import '../../model/etiqueta_model.dart';
import '../../model/whatsapp_model.dart';
import '../../preference/shared_preferences.dart';
import '../../providers/whatsapp_provider.dart';
import '../../utils/button.dart' as btn;
import '../../utils/cache.dart' as cache;
import '../../utils/dialog.dart' as dlg;
import '../../utils/personalizacion.dart' as prs;
import '../../utils/utils.dart' as utils;
import '../../widgets/modal_progress_hud.dart';

class CampaniaPage extends StatefulWidget {
  final WhatsappModel whatsappModel;
  final Function mostrarMnesjae;

  CampaniaPage(this.whatsappModel, this.mostrarMnesjae) : super();

  @override
  State<CampaniaPage> createState() => _CampaniaPageState();
}

class _CampaniaPageState extends State<CampaniaPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final PreferenciasUsuario prefs = PreferenciasUsuario();

  WhatsappModel _whatsappPrueba = WhatsappModel();
  final WhatsappProvider _whatsappProvider = WhatsappProvider();
  final ArchivoBloc _archivoBloc = ArchivoBloc();
  List<EtiquetaModel> _etiquetas = [];
  bool _saving = false;
  bool primeraLlamada = true;
  String _campania = '';
  int contactosAenviar = 0;

  @override
  void initState() {
    _archivoBloc.listar();
    _archivoBloc.archivoSeleccionada = new ArchivoModel();
    super.initState();
    if (widget.whatsappModel.idCampania != '') {
      List etiquetas = widget.whatsappModel.etiqueta.split(',');
      etiquetas.forEach((element) {
        _etiquetas.add(EtiquetaModel(etiqueta: element.toString().trim()));
      });
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.whatsappModel.alias}'),
        actions: [
          IconButton(
            padding: EdgeInsets.only(right: 10.0),
            icon: prs.iconoContactosMenu,
            onPressed: () {
              Navigator.pushNamed(context, 'contacto');
            },
          )
        ],
      ),
      body: ModalProgressHUD(
        inAsyncCall: _saving,
        child: Center(
            child: Container(child: _body(), width: prs.anchoFormulario)),
      ),
    );
  }

  Widget _body() {
    return Column(
      children: <Widget>[
        Expanded(child: SingleChildScrollView(child: _contenido())),
        btn.bootonIcon('ENVIAR', Icon(Icons.send_to_mobile), _enviarCampania),
      ],
    );
  }

  Column _contenido() {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(top: 15.0, left: 20.0, right: 5.0),
          child: Column(
            children: <Widget>[
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    _crearEtiqueta(),
                    SizedBox(height: 15.0),
                    _archivos(context),
                    SizedBox(height: 15.0),
                    _crearComentario(),
                    SizedBox(height: 20.0),
                    Text('Enviar WhatsApp de prueba a:'),
                    SizedBox(height: 20.0),
                    _crearCelular(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _archivos(BuildContext context) {
    return StreamBuilder(
      stream: _archivoBloc.archivoStream,
      builder:
          (BuildContext context, AsyncSnapshot<List<ArchivoModel>> snapshot) {
        if (snapshot.hasData) {
          return createExpanPanel(snapshot.data!);
        } else {
          return Container(child: Center(child: CircularProgressIndicator()));
        }
      },
    );
  }

  Widget createExpanPanel(List<ArchivoModel> archivos) {
    return DropdownButtonFormField(
      isDense: true,
      icon: _archivoBloc.archivoSeleccionada.idArchivo < 1
          ? Container()
          : cache.fadeImage(
              '${prefs.dominio}${_archivoBloc.archivoSeleccionada.archivo}'),
      iconSize: 40.0,
      decoration: prs.decoration(
          '',
          _archivoBloc.archivoSeleccionada.idArchivo < 1
              ? prs.iconoArchivos
              : null),
      hint: (_archivoBloc.archivoSeleccionada.idArchivo <= 0)
          ? Text('Adjuntar archivo')
          : Text(_archivoBloc.archivoSeleccionada.archivo),
      items: archivos.map((ArchivoModel archivo) {
        return DropdownMenuItem<ArchivoModel>(
          value: archivo,
          child: Text('${archivo.nombreVisible}'),
        );
      }).toList(),
      onChanged: (ArchivoModel? archivo) {
        _archivoBloc.archivoSeleccionada = archivo!;
        setState(() {});
      },
    );
  }

  Future<List<EtiquetaModel>> obteberEtiquetas(String query) async {
    List<EtiquetaModel> lista =
        await EtiquetasService.obtenerEtiquetas(query, primeraLlamada);
    primeraLlamada = false;
    return lista;
  }

  Widget _crearEtiqueta() {
    return FlutterTagging<EtiquetaModel>(
      initialItems: _etiquetas,
      textFieldConfiguration: TextFieldConfiguration(
        keyboardType: TextInputType.text,
        textCapitalization: TextCapitalization.none,
        decoration: InputDecoration(
          suffixIcon: IconButton(
            icon: Icon(Icons.live_help_sharp, size: 30, color: prs.colorIcons),
            onPressed: () {
              dlg.mostrar(context,
                  'Al seleccionar varias etiquetas, basta que un contacto tenga asignada una de ellas para enviarle el mensaje.');
            },
          ),
          border: InputBorder.none,
          filled: true,
          fillColor: Colors.green.withAlpha(30),
          hintText: 'e.g: nuevo cliente',
          labelText: 'Selecciona las etiquetas a enviar la campaña',
        ),
      ),
      findSuggestions: obteberEtiquetas,
      configureSuggestion: (lang) {
        return SuggestionConfiguration(
          title: Text(lang.etiqueta),
          leading: lang.nueva
              ? Icon(Icons.add_circle, color: Colors.red)
              : Icon(Icons.check, color: Colors.green),
        );
      },
      configureChip: (lang) {
        return ChipConfiguration(
          padding: EdgeInsets.all(5.0),
          labelPadding: EdgeInsets.all(0.0),
          label: Text('${lang.etiqueta}'),
          backgroundColor: ContactoModel().color('${lang.etiqueta}'),
          labelStyle: TextStyle(color: Colors.white),
          deleteIconColor: Colors.white,
        );
      },
    );
  }

  _enviarCampania() async {
    FocusScope.of(context).requestFocus(FocusNode());
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (!_pruebaEnviada)
      return dlg.mostrar(context,
          'Envía una prueba a un número especifico.\n\nEsto permite verificar la sesión.',
          titulo: 'PRECAUCIÓN', colorTitulo: Colors.red);
    _saving = true;
    setState(() {});
    contactosAenviar = await _whatsappProvider
        .verificar(EtiquetaModel().formaterLista(_etiquetas));

    _saving = false;
    setState(() {});

    if (contactosAenviar <= 0)
      return dlg.mostrar(context,
          'Ninguno de tus contactos tiene registrada ninguna de las etiquetas que has seleccionado.\n\nPor favor selecciona etiquetas que estes asignadas a mínimo un contacto.',
          titulo: 'ATERTA', colorTitulo: Colors.red);
    dlg.mostrar(context,
        'Tu campaña se enviará a $contactosAenviar contacto${contactosAenviar <= 1 ? "" : "s"}.\n\n¿Estás seguro de continuar?',
        fBotonIDerecha: _confirmarEnviarCampania,
        mBotonDerecha: 'SI, ENVIAR',
        mIzquierda: 'CANCELAR');
  }

  _confirmarEnviarCampania() async {
    Navigator.of(context).pop();
    _saving = true;
    setState(() {});
    await _whatsappProvider.enviar(
        contactosAenviar,
        widget.whatsappModel.alias,
        widget.whatsappModel.celular,
        EtiquetaModel().formaterLista(_etiquetas),
        _campania,
        _archivoBloc.archivoSeleccionada.archivo);
    _saving = false;
    Navigator.of(context).pop();
    widget.mostrarMnesjae('Campaña iniciada correctamente ↘');
  }

  bool _pruebaEnviada = false;

  _enviarPrueba() async {
    FocusScope.of(context).requestFocus(FocusNode());
    _formKey.currentState!.save();
    if (_whatsappPrueba.celularEnviar.length < 8) {
      if (!_formKey.currentState!.validate()) return;
    }

    if (_whatsappPrueba.celularEnviar.length < 8) {
      dlg.mostrar(context, 'Ingresa un numero de WhatsApp valido');
      return;
    }
    _saving = true;
    setState(() {});
    await _whatsappProvider.probar(
        widget.whatsappModel.celular,
        _whatsappPrueba.celularEnviar,
        _campania,
        _archivoBloc.archivoSeleccionada.archivo, (estado, error) {
      if (estado > 0) {
        _pruebaEnviada = true;
        dlg.mostrar(context, error,
            titulo: 'Mensaje enviado', colorTitulo: Colors.purple);
      } else {
        dlg.mostrar(context, error,
            titulo: 'Session no Autorizada', colorTitulo: Colors.red);
      }
    });
    _saving = false;
    setState(() {});
  }

  Widget _crearComentario() {
    return TextFormField(
      initialValue: widget.whatsappModel.mensaje,
      minLines: 3,
      maxLength: 500,
      textCapitalization: TextCapitalization.sentences,
      keyboardType: TextInputType.multiline,
      maxLines: null,
      decoration: prs.decoration('Mensaje', null),
      onSaved: (campania) => _campania = campania!,
      validator: (value) {
        if (value!.length < 20) return 'Mínimo 20 caracteres';
        return null;
      },
    );
  }

  _onChangedCelular(phone) {
    _whatsappPrueba.celular = phone.toString();
  }

  Widget _crearCelular() {
    return Row(
      children: [
        SizedBox(width: 5.0),
        Expanded(
          child: utils.crearCelular(prefs.simCountryCode, _onChangedCelular,
              celular: _whatsappPrueba.celular),
        ),
        RawMaterialButton(
          onPressed: _enviarPrueba,
          child: Icon(Icons.send, size: 28.0, color: prs.colorIcons),
        )
      ],
    );
  }
}
