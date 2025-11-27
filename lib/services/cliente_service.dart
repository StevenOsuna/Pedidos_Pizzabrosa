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
      final data = event.snapshot.value as Map?;
      if (data == null) return [];

      return data.entries.map((e) => Cliente.fromJson(e.value, e.key)).toList()
        ..sort((a, b) => a.nombre.compareTo(b.nombre));
    });
  }

  Future<List<Cliente>> obtenerClientesUnaVez() async {
    final snapshot = await ref.get();
    final data = snapshot.value as Map?;
    if (data == null) return [];
    return data.entries.map((e) => Cliente.fromJson(e.value, e.key)).toList()
      ..sort((a, b) => a.nombre.compareTo(b.nombre));
  }
}
