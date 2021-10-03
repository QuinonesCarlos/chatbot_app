import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../utils/validar.dart' as val;
import '../bloc/archivo_bloc.dart';
import '../bloc/foto_bloc.dart';
import '../model/archivo_model.dart';
import '../preference/shared_preferences.dart';
import '../providers/archivo_provider.dart';
import '../sistema.dart';
import '../utils/button.dart' as btn;
import '../utils/cache.dart' as cache;
import '../utils/personalizacion.dart' as prs;
import '../utils/utils.dart' as utils;

class FotoArchivoDialog extends StatefulWidget {
  final ArchivoModel archivo;

  FotoArchivoDialog(this.archivo) : super();

  FotoArchivoDialogState createState() => FotoArchivoDialogState(archivo);
}

class FotoArchivoDialogState extends State<FotoArchivoDialog> {
  final ArchivoModel archivo;
  final ArchivoProvider _archivoProvider = ArchivoProvider();
  final ArchivoBloc _archivoBloc = ArchivoBloc();
  final FotoBloc _fotoBloc = FotoBloc();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  FotoArchivoDialogState(this.archivo);

  @override
  void initState() {
    _fotoBloc.imageFile = null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(archivo.archivo),
      ),
      body:
          Center(child: Container(child: _body(), width: prs.anchoFormulario)),
    );
  }

  Widget _body() {
    return Column(
      children: <Widget>[
        Expanded(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _crearDetalle(),
                    SizedBox(height: 20.0),
                    btn.bootonIcon('ADJUNTAR ARCHIVO', Icon(Icons.file_upload),
                        archivo.idArchivo <= 0 ? _subirFoto : null),
                    StreamBuilder(
                      stream: _fotoBloc.fotoStream,
                      builder: (BuildContext context, snapshot) {
                        return ClipRRect(
                          child: _imagen(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        btn.confirmar('ESTABLECER CAMBIOS', _cambiarFoto),
      ],
    );
  }

  Widget _crearDetalle() {
    return TextFormField(
        maxLength: 45,
        maxLines: 1,
        initialValue: archivo.detalle,
        textCapitalization: TextCapitalization.words,
        decoration: prs.decoration('Detalle', null),
        onSaved: (value) => archivo.detalle = value!,
        validator: val.validarMinimo3);
  }

  PickedFile? pickedFile;
  final picker = ImagePicker();
  String? _nombreImagen;
  final PreferenciasUsuario prefs = PreferenciasUsuario();

  Widget _imagen() {
    if (fileWeb != null && Sistema.isWeb) return Image.network(fileWeb!.path);
    if (_fotoBloc.imageFile != null)
      return Image.file(_fotoBloc.imageFile!, fit: BoxFit.cover);
    return cache.fadeImage(
      '${prefs.dominio}${archivo.archivo}',
    );
  }

  XFile? fileWeb;

  _subirFoto() async {
    try {
      _fotoBloc.fotoSink(true);
      fileWeb = await picker.pickImage(source: ImageSource.gallery);
      _fotoBloc.imageFile = File(fileWeb!.path);
      if (_fotoBloc.imageFile == null) return;
      _fotoBloc.fotoSink(false);
    } catch (exception) {
      print(exception);
    }
  }

  _cambiarFoto() async {
    FocusScope.of(context).requestFocus(FocusNode());
    _formKey.currentState!.save();
    if (!_formKey.currentState!.validate()) return '';

    if (archivo.idArchivo <= 0) {
      _nombreImagen = '${DateTime.now().microsecondsSinceEpoch.toString()}';
      if (_fotoBloc.imageFile == null) return;
      utils.mostrarProgress(context, barrierDismissible: false);
      if (Sistema.isWeb) {
        await _archivoProvider.subirWeb(await fileWeb!.readAsBytes(),
            _nombreImagen, archivo.detalle.toString());
      } else
        await _archivoProvider.subirMovil(
            _fotoBloc.imageFile!, _nombreImagen, archivo.detalle.toString());
    } else {
      utils.mostrarProgress(context, barrierDismissible: false);
      await _archivoProvider.editar(archivo);
    }
    await _archivoBloc.listar();
    Navigator.pop(context);
    Navigator.pop(context);
  }
}
