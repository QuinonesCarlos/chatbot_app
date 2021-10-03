import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../bloc/archivo_bloc.dart';
import '../../card/archivo_card.dart';
import '../../card/shimmer_card.dart';
import '../../dialog/foto_archivo_dialog.dart';
import '../../model/archivo_model.dart';
import '../../providers/archivo_provider.dart';
import '../../utils/dialog.dart' as dlg;
import '../../utils/personalizacion.dart' as prs;
import '../../utils/utils.dart' as utils;
import '../../widgets/modal_progress_hud.dart';

class ArchivosPage extends StatefulWidget {
  ArchivosPage() : super();

  @override
  _ArchivosPageState createState() => _ArchivosPageState();
}

class _ArchivosPageState extends State<ArchivosPage> {
  final ArchivoBloc _archivoBloc = ArchivoBloc();
  final _archivoProvider = ArchivoProvider();

  bool _isLineProgress = false;
  bool _saving = false;

  _ArchivosPageState();

  @override
  void initState() {
    _archivoBloc.listar();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Archivos'),
        actions: [
          IconButton(
            padding: EdgeInsets.only(right: 10.0),
            onPressed: () {
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    return FotoArchivoDialog(new ArchivoModel());
                  });
            },
            icon: Icon(Icons.add_a_photo_outlined, size: 30.0),
          ),
        ],
      ),
      body: ModalProgressHUD(
        color: Colors.black,
        opacity: 0.4,
        progressIndicator: utils.progressIndicator('Eliminando...'),
        inAsyncCall: _saving,
        child: Center(
            child: Container(child: _body(), width: prs.anchoFormulario)),
      ),
    );
  }

  Widget _body() {
    return Column(
      children: <Widget>[
        Visibility(
            visible: _isLineProgress,
            child: LinearProgressIndicator(
                backgroundColor: prs.colorLinearProgress)),
        SizedBox(height: 10.0),
        Expanded(child: _listaCar(context)),
      ],
    );
  }

  Widget _listaCar(context) {
    return Container(
      child: StreamBuilder(
        stream: _archivoBloc.archivoStream,
        builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.length > 0)
              return createListView(context, snapshot);
            return Container(
              margin: EdgeInsets.all(80.0),
              width: double.infinity,
              height: double.infinity,
              child: Center(
                child: Image(
                  image: AssetImage('assets/chatbot.png'),
                  fit: BoxFit.cover,
                ),
              ),
            );
          } else {
            return ShimmerCard();
          }
        },
      ),
    );
  }

  List<Widget> _listaOrdenar = [];

  Widget createListView(BuildContext context, AsyncSnapshot snapshot) {
    _listaOrdenar.clear();
    for (var item in snapshot.data) _listaOrdenar.add(_card(context, item));
    return RefreshIndicator(
      onRefresh: () => _archivoBloc.listar(),
      child: ReorderableListView(
        children: _listaOrdenar,
        onReorder: (int desde, int hasta) async {
          ArchivoModel _archivoAux;
          if (desde < hasta) {
            _archivoAux = _archivoBloc.archivos[desde];
            _archivoBloc.archivos.removeAt(desde);
            _archivoBloc.archivos.insert(hasta - 1, _archivoAux);
          } else {
            _archivoAux = _archivoBloc.archivos[desde];
            _archivoBloc.archivos.removeAt(desde);
            _archivoBloc.archivos.insert(hasta, _archivoAux);
          }
          String ids = '';
          for (var _archivo in _archivoBloc.archivos)
            ids += '${_archivo.idArchivo}-';
          setState(() {});
          _isLineProgress = true;
          setState(() {});
          await _archivoProvider.ordenar(ids);
          _isLineProgress = false;
          if (!mounted) return;
          setState(() {});
        },
      ),
    );
  }

  _onTap(ArchivoModel archivoModel) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return FotoArchivoDialog(archivoModel);
        });
  }

  mostraCargando() {
    _saving = true;
    setState(() {});
  }

  quitarCargando() {
    _saving = false;
    setState(() {});
  }

  Widget _card(BuildContext context, ArchivoModel archivoModel) {
    return Slidable(
      key: ValueKey(archivoModel.idArchivo),
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: ArchivoCard(archivoModel: archivoModel, onTab: _onTap),
      actions: <Widget>[],
      secondaryActions: <Widget>[
        IconSlideAction(
          color: Colors.red,
          caption: 'Eliminar',
          icon: Icons.delete,
          onTap: () {
            _enviarCancelar() async {
              Navigator.of(context).pop();
              mostraCargando();
              await _archivoBloc.eliminar(archivoModel);
              quitarCargando();
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Archivo eliminado correctamente")));
            }

            dlg.mostrar(context, 'Esta acción no se puede revertir!',
                fBotonIDerecha: _enviarCancelar, mBotonDerecha: 'ELIMINAR');
          },
        ),
      ],
    );
  }
}
