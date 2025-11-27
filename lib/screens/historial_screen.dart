import 'package:flutter/material.dart';
import '../models/pedidos.dart';
import '../services/pedido_service.dart';

class HistorialScreen extends StatelessWidget {
  HistorialScreen({super.key});

  final PedidoService pedidoService = PedidoService();

  Color _colorEstado(String estado) {
    switch (estado) {
      case "entregado":
        return Colors.green.shade300;
      default:
        return Colors.grey.shade300;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ancho = MediaQuery.of(context).size.width;
    final esCelular = ancho < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Historial de pedidos"),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      body: StreamBuilder<List<Pedido>>(
        stream: pedidoService.obtenerPedidosTiempoReal(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // Filtrar pedidos entregados
          final pedidos =
              snapshot.data!.where((p) => p.estado == "entregado").toList()
                ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

          if (pedidos.isEmpty) {
            return const Center(
              child: Text(
                "No hay pedidos entregados",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final double cardWidth = esCelular ? ancho * 0.9 : ancho * 0.5;

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: pedidos.length,
                itemBuilder: (context, index) {
                  final pedido = pedidos[index];

                  return Center(
                    child: Container(
                      width: cardWidth,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Card(
                        elevation: 4,
                        color: _colorEstado(pedido.estado),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // HEADER
                              Text(
                                "Pedido #${pedido.id ?? ''}",
                                style: TextStyle(
                                  fontSize: esCelular ? 18 : 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "Cliente: ${pedido.clienteNombre}",
                                style: TextStyle(
                                  fontSize: esCelular ? 16 : 18,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 10),

                              const Divider(),

                              // LISTA DE ITEMS
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: pedido.items.map((item) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    child: Text(
                                      "• ${item.paquete} - ${item.tamano} ${item.notas.isNotEmpty ? "(" + item.notas + ")" : ""}",
                                      style: TextStyle(
                                        fontSize: esCelular ? 16 : 18,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),

                              const SizedBox(height: 10),

                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  _fecha(pedido.timestamp),
                                  style: TextStyle(
                                    fontSize: esCelular ? 12 : 14,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  // Convertir timestamp a fecha legible
  String _fecha(int ts) {
    final d = DateTime.fromMillisecondsSinceEpoch(ts);
    return "${d.day}/${d.month}/${d.year} ${d.hour}:${d.minute.toString().padLeft(2, '0')}";
  }
}
