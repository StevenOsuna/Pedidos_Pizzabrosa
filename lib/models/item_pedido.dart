class ItemPedido {
  final String paquete; // mexicana, peperoni, hawaiana, champiñones
  final String tamano; // familiar, superpizza, megapizza
  final int cantidad;
  final String notas; // opcional, extras o indicaciones
  final double precio;

  ItemPedido({
    required this.paquete,
    required this.tamano,
    required this.cantidad,
    required this.notas,
    required this.precio,
  });

  Map<String, dynamic> toMap() {
    return {
      'paquete': paquete,
      'tamaño': tamano,
      'cantidad': cantidad,
      'notas': notas,
      'precio': precio,
    };
  }

  factory ItemPedido.fromMap(Map<String, dynamic> data) {
    return ItemPedido(
      paquete: data['paquete'],
      tamano: data['tamaño'],
      cantidad: data['cantidad'],
      notas: data['notas'] ?? '',
      precio: (data['precio'] ?? 0).toDouble(),
    );
  }
}
