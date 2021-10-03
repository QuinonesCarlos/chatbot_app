import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import '../../utils/dialog.dart' as dlg;
import '../../widgets/modal_progress_hud.dart';
import '../bloc/contacto_bloc.dart';
import '../libs/flutter_tagging/configurations.dart';
import '../libs/flutter_tagging/tagging.dart';
import '../model/contacto_model.dart';
import '../model/etiqueta_model.dart';
import '../preference/shared_preferences.dart';
import '../providers/contacto_provider.dart';
import '../utils/button.dart' as btn;
import '../utils/personalizacion.dart' as prs;
import '../utils/utils.dart' as utils;

class ContactoDialog extends StatefulWidget {
  final ContactoModel contacto;
  final Function mostrarMensaje;

  ContactoDialog(this.contacto, this.mostrarMensaje);

  @override
  _ContactoDialogState createState() => _ContactoDialogState();
}

class _ContactoDialogState extends State<ContactoDialog> {
  final prefs = PreferenciasUsuario();
  final ContactoBloc _contactoBloc = ContactoBloc();
  final ContactoProvider _contactoProvider = ContactoProvider();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<EtiquetaModel> _etiquetas = [];
  bool _saving = false;
  bool primeraLlamada = true;

  @override
  void initState() {
    super.initState();
    if (widget.contacto.etiqueta != '') {
      List etiquetas = widget.contacto.etiqueta.split(',');
      etiquetas.forEach((element) {
        _etiquetas.add(EtiquetaModel(etiqueta: element.toString().trim()));
        print(element);
      });
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        actions: [
          IconButton(
            padding: EdgeInsets.only(right: 10.0),
            icon: Icon(
              Icons.live_help_sharp,
              size: 30,
            ),
            onPressed: () {
              dlg.mostrar(context,
                  'Las etiquetas sirven para segmentar tus campañas.\n\nLas etiquetas formadas por dos palabras, se reemplazará el espacio por un guion bajo (_). E.g.: nuevo cliente se convierte en nuevo_cliente.\n\nUn cliente puede tener varias etiquetas.  ');
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

  _onChangedCelular(phone) {
    widget.contacto.celular = phone;
  }

  Widget _crearCelular() {
    if (widget.contacto.nombre.length >= 4)
      return TextFormField(
        keyboardType: TextInputType.phone,
        initialValue: widget.contacto.celular,
        validator: (value) {
          if (value!.trim().length < 4) return 'Mínimo 4 caracteres';
          return null;
        },
        onSaved: (value) {
          widget.contacto.celular = value!;
        },
        decoration: prs.decoration('Celular', prs.iconoContactos),
      );
    return Row(
      children: [
        SizedBox(width: 10.0),
        Expanded(
          child: utils.crearCelular(prefs.simCountryCode, _onChangedCelular,
              celular: widget.contacto.celular),
        )
      ],
    );
  }

  Widget _crearNombre() {
    return TextFormField(
      keyboardType: TextInputType.name,
      textCapitalization: TextCapitalization.words,
      initialValue: widget.contacto.nombre,
      validator: (value) {
        if (value!.trim().length < 4) return 'Mínimo 4 caracteres';
        return null;
      },
      onSaved: (value) {
        widget.contacto.nombre = value!;
      },
      decoration: prs.decoration('Nombres', prs.iconoNombres),
    );
  }

  Future<List<EtiquetaModel>> obteberEtiquetas(String query) async {
    List<EtiquetaModel> lista =
        await EtiquetasService.obtenerEtiquetas(query, primeraLlamada);
    primeraLlamada = false;
    return lista;
  }

  Widget _crearEtiqueta() {
    //  return Container();
    return FlutterTagging<EtiquetaModel>(
      initialItems: _etiquetas,
      textFieldConfiguration: TextFieldConfiguration(
        keyboardType: TextInputType.text,
        textCapitalization: TextCapitalization.none,
        decoration: InputDecoration(
          border: InputBorder.none,
          filled: true,
          fillColor: Colors.green.withAlpha(30),
          hintText: 'e.g: nuevo cliente',
          labelText: 'Etiquetas',
        ),
      ),
      findSuggestions: obteberEtiquetas,
      configureSuggestion: (lang) {
        return SuggestionConfiguration(
          title: Text(lang.etiqueta),
          leading:
              lang.nueva ? Icon(Icons.add_circle, color: Colors.green) : null,
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _crearNombre(),
                    SizedBox(height: 20.0),
                    _crearCelular(),
                    SizedBox(height: 20.0),
                    _crearInfo(),
                    _crearEtiqueta(),
                    SizedBox(height: 55.0),
                  ],
                ),
              ),
            ),
          ),
        ),
        btn.bootonIcon('ESTABLECER CAMBIOS', Icon(Icons.save), _registrar),
      ],
    );
  }

  Widget _crearInfo() {
    if (widget.contacto.celular.length > 8) return Container();
    return Column(
      children: [
        Text('Escribe tus etiquetas. Al tocarla se asignará',
            style: TextStyle(color: Colors.red)),
        SizedBox(height: 15.0),
      ],
    );
  }

  _registrar() async {
    FocusScope.of(context).requestFocus(FocusNode());
    _formKey.currentState!.save();
    if (!_formKey.currentState!.validate()) return;
    if (widget.contacto.celular.length <= 8) return;
    widget.contacto.etiqueta = EtiquetaModel().formaterLista(
        _etiquetas..sort((a, b) => a.etiqueta.compareTo(b.etiqueta)));
    _saving = true;
    setState(() {});
    await _contactoProvider.registrar(widget.contacto);
    await _contactoBloc.listar(isClean: true);
    _saving = false;
    Navigator.of(context).pop();
    widget.mostrarMensaje('Cambios establecidos correctamente 🔝');
  }
}
