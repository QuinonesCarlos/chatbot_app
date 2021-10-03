import '../libs/flutter_tagging/taggable.dart';
import '../providers/etiqueta_provider.dart';

class EtiquetaModel extends Taggable {
  final String etiqueta;
  final bool nueva;

  EtiquetaModel({this.etiqueta: '', this.nueva: false});

  factory EtiquetaModel.fromJson(Map<String, dynamic> json) =>
      EtiquetaModel(etiqueta: json["etiqueta"]);

  @override
  List<Object> get props => [etiqueta];

  @override
  String toString() {
    return '${this.etiqueta}'
        .trim()
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll('__', '_')
        .replaceAll('__', '_');
  }

  String formaterLista(List<EtiquetaModel> etiquetas) {
    return etiquetas
        .toString()
        .replaceFirst('[', '')
        .replaceAll(']', '')
        .toLowerCase()
        .trim();
  }
}

EtiquetaProvider _etiquetaProvider = EtiquetaProvider();
List<EtiquetaModel> listEtiquetaServerAux = [];

List<EtiquetaModel> listEtiquetaServerCall = [];

class EtiquetasService {
  static Future<List<EtiquetaModel>> obtenerEtiquetas(
      String query, bool primeraLlamada) async {
    query =
        query.trim().toLowerCase().replaceAll(' ', '_').replaceAll('__', '_');

    if (primeraLlamada)
      listEtiquetaServerCall = await _etiquetaProvider.listar();

    listEtiquetaServerAux.clear();
    listEtiquetaServerAux.addAll(listEtiquetaServerCall);

    if (query.length < 4) return listEtiquetaServerAux;
    List<EtiquetaModel> listReturn = <EtiquetaModel>[
      EtiquetaModel(etiqueta: query, nueva: true)
    ];
    listReturn.addAll(listEtiquetaServerAux);
    return listReturn
        .where((etiqueta) => etiqueta.etiqueta.toLowerCase().contains(query))
        .toList();
  }
}
