import '../utils/cache.dart' as cache;

class ClienteModel {
  String idCliente;
  String celular;
  String correo;
  String nombres;
  String apellidos;
  int sexo;
  String clave;
  String cedula;
  int celularValidado;
  int correoValidado;
  String img;
  String codigoPais;
  String link;
  String fechaNacimiento;
  double calificacion;
  int calificaciones, registros, puntos, correctos, canceladas;

  ClienteModel({
    this.sexo: 0,
    this.idCliente: '',
    this.celular: '',
    this.correo: '',
    this.nombres: '',
    this.apellidos: '',
    this.clave: '*********',
    this.cedula: '',
    this.celularValidado: 0,
    this.correoValidado: 0,
    this.img: '',
    this.codigoPais: '',
    this.calificacion: 5.0,
    this.calificaciones: 1,
    this.registros: 0,
    this.puntos: 0,
    this.correctos: 0,
    this.canceladas: 0,
    this.fechaNacimiento: '',
    this.link: '',
  });

  factory ClienteModel.fromJson(Map<String, dynamic> json) => ClienteModel(
        sexo: json["sexo"],
        idCliente: '${json["id_cliente"]}',
        celular: json["celular"] == null ? '' : '${json["celular"]}',
        correo: json["correo"],
        nombres: json["nombres"],
        apellidos: json["apellidos"] == null ? '' : json["apellidos"],
        cedula: json["cedula"] == null ? '' : json["cedula"],
        celularValidado: json["celularValidado"],
        correoValidado: json["correoValidado"],
        img: cache.img(json["img"]),
        codigoPais: json["codigoPais"] == null ? '' : json["codigoPais"],
        calificacion: json["calificacion"] == null
            ? 0.0
            : json["calificacion"].toDouble(),
        calificaciones: json["calificaciones"],
        registros: json["registros"],
        puntos: json["puntos"],
        correctos: json["correctos"],
        canceladas: json["canceladas"],
        fechaNacimiento:
            json["fecha_nacimiento"] == null ? '' : json["fecha_nacimiento"],
        link: json["link"] == null ? '' : json["link"],
      );
}
