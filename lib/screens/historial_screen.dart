import 'package:flutter/material.dart';
import '../models/pedidos.dart';
import '../services/pedido_service.dart';
import 'package:intl/intl.dart';

class HistorialScreen extends StatelessWidget {
  final PedidoService pedidoService = PedidoService();

  HistorialScreen({super.key});

  String formatearFecha(int timestamp) {
    final fecha = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('dd/MM/yyyy – HH:mm').format(fecha);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Historial de Pedidos"),
        backgroundColor: Colors.redAccent,
        centerTitle: true,
      ),
      body: StreamBuilder<List<Pedido>>(
        stream: pedidoService.obtenerHistorial(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final pedidos = snapshot.data!;

          if (pedidos.isEmpty) {
            return const Center(
              child: Text(
                "No hay pedidos en el historial",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: pedidos.length,
            itemBuilder: (context, index) {
              final pedido = pedidos[index];

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ENCABEZADO
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            pedido.clienteNombre.isEmpty
                                ? "Sin nombre"
                                : pedido.clienteNombre,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            formatearFecha(pedido.timestamp),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // ITEMS
                      ...pedido.items.map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            "• ${item.paquete} - ${item.tamano} "
                            "${item.notas.isNotEmpty ? "(${item.notas})" : ""}",
                            style: const TextStyle(fontSize: 16),
                          ),
                        );
                      }),

                      const Divider(height: 22),

                      // ESTADO
                      Text(
                        "Estado final: ${pedido.estado}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
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
