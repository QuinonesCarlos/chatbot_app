import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../utils/dialog.dart' as dlg;
import '../dialog/contacto_dialog.dart';
import '../model/contacto_model.dart';

class ContactoWidget extends StatefulWidget {
  final ContactoModel contacto;
  final Function eliminar;
  final Function mostrarMensaje;

  ContactoWidget(this.contacto, this.eliminar, this.mostrarMensaje);

  @override
  _ContactoWidgetState createState() => _ContactoWidgetState();
}

class _ContactoWidgetState extends State<ContactoWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _card(context, widget.contacto);
  }

  Widget _card(BuildContext context, ContactoModel contacto) {
    return Slidable(
      key: ValueKey(contacto.celular.toString()),
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: _tarjeta(context, contacto),
      secondaryActions: <Widget>[
        IconSlideAction(
          color: Colors.green,
          caption: 'Eliminar',
          icon: Icons.delete_outline_sharp,
          onTap: () {
            dlg.mostrar(context,
                '¿Seguro deseas eliminar el contacto ${contacto.nombre}?',
                icon: FontAwesomeIcons.trash,
                fBotonIDerecha: eliminarContacto,
                mBotonDerecha: 'SI, ELIMINAR',
                mIzquierda: 'REGRESAR');
          },
        ),
      ],
    );
  }

  eliminarContacto() {
    widget.eliminar(widget.contacto);
  }

  Widget _tarjeta(BuildContext context, ContactoModel contacto) {
    final tarjeta = Container(
      margin: EdgeInsets.only(top: 5, left: 10.0, right: 10.0, bottom: 10.0),
      padding: EdgeInsets.only(left: 10.0, top: 5, bottom: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.white,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black26,
            blurRadius: 0.0,
            spreadRadius: 0.0,
            offset: Offset(0.1, 0.1),
          ),
        ],
      ),
      child: Stack(
        children: <Widget>[_contenidoLista(contacto, context)],
      ),
    );

    return Stack(
      children: <Widget>[
        tarjeta,
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              splashColor: Colors.blueAccent.withOpacity(0.6),
              onTap: () async {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ContactoDialog(contacto, widget.mostrarMensaje)));
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _contenidoLista(ContactoModel contacto, BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(contacto.celular,
                overflow: TextOverflow.visible,
                maxLines: 1,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            SizedBox(width: 5.0),
            Text(contacto.nombre,
                overflow: TextOverflow.visible,
                maxLines: 1,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
        SizedBox(height: 5.0),
        contacto.etiquetas(context),
        SizedBox(height: 5.0),
      ],
    );
  }
}
