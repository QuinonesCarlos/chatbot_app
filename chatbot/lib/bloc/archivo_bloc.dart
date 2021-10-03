import 'dart:async';

import '../model/archivo_model.dart';
import '../providers/archivo_provider.dart';

class ArchivoBloc {
  final ArchivoProvider _archivoProvider = ArchivoProvider();
  ArchivoModel archivoSeleccionada = ArchivoModel();

  List<ArchivoModel> archivos = [];

  static ArchivoBloc? _instancia;

  ArchivoBloc._internal();

  factory ArchivoBloc() {
    if (_instancia == null) {
      _instancia = ArchivoBloc._internal();
    }
    return _instancia!;
  }

  final archivoesStreamController =
      StreamController<List<ArchivoModel>>.broadcast();

  Function(List<ArchivoModel>) get archivoSink =>
      archivoesStreamController.sink.add;

  Stream<List<ArchivoModel>> get archivoStream =>
      archivoesStreamController.stream;

  Future<List<ArchivoModel>> listar() async {
    final archivoesResponse = await _archivoProvider.listar();
    archivos.clear();
    archivos.addAll(archivoesResponse);
    archivoSink(archivos);
    return archivoesResponse;
  }

  Future eliminar(ArchivoModel archivoModel) async {
    await _archivoProvider.eliminar(archivoModel);
    archivos.remove(archivoModel);
    archivoSink(archivos);
    return;
  }

  void disposeStreams() {
    archivoesStreamController.close();
  }
}
