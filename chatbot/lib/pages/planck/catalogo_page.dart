import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../bloc/connect_bloc.dart';
import '../../bloc/whatsapp_bloc.dart';
import '../../card/shimmer_card.dart';
import '../../dialog/whatsappcelular_dialog.dart';
import '../../model/whatsapp_model.dart';
import '../../pages/planck/campania_page.dart';
import '../../preference/push_provider.dart';
import '../../preference/shared_preferences.dart';
import '../../providers/cliente_provider.dart';
import '../../utils/button.dart' as btn;
import '../../utils/dialog.dart' as dlg;
import '../../utils/permisos.dart' as permisos;
import '../../utils/personalizacion.dart' as prs;
import '../../utils/utils.dart' as utils;
import '../../widgets/en_linea_widget.dart';
import '../../widgets/menu_widget.dart';
import '../../widgets/modal_progress_hud.dart';

class CatalogoPage extends StatefulWidget {
  CatalogoPage();

  @override
  _CatalogoPageState createState() => _CatalogoPageState();
}

class _CatalogoPageState extends State<CatalogoPage>
    with WidgetsBindingObserver {
  final prefs = PreferenciasUsuario();

  final ConnectBloc _connectBloc = ConnectBloc();
  final StreamController<bool> _cambios = StreamController<bool>.broadcast();

  final ClienteProvider _clienteProvider = ClienteProvider();
  final WhatsappBloc _whatsappBloc = WhatsappBloc();
  final PushProvider _pushProvider = PushProvider();

  DateTime _dateTime = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  bool _saving = false;
  String title = 'Chatbot';
  int _selectedIndex = 0;

  late TextEditingController textControllerIp;

  @override
  void initState() {
    bool _init = false;
    textControllerIp = TextEditingController(text: prefs.dominio);
    _cambios.stream.listen((internet) {
      if (!mounted) return;
      if (internet && _init) {
        _whatsappBloc.listar(fecha);
      }
      _init = true;
    });
    WidgetsBinding.instance!.addObserver(this);
    _whatsappBloc.listar(fecha);
    super.initState();
    _pushProvider.context = context;
    _pushProvider.objects.listen((despacho) {
      if (!mounted) return;
      _whatsappBloc.listar(fecha);
    });
    _clienteProvider.actualizarToken().then((isActualizo) {
      permisos.verificarSession(context);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  void disposeStreams() {
    _cambios.close();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        permisos.verificarSession(context);
        _whatsappBloc.listar(fecha);
        _pushProvider.cancelAll();
        break;
      case AppLifecycleState.paused:
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MenuWidget(),
      appBar: AppBar(
        title: Text(title),
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
        color: Colors.black,
        opacity: 0.4,
        progressIndicator: utils.progressIndicator('Consultando...'),
        inAsyncCall: _saving,
        child: Center(child: Container(child: _body(), width: prs.ancho)),
      ),
      bottomNavigationBar: _bottomNavigationBar(),
    );
  }

  _bottomNavigationBar() {
    return BottomNavigationBar(
      items: _items(),
      showUnselectedLabels: true,
      unselectedItemColor: prs.colorButtonSecondary,
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.deepOrange,
      onTap: _onItemTapped,
    );
  }

  _items() {
    List<BottomNavigationBarItem> boton = [];
    boton.add(BottomNavigationBarItem(
        icon: Icon(FontAwesomeIcons.whatsapp), label: 'Inicio'));
    boton.add(BottomNavigationBarItem(
        icon: Icon(FontAwesomeIcons.addressCard), label: 'Campañas'));
    return boton;
  }

  String get fecha {
    if (_selectedIndex == 0) return '';
    return _dateTime.toString();
  }

  _onItemTapped(int index) async {
    _dateTime = DateTime.now();
    _selectedIndex = index;
    _saving = true;
    setState(() {});
    switch (index) {
      case 0:
        title = 'Chatbot';
        await _whatsappBloc.listar(fecha);
        break;
      case 1:
        title = 'Campañas';
        await _whatsappBloc.listar(fecha);
        break;
    }
    _saving = false;
    setState(() {});
  }

  _onRefrez() async {
    _saving = true;
    setState(() {});
    await _whatsappBloc.listar(fecha);
    _saving = false;
    setState(() {});
  }

  Widget _body() {
    return Column(
      children: <Widget>[
        EnLineaWidget(cambios: _cambios),
        _crearFecha(context),
        SizedBox(height: 15.0),
        Visibility(visible: _selectedIndex == 0, child: _crearDominio()),
        SizedBox(height: 15.0),
        Expanded(child: _tabCatalogo()),
        Visibility(
            visible: _selectedIndex == 0,
            child: btn.bootonIcon(
                'INGRESAR', Icon(Icons.qr_code), _registrarWhatssApp))
      ],
    );
  }

  configurarDominio() async {
    FocusScope.of(context).requestFocus(FocusNode());
    String dominio = textControllerIp.text.trim().toLowerCase();

    if (!dominio.startsWith('http')) {
      dominio = 'http://$dominio';
    }

    if (!dominio.endsWith('/') && dominio.length > 10) {
      dominio += '/';
    }

    prefs.dominio = dominio;
    textControllerIp.text = dominio;
    _connectBloc.verificar();
    _onRefrez();
  }

  Widget _crearDominio() {
    return TextFormField(
      maxLength: 200,
      maxLines: 1,
      textCapitalization: TextCapitalization.none,
      decoration: prs.decoration('Dominio || IP Servidor', null),
      onEditingComplete: configurarDominio,
      controller: textControllerIp,
    );
  }

  Widget _crearFecha(BuildContext context) {
    return Visibility(
      visible: _selectedIndex == 1,
      child: TableCalendar(
        calendarFormat: CalendarFormat.week,
        firstDay: DateTime.utc(2019, 1, 1),
        lastDay: DateTime.utc(2069, 1, 1),
        focusedDay: _focusedDay,
        locale: 'es',
        onDaySelected: (selectedDay, focusedDay) {
          _dateTime = selectedDay;
          _focusedDay = focusedDay;
          _onRefrez();
        },
      ),
    );
  }

  _registrarWhatssApp() async {
    if (prefs.isExplorar) return permisos.cerrasSesion(context);
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return WhatsappCelularDialog(WhatsappModel());
        });
  }

  Widget _tabCatalogo() {
    return Container(
      child: StreamBuilder(
        stream: _whatsappBloc.whatsappStream,
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
                    width: 220.0,
                    fit: BoxFit.cover),
              ),
            );
          } else {
            return ShimmerCard();
          }
        },
      ),
    );
  }

  Widget createListView(BuildContext context, AsyncSnapshot snapshot) {
    return RefreshIndicator(
      onRefresh: () => _whatsappBloc.listar(fecha),
      child: _selectedIndex == 0
          ? ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                return _card(context, snapshot.data[index]);
              },
            )
          : ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                return _cardSinSlider(context, snapshot.data[index]);
              },
            ),
    );
  }

  Widget _card(BuildContext context, WhatsappModel whatsappModel) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: _cardSinSlider(context, whatsappModel),
      secondaryActions: <Widget>[
        IconSlideAction(
          color: Colors.red,
          caption: 'Eliminar',
          icon: Icons.delete_outline_sharp,
          onTap: () async {
            _eliminar() {
              _eliminarWhatssApp(whatsappModel);
            }

            dlg.mostrar(context,
                '¿Seguro deseas eliminar el WhatsApp de ${whatsappModel.alias}?',
                icon: FontAwesomeIcons.trash,
                fBotonIDerecha: _eliminar,
                mBotonDerecha: 'SI, ELIMINAR',
                mIzquierda: 'REGRESAR');
          },
        ),
      ],
    );
  }

  _eliminarWhatssApp(WhatsappModel whatsappModel) async {
    Navigator.of(context).pop();
    _saving = true;
    setState(() {});
    await _whatsappBloc.eliminar(whatsappModel);
    _saving = false;
    setState(() {});
  }

  _cardSinSlider(BuildContext context, WhatsappModel whatsappModel) {
    return Column(
      children: <Widget>[
        ListTile(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        CampaniaPage(whatsappModel, mostrarMensaje)));
          },
          title: Text(whatsappModel.titulo,
              maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Container(
            margin: EdgeInsets.only(left: 14.0, top: 10.0),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(FontAwesomeIcons.whatsapp,
                        size: 12.0, color: Colors.black54),
                    SizedBox(width: 8.0),
                    Text('${whatsappModel.celularFormateado}'),
                  ],
                ),
                SizedBox(height: 3.0),
                Row(
                  children: <Widget>[
                    Icon(FontAwesomeIcons.doorOpen,
                        size: 9.0, color: Colors.black54),
                    SizedBox(width: 8.0),
                    Text(
                      '${whatsappModel.fechaRegistro}',
                      style: TextStyle(fontSize: 10.0),
                    ),
                  ],
                ),
                SizedBox(height: 3.0),
                Row(
                  children: <Widget>[
                    Icon(FontAwesomeIcons.sync,
                        size: 9.0, color: Colors.black54),
                    SizedBox(width: 8.0),
                    Text(
                      '${whatsappModel.pie}',
                      style: TextStyle(fontSize: 10.0),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Divider(),
      ],
    );
  }

  mostrarMensaje(String mensaje) async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.green,
      content: Text(mensaje, style: TextStyle(color: Colors.white)),
    ));
  }
}
