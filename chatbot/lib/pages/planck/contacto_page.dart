import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../bloc/contacto_bloc.dart';
import '../../card/shimmer_card.dart';
import '../../dialog/contacto_dialog.dart';
import '../../model/contacto_model.dart';
import '../../preference/shared_preferences.dart';
import '../../utils/permisos.dart' as permisos;
import '../../utils/personalizacion.dart' as prs;
import '../../utils/utils.dart' as utils;
import '../../widgets/contacto_widget.dart';
import '../../widgets/modal_progress_hud.dart';

class ContactoPage extends StatefulWidget {
  ContactoPage({Key? key}) : super(key: key);

  @override
  _ContactoPageState createState() => _ContactoPageState();
}

class _ContactoPageState extends State<ContactoPage> {
  final ContactoBloc _contactoBloc = ContactoBloc();
  final ScrollController pageController = ScrollController();
  final prefs = PreferenciasUsuario();

  late TextEditingController _textControllerCriterio;
  bool _saving = false;

  @override
  void initState() {
    _contactoBloc.pagina = 0;
    _textControllerCriterio = TextEditingController(text: '');
    pageController.addListener(() async {
      if (_contactoBloc.consultando != 0) return;
      if (pageController.position.pixels >=
          pageController.position.maxScrollExtent - 50) {
        _contactoBloc.pagina++;
        _contactoBloc.listar(isClean: false);
      }
    });
    super.initState();
    _contactoBloc.listar(isClean: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.0,
        title: StreamBuilder(
          stream: _contactoBloc.isConsultandoStream,
          builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
            return Text('Contactos (${_contactoBloc.total})',
                overflow: TextOverflow.clip);
          },
        ),
        actions: [
          IconButton(
            padding: EdgeInsets.only(right: 10.0),
            icon: prs.iconoContacto,
            onPressed: () {
              if (prefs.isExplorar) return permisos.cerrasSesion(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ContactoDialog(ContactoModel(), mostrarMensaje)));
            },
          )
        ],
      ),
      body: ModalProgressHUD(
        color: Colors.black,
        opacity: 0.4,
        progressIndicator: utils.progressIndicator('Consultando...'),
        inAsyncCall: _saving,
        child: Center(
            child: Container(child: _contactos(context), width: prs.ancho)),
      ),
    );
  }

  buscar(String value) async {
    if (value.length < 3) return;
    filtrar();
  }

  filtrar() async {
    FocusScope.of(context).requestFocus(FocusNode());
    _saving = true;
    setState(() {});
    await _contactoBloc.listar(
        isClean: true, criterio: _textControllerCriterio.text);
    _saving = false;
    setState(() {});
  }

  Widget _crearBuscador() {
    return Visibility(
      visible: true,
      child: Container(
        padding: EdgeInsets.only(left: 17.0, right: 15.0, bottom: 10.0),
        child: TextField(
            onEditingComplete: filtrar,
            controller: _textControllerCriterio,
            decoration: prs.decorationSearch('Buscar por etiquetas o nombres')),
      ),
    );
  }

  Widget _contactos(BuildContext context) {
    return StreamBuilder(
      stream: _contactoBloc.contactoStream,
      builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.length <= 0) {
            return Column(children: [
              SizedBox(height: 10.0),
              _crearBuscador(),
              Center(
                child: Image(
                  width: 150,
                  image: AssetImage('assets/screen/senialar.png'),
                  fit: BoxFit.cover,
                ),
              ),
              Text(
                'Agrega contactos nuevos tocando el icono superior derecho',
                textAlign: TextAlign.center,
              ),
            ]);
          }
          return Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  controller: pageController,
                  slivers: <Widget>[
                    SliverToBoxAdapter(child: SizedBox(height: 10.0)),
                    SliverToBoxAdapter(child: _crearBuscador()),
                    SliverGrid(
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 500.0,
                        childAspectRatio: 4.2,
                        mainAxisSpacing: 0.0,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return ContactoWidget(snapshot.data![index],
                              eliminarContacto, mostrarMensaje);
                        },
                        childCount: snapshot.data!.length,
                      ),
                    ),
                    SliverToBoxAdapter(
                        child: StreamBuilder(
                      stream: _contactoBloc.isConsultandoStream,
                      builder:
                          (BuildContext context, AsyncSnapshot<int> snapshot) {
                        if (snapshot.hasData && snapshot.data == 1)
                          return ShimmerCard();
                        return SizedBox(height: 80.0);
                      },
                    )),
                    SliverPadding(padding: const EdgeInsets.only(bottom: 80.0))
                  ],
                ),
              ),
            ],
          );
        } else {
          return Column(children: [ShimmerCard(), ShimmerCard()]);
        }
      },
    );
  }

  eliminarContacto(ContactoModel contactoModel) async {
    Navigator.of(context).pop();
    _saving = true;
    setState(() {});
    await _contactoBloc.eliminar(contactoModel);
    _saving = false;
    setState(() {});
  }

  mostrarMensaje(String mensaje) async {
    await Future.delayed(Duration(milliseconds: 500), null);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.green,
      content: Text(mensaje, style: TextStyle(color: Colors.white)),
    ));
  }
}
