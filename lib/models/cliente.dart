class Cliente {
  final String? id;
  final String nombre;
  final String telefono;
  final String direccion;

  Cliente({
    this.id,
    required this.nombre,
    required this.telefono,
    required this.direccion,
  });

  Map<String, dynamic> toMap() {
    return {'nombre': nombre, 'telefono': telefono, 'direccion': direccion};
  }

  factory Cliente.fromMap(String id, Map<String, dynamic> data) {
    return Cliente(
      id: id,
      nombre: data['nombre'],
      telefono: data['telefono'],
      direccion: data['direccion'],
    );
  }
}
