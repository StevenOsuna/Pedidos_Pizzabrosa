class Cliente {
  String? id;
  final String nombre;
  final String cel;
  final String direccion;
  final int timestamp;

  Cliente({
    this.id,
    required this.nombre,
    required this.cel,
    required this.direccion,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    "nombre": nombre,
    "cel": cel,
    "direccion": direccion,
    "timestamp": timestamp,
  };

  factory Cliente.fromJson(Map json, String id) {
    return Cliente(
      id: id,
      nombre: json["nombre"],
      cel: json["cel"],
      direccion: json["direccion"],
      timestamp: json["timestamp"],
    );
  }
}
