import 'package:firebase_database/firebase_database.dart';
import '../models/cliente.dart';

class ClienteService {
  final DatabaseReference ref = FirebaseDatabase.instance.ref().child(
    "clientes",
  );

  Future<void> agregarCliente(Cliente cliente) async {
    final nuevo = ref.push();
    await nuevo.set(cliente.toJson());
  }

  Future<void> actualizarCliente(String id, Cliente cliente) async {
    await ref.child(id).update(cliente.toJson());
  }

  Future<void> eliminarCliente(String id) async {
    await ref.child(id).remove();
  }

  Stream<List<Cliente>> obtenerClientes() {
    return ref.onValue.map((event) {
      final raw = event.snapshot.value;

      if (raw == null) return [];

      // Convertimos el snapshot completo
      final data = Map<dynamic, dynamic>.from(raw as Map);

      return data.entries.map((e) {
        final value = e.value;

        // Conversión segura
        final mapValue = (value is Map<dynamic, dynamic>)
            ? Map<dynamic, dynamic>.from(value)
            : <dynamic, dynamic>{};

        return Cliente.fromJson(mapValue, e.key);
      }).toList()..sort((a, b) => a.nombre.compareTo(b.nombre));
    });
  }

  Future<List<Cliente>> obtenerClientesUnaVez() async {
    final snapshot = await ref.get();
    final raw = snapshot.value;

    if (raw == null) return [];

    final data = Map<dynamic, dynamic>.from(raw as Map);

    return data.entries.map((e) {
      final value = e.value;

      final mapValue = (value is Map<dynamic, dynamic>)
          ? Map<dynamic, dynamic>.from(value)
          : <dynamic, dynamic>{};

      return Cliente.fromJson(mapValue, e.key);
    }).toList()..sort((a, b) => a.nombre.compareTo(b.nombre));
  }
}
