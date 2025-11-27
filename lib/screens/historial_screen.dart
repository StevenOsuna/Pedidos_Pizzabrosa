import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/pedidos.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HistorialScreenState createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  final DatabaseReference ref = FirebaseDatabase.instance.ref("pedidos");

  @override
  Widget build(BuildContext context) {
    //final double ancho = MediaQuery.of(context).size.width;
    //final bool esCelular = ancho < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Historial de Pedidos"),
        centerTitle: true,
      ),

      body: StreamBuilder<DatabaseEvent>(
        stream: ref.onValue,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: Text("No hay pedidos registrados"));
          }

          final raw = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          final pedidos = raw.entries.map((entry) {
            return Pedido.fromJson(entry.value, entry.key);
          }).toList();

          // más recientes primero
          pedidos.sort((a, b) => b.timestamp.compareTo(a.timestamp));

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: pedidos.length,
            itemBuilder: (context, index) {
              final pedido = pedidos[index];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cliente
                      Text(
                        pedido.clienteNombre.isEmpty
                            ? "Cliente no registrado"
                            : pedido.clienteNombre,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Row(
                        children: [
                          const Icon(Icons.phone, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            pedido.clienteCel.isEmpty
                                ? "Sin teléfono"
                                : pedido.clienteCel,
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 18),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              pedido.clienteDireccion.isEmpty
                                  ? "Sin dirección"
                                  : pedido.clienteDireccion,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Estado del pedido
                      Row(
                        children: [
                          const Icon(Icons.flag),
                          const SizedBox(width: 6),
                          Text("Estado: ${pedido.estado}"),
                        ],
                      ),

                      const Divider(height: 20),

                      // ITEMS DEL PEDIDO
                      const Text(
                        "Artículos:",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: pedido.items.map((item) {
                          final notas = item.notas.isEmpty
                              ? ""
                              : " (${item.notas})";

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              "• ${item.paquete} - ${item.tamano}$notas",
                              style: const TextStyle(fontSize: 15),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 10),

                      // Fecha
                      Text(
                        "Fecha: ${DateTime.fromMillisecondsSinceEpoch(pedido.timestamp).toLocal()}",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
