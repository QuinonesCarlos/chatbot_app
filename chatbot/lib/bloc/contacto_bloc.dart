import 'dart:async';

import '../model/contacto_model.dart';
import '../providers/contacto_provider.dart';

class ContactoBloc {
  final ContactoProvider _contactoProvider = ContactoProvider();

  static ContactoBloc? _instancia;

  ContactoBloc._internal();

  factory ContactoBloc() {
    if (_instancia == null) {
      _instancia = ContactoBloc._internal();
    }
    return _instancia!;
  }

  List<ContactoModel> contactos = [];
  final contactosStreamController =
      StreamController<List<ContactoModel>>.broadcast();

  Function(List<ContactoModel>) get contactoSink =>
      contactosStreamController.sink.add;

  Stream<List<ContactoModel>> get contactoStream =>
      contactosStreamController.stream;

  int total = 0; //Elemetons que posee en total para paginar
  final isConsultandoStreamController = StreamController<int>.broadcast();

  Function(int) get isConsultandoSink => isConsultandoStreamController.sink.add;

  Stream<int> get isConsultandoStream => isConsultandoStreamController.stream;
  int consultando = 0;
  int pagina = 0;

  Future listar({bool isClean: false, String criterio: ''}) async {
    if (isClean) {
      pagina = 0;
      contactos.clear();
    }
    if (consultando == 1 && contactos.length > 0) return;
    if (total > 1 && contactos.length >= total) return;
    consultando = 1;
    isConsultandoSink(consultando);
    await _contactoProvider.listar(isClean, pagina, criterio,
        (_contactosResponse, _total) async {
      total = _total;
      if (contactos.length >= total) {
        consultando = -1;
      } else {
        consultando = 0;
      }
      isConsultandoSink(consultando);
      contactos.addAll(_contactosResponse);
    });
    return contactoSink(contactos);
  }

  Future eliminar(ContactoModel contactoModel) async {
    await _contactoProvider.eliminar(contactoModel);
    contactos.remove(contactoModel);
    total--;
    return contactoSink(contactos);
  }

  void disposeStreams() {
    contactosStreamController.close();
    isConsultandoStreamController.close();
  }
}
