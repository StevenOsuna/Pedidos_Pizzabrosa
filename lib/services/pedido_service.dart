import 'package:firebase_database/firebase_database.dart';
import '../models/pedidos.dart';

class PedidoService {
  final DatabaseReference ref = FirebaseDatabase.instance.ref().child(
    "pedidos",
  );

  final DatabaseReference refHistorial = FirebaseDatabase.instance.ref().child(
    "historial",
  );

  // Agregar pedido
  Future<void> agregarPedido(Pedido pedido) async {
    final newRef = ref.push();
    await newRef.set(pedido.toJson());
  }

  Future<void> moverAPedidosHistorial(Pedido pedido) async {
    if (pedido.id == null) return;

    await refHistorial.child(pedido.id!).set(pedido.toJson());
  }

  // Actualizar estado
  Future<void> actualizarEstado(String id, String estado) async {
    await ref.child(id).update({"estado": estado});
  }

  // Eliminar pedido
  Future<void> eliminarPedido(String id) async {
    await ref.child(id).remove();
  }

  // Stream en tiempo real
  Stream<List<Pedido>> obtenerPedidosTiempoReal() {
    return ref.onValue.map((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) return [];

      return data.entries.map((e) {
        return Pedido.fromJson(e.value, e.key);
      }).toList()..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    });
  }

  Stream<List<Pedido>> obtenerPedidosHistorial() {
    return ref.onValue.map((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) return [];

      final pedidos = data.entries.map((e) {
        return Pedido.fromJson(e.value, e.key);
      }).toList();

      // Ordenar por fecha, más reciente primero
      pedidos.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return pedidos;
    });
  }
}
