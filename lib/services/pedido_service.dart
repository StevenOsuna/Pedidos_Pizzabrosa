import 'package:firebase_database/firebase_database.dart';
import '../models/pedidos.dart';

class PedidoService {
  final DatabaseReference ref = FirebaseDatabase.instance.ref().child(
    "pedidos",
  );
  final DatabaseReference refHistorial = FirebaseDatabase.instance.ref().child(
    "historial",
  );

  // Agregar pedido (push)
  Future<void> agregarPedido(Pedido pedido) async {
    final nuevo = ref.push();
    // Guardamos el id dentro del objeto para consistencia
    final map = pedido.toJson();
    map['id'] = nuevo.key;
    await nuevo.set(map);
  }

  // Actualizar solo el estado
  Future<void> actualizarEstado(String id, String estado) async {
    await ref.child(id).update({'estado': estado});
  }

  // Eliminar pedido del nodo "pedidos"
  Future<void> eliminarPedido(String id) async {
    await ref.child(id).remove();
  }

  // Mover pedido (copiar) al nodo historial
  Future<void> moverAPedidosHistorial(Pedido pedido) async {
    if (pedido.id == null) return;
    final histRef = refHistorial.child(pedido.id!);
    // Guardar todo el objeto en historial (incluyendo id)
    await histRef.set(pedido.toJson()..['id'] = pedido.id);
  }

  // Stream en tiempo real para la cocina (pedidos activos)
  Stream<List<Pedido>> obtenerPedidosTiempoReal() {
    return ref.onValue.map((event) {
      final raw = event.snapshot.value;
      if (raw == null) return <Pedido>[];

      final data = Map<dynamic, dynamic>.from(raw as Map);
      final pedidos = data.entries.map((e) {
        final value = e.value;
        final mapValue = (value is Map)
            ? Map<dynamic, dynamic>.from(value)
            : <dynamic, dynamic>{};
        return Pedido.fromJson(mapValue, e.key.toString());
      }).toList();

      // Orden por timestamp ascendente (llegada): los primeros son los más antiguos
      pedidos.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return pedidos;
    });
  }

  // Stream para historial (todos los pedidos entregados / movidos)
  Stream<List<Pedido>> obtenerHistorial() {
    return refHistorial.onValue.map((event) {
      final raw = event.snapshot.value;
      if (raw == null) return <Pedido>[];

      final data = Map<dynamic, dynamic>.from(raw as Map);
      final pedidos = data.entries.map((e) {
        final value = e.value;
        final mapValue = (value is Map)
            ? Map<dynamic, dynamic>.from(value)
            : <dynamic, dynamic>{};
        return Pedido.fromJson(mapValue, e.key.toString());
      }).toList();

      // Orden descendente: más recientes primero
      pedidos.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return pedidos;
    });
  }

  // Obtener lista una vez (útil para pruebas)
  Future<List<Pedido>> obtenerPedidosUnaVez() async {
    final snap = await ref.get();
    if (snap.value == null) return <Pedido>[];

    final data = Map<dynamic, dynamic>.from(snap.value as Map);
    return data.entries.map((e) {
      final value = e.value;
      final mapValue = (value is Map)
          ? Map<dynamic, dynamic>.from(value)
          : <dynamic, dynamic>{};
      return Pedido.fromJson(mapValue, e.key.toString());
    }).toList();
  }
}
