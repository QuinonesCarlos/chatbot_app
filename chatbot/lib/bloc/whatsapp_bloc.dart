import 'dart:async';

import '../model/whatsapp_model.dart';
import '../providers/whatsapp_provider.dart';

class WhatsappBloc {
  final WhatsappProvider _whatsappProvider = WhatsappProvider();
  WhatsappModel whatsappSeleccionada = WhatsappModel();

  List<WhatsappModel> whatsapps = [];

  static WhatsappBloc? _instancia;

  WhatsappBloc._internal();

  factory WhatsappBloc() {
    if (_instancia == null) {
      _instancia = WhatsappBloc._internal();
    }
    return _instancia!;
  }

  final whatsappsStreamController =
      StreamController<List<WhatsappModel>>.broadcast();

  Function(List<WhatsappModel>) get whatsappSink =>
      whatsappsStreamController.sink.add;

  Stream<List<WhatsappModel>> get whatsappStream =>
      whatsappsStreamController.stream;

  Future<List<WhatsappModel>> listar(String fecha) async {
    final whatsappsResponse = await _whatsappProvider.listar(fecha);
    whatsapps.clear();
    whatsapps.addAll(whatsappsResponse);
    whatsappSink(whatsapps);
    return whatsappsResponse;
  }

  Future eliminar(WhatsappModel whatsappModel) async {
    await _whatsappProvider.eliminar(whatsappModel);
    whatsapps.remove(whatsappModel);
    return whatsappSink(whatsapps);
  }

  void disposeStreams() {
    whatsappsStreamController.close();
  }
}
