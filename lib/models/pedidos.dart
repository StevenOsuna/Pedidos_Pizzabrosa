import 'item_pedido.dart';

class Pedido {
  final String? id;
  final String clienteId; // referencia a Cliente
  final String clienteNombre; // para mostrar rápido en pantalla
  final List<ItemPedido> items; // pizzas solicitadas
  final String estado; // espera, siguiente, preparacion, entregado
  final int timestamp;
  final double total;

  Pedido({
    this.id,
    required this.clienteId,
    required this.clienteNombre,
    required this.items,
    required this.estado,
    required this.timestamp,
    required this.total,
  });

  Map<String, dynamic> toMap() {
    return {
      'clienteId': clienteId,
      'clienteNombre': clienteNombre,
      'items': items.map((i) => i.toMap()).toList(),
      'estado': estado,
      'timestamp': timestamp,
      'total': total,
    };
  }

  factory Pedido.fromMap(String id, Map<String, dynamic> data) {
    return Pedido(
      id: id,
      clienteId: data['clienteId'],
      clienteNombre: data['clienteNombre'],
      items: (data['items'] as List)
          .map((e) => ItemPedido.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      estado: data['estado'],
      timestamp: data['timestamp'],
      total: (data['total'] ?? 0).toDouble(),
    );
  }
}
