import 'package:firebase_database/firebase_database.dart';
import '../models/pedidos.dart';

class PedidoService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref('pedidos');

  Future<void> agregarPedido(Pedido pedido) async {
    final ref = _db.push();
    await ref.set(pedido.toMap());
  }

  Future<void> actualizarEstado(String id, String estado) async {
    await _db.child(id).update({'estado': estado});
  }

  Future<void> eliminarPedido(String id) async {
    await _db.child(id).remove();
  }

  // Stream en tiempo real (para CocinaScreen)
  Stream<List<Pedido>> obtenerPedidosTiempoReal() {
    return _db.onValue.map((event) {
      if (!event.snapshot.exists) return [];

      final data = Map<String, dynamic>.from(event.snapshot.value as Map);

      final pedidos = data.entries.map((e) {
        return Pedido.fromMap(e.key, Map<String, dynamic>.from(e.value));
      }).toList();

      pedidos.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return pedidos;
    });
  }
}
