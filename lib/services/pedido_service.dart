import 'package:firebase_database/firebase_database.dart';
import '../models/pedidos.dart';

class PedidoService {
  final DatabaseReference ref = FirebaseDatabase.instance.ref().child(
    "pedidos",
  );

  // Agregar pedido
  Future<void> agregarPedido(Pedido pedido) async {
    final newRef = ref.push();
    await newRef.set(pedido.toJson());
  }

  // Actualizar estado
  Future<void> actualizarEstado(String id, String estado) async {
    await ref.child(id).update({'estado': estado});
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
}
