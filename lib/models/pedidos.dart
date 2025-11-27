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
    'tamaño': tamano,
    'notas': notas,
  };

  factory PedidoItem.fromJson(Map<String, dynamic> json) => PedidoItem(
    paquete: json['paquete'],
    tamano: json['tamaño'],
    notas: json['notas'],
  );
}

class Pedido {
  String? id;
  final String clienteNombre;
  final String clienteCel;
  final String clienteDireccion;
  final String estado; // preparacion / siguiente / espera / entregado
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

  factory Pedido.fromJson(Map<String, dynamic> json, String id) => Pedido(
    id: id,
    clienteNombre: json['clienteNombre'],
    clienteCel: json['clienteCel'],
    clienteDireccion: json['clienteDireccion'],
    estado: json['estado'],
    timestamp: json['timestamp'],
    items: (json['items'] as List<dynamic>)
        .map((i) => PedidoItem.fromJson(i))
        .toList(),
  );
}
