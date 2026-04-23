class Accidente {
  final String? clase;
  final String? gravedad;
  final String? barrio;
  final String? dia;
  final String? hora;
  final String? area;
  final String? vehiculo;

  Accidente({
    this.clase,
    this.gravedad,
    this.barrio,
    this.dia,
    this.hora,
    this.area,
    this.vehiculo,
  });

  factory Accidente.fromJson(Map<String, dynamic> json) {
    return Accidente(
      clase: json['clase_de_accidente'],
      gravedad: json['gravedad_del_accidente'],
      barrio: json['barrio_hecho'],
      dia: json['dia'],
      hora: json['hora'],
      area: json['area'],
      vehiculo: json['clase_de_vehiculo'],
    );
  }
}