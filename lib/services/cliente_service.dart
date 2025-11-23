import 'package:firebase_database/firebase_database.dart';
import '../models/cliente.dart';

class ClienteService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref('clientes');

  Future<String> agregarCliente(Cliente cliente) async {
    final newRef = _db.push();
    await newRef.set(cliente.toMap());
    return newRef.key!; // regresamos ID del cliente
  }

  Future<List<Cliente>> obtenerClientes() async {
    final snapshot = await _db.get();
    if (!snapshot.exists) return [];

    final data = Map<String, dynamic>.from(snapshot.value as Map);

    return data.entries.map((e) {
      return Cliente.fromMap(e.key, Map<String, dynamic>.from(e.value));
    }).toList();
  }
}
