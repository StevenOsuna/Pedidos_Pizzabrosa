import 'package:flutter/material.dart';
import '../models/pedidos.dart';
import '../services/pedido_service.dart';

class CocinaScreen extends StatefulWidget {
  const CocinaScreen({super.key});

  @override
  State<CocinaScreen> createState() => _CocinaScreenState();
}

class _CocinaScreenState extends State<CocinaScreen> {
  final PedidoService pedidoService = PedidoService();

  Color _colorPorEstado(String estado) {
    switch (estado) {
      case 'preparacion':
        return Colors.green.shade200;
      case 'siguiente':
        return Colors.yellow.shade200;
      case 'entregado':
        return Colors.grey.shade300;
      default:
        return Colors.red.shade200; // 'espera' u otros
    }
  }

  // -------------------------------------------------------
  // Procesar botón ENTREGAR
  // -------------------------------------------------------
  Future<void> entregarPedido(List<Pedido> pedidos) async {
    if (pedidos.isEmpty) return;

    // 1. Tomamos el primer pedido
    final first = pedidos.first;
    if (first.id != null) {
      // 1a) Guardar en historial
      await pedidoService.moverAPedidosHistorial(first);
      // 1b) Eliminar del nodo principal
      await pedidoService.eliminarPedido(first.id!);
    }

    // 2. Reordenar estados de los pedidos restantes
    if (pedidos.length > 1 && pedidos[1].id != null) {
      await pedidoService.actualizarEstado(pedidos[1].id!, 'preparacion');
    }
    if (pedidos.length > 2 && pedidos[2].id != null) {
      await pedidoService.actualizarEstado(pedidos[2].id!, 'siguiente');
    }

    // Los demás quedan en espera
    for (int i = 3; i < pedidos.length; i++) {
      if (pedidos[i].id != null) {
        await pedidoService.actualizarEstado(pedidos[i].id!, 'espera');
      }
    }
  }

  Widget _buildPedidoCard(BuildContext context, Pedido pedido) {
    final double anchoPantalla = MediaQuery.of(context).size.width;
    final double cardWidth = anchoPantalla < 500
        ? anchoPantalla * 0.80
        : anchoPantalla < 900
        ? anchoPantalla / 2.8
        : anchoPantalla / 3.2;

    return Container(
      width: cardWidth,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Card(
        elevation: 5,
        color: _colorPorEstado(pedido.estado),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ENCABEZADO DEL PEDIDO
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pedido${pedido.id != null ? ' #${pedido.id}' : ''}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pedido.clienteNombre,
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Estado: ${pedido.estado}',
                    style: TextStyle(
                      fontSize: 15,
                      color: pedido.estado == 'preparacion'
                          ? Colors.redAccent
                          : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const Divider(thickness: 1.2, height: 20),

              // LISTA DE PRODUCTOS
              Expanded(
                child: ListView(
                  physics: const NeverScrollableScrollPhysics(),
                  children: pedido.items.map((item) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        '• ${item.paquete} - ${item.tamano}'
                        '${item.notas.isNotEmpty ? " (${item.notas})" : ""}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------
  // UI PRINCIPAL
  // -------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Cocina'),
        backgroundColor: Colors.redAccent,
        centerTitle: true,
      ),
      body: StreamBuilder<List<Pedido>>(
        stream: pedidoService.obtenerPedidosTiempoReal(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final pedidos = snapshot.data!;

          if (pedidos.isEmpty) {
            return const Center(
              child: Text("No hay pedidos", style: TextStyle(fontSize: 20)),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // LISTA HORIZONTAL DE PEDIDOS
                    Expanded(
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: pedidos.length,
                        itemBuilder: (context, index) {
                          return _buildPedidoCard(context, pedidos[index]);
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // BOTÓN ENTREGAR
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => entregarPedido(pedidos),
                        icon: const Icon(Icons.check_circle_outline, size: 26),
                        label: const Text(
                          'ENTREGAR',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          minimumSize: const Size(double.infinity, 60),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
