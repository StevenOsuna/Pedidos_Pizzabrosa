class PedidoItem {
  final String paquete;
  final String tamano;
  final String notas;

  PedidoItem({
    required this.paquete,
    required this.tamano,
    required this.notas,
  });

  Map<String, dynamic> toJson() => {
    'paquete': paquete,
    'tamano': tamano,
    'notas': notas,
  };

  factory PedidoItem.fromJson(dynamic json) {
    final data = Map<String, dynamic>.from(json);
    return PedidoItem(
      paquete: data['paquete'] ?? '',
      tamano: data['tamano'] ?? '',
      notas: data['notas'] ?? '',
    );
  }
}

class Pedido {
  String? id;
  final String clienteNombre;
  final String clienteCel;
  final String clienteDireccion;
  final String estado;
  final int timestamp;
  final List<PedidoItem> items;

  Pedido({
    this.id,
    required this.clienteNombre,
    required this.clienteCel,
    required this.clienteDireccion,
    required this.estado,
    required this.timestamp,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
    'clienteNombre': clienteNombre,
    'clienteCel': clienteCel,
    'clienteDireccion': clienteDireccion,
    'estado': estado,
    'timestamp': timestamp,
    'items': items.map((i) => i.toJson()).toList(),
  };

  factory Pedido.fromJson(dynamic json, String id) {
    final data = Map<String, dynamic>.from(json);

    return Pedido(
      id: id,
      clienteNombre: data['clienteNombre'] ?? '',
      clienteCel: data['clienteCel'] ?? '',
      clienteDireccion: data['clienteDireccion'] ?? '',
      estado: data['estado'] ?? 'preparando',
      timestamp: data['timestamp'] ?? 0,
      items: (data['items'] as List<dynamic>? ?? [])
          .map((i) => PedidoItem.fromJson(i))
          .toList(),
    );
  }
}
