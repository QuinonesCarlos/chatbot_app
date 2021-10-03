class WhatsappModel {
  String celular;
  String fechaRegistro;
  String fechaActualizo;

  String idCampania;
  String etiqueta;
  String campania;
  String alias;
  int aEnviar;
  int enviadas;

  WhatsappModel({
    this.idCampania: '',
    this.alias: '',
    this.celular: '',
    this.fechaRegistro: '',
    this.fechaActualizo: '',
    this.etiqueta: '',
    this.campania: '',
    this.aEnviar: 0,
    this.enviadas: 0,
  });

  factory WhatsappModel.fromJson(Map<String, dynamic> json) => WhatsappModel(
        alias: json["alias"],
        celular: json["celular"],
        fechaRegistro:
            json["fecha_registro"] == null ? '' : json["fecha_registro"],
        fechaActualizo:
            json["fecha_actualizo"] == null ? '' : json["fecha_actualizo"],
        idCampania: json["id_campania"] == null ? '' : '${json["id_campania"]}',
        etiqueta: json["etiqueta"] == null ? '' : json["etiqueta"],
        campania: json["campania"] == null ? '' : json["campania"],
        aEnviar: json["a_enviar"] == null ? 0 : json["a_enviar"],
        enviadas: json["enviadas"] == null ? 0 : json["enviadas"],
      );

  get mensaje {
    if (idCampania == '') return '';
    return campania;
  }

  get titulo {
    if (idCampania == '') return alias;
    if (campania.length <= 40) return campania;
    return '${campania.toString()}';
  }

  get pie {
    if (idCampania == '') return fechaActualizo;
    return '$enviadas / $aEnviar';
  }

  get celularFormateado {
    return celular.replaceAllMapped(
        RegExp(r".{4}"), (match) => "${match.group(0)} ");
  }

  get celularEnviar {
    return celular.replaceAll(' ', '').replaceAll("+", '');
  }
}
