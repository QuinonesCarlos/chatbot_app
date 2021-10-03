class SessionModel {
  int actual;
  String fechaActualizo;
  String fechaInicio;
  int idPlataforma;
  String imei;
  String ciudad;
  String pais;
  String marca;

  SessionModel({
    required this.actual,
    required this.fechaActualizo,
    required this.fechaInicio,
    required this.idPlataforma,
    required this.imei,
    required this.ciudad,
    required this.pais,
    required this.marca,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) => SessionModel(
        actual: json["actual"],
        fechaActualizo: json["fecha_actualizo"],
        fechaInicio: json["fecha_inicio"],
        idPlataforma: json["id_plataforma"],
        imei: json["imei"],
        ciudad: json["ciudad"],
        pais: json["pais"],
        marca: json["marca"],
      );
}
