class ArchivoModel {
  int idArchivo;
  String archivo;
  String detalle;

  ArchivoModel({
    this.idArchivo: -1,
    this.archivo: '',
    this.detalle: '',
  });

  String get nombreVisible {
    return detalle.substring(0, detalle.length > 32 ? 32 : detalle.length);
  }

  factory ArchivoModel.fromJson(Map<String, dynamic> json) => ArchivoModel(
        idArchivo: json["id_archivo"],
        archivo: json["archivo"],
        detalle: json["detalle"],
      );
}
