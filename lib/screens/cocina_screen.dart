import 'package:flutter/material.dart';

class CocinaScreen extends StatefulWidget {
  const CocinaScreen({super.key});

  @override
  State<CocinaScreen> createState() => _CocinaScreenState();
}

class _CocinaScreenState extends State<CocinaScreen> {
  List<Map<String, dynamic>> pedidos = [
    {
      'id': 1,
      'cliente': 'Juan Pérez',
      'productos': ['Pepperoni', 'MegaPizza', 'Coca-cola 600ml', 'Sin cebolla'],
      'estado': 'En preparación',
    },
    {
      'id': 2,
      'cliente': 'María López',
      'productos': ['Hawaiana', 'Superpizza', 'Agua mineral'],
      'estado': 'Siguiente',
    },
    {
      'id': 3,
      'cliente': 'Carlos Ruiz',
      'productos': ['Mexicana', 'Familiar', 'Queso Extra'],
      'estado': 'En espera',
    },
  ];

  void entregarPedido() {
    setState(() {
      if (pedidos.isNotEmpty) pedidos.removeAt(0);
      if (pedidos.isNotEmpty) pedidos[0]['estado'] = 'En preparación';
      if (pedidos.length > 1) pedidos[1]['estado'] = 'Siguiente';
      if (pedidos.length > 2) pedidos[2]['estado'] = 'En espera';
    });
  }

  Color _colorPorEstado(String estado) {
    switch (estado) {
      case 'En preparación':
        return Colors.green.shade200;
      case 'Siguiente':
        return Colors.yellow.shade200;
      default:
        return Colors.red.shade200;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Cocina'),
        backgroundColor: Colors.redAccent,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // PEDIDOS EN HORIZONTAL
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: pedidos.length,
                itemBuilder: (context, index) {
                  final pedido = pedidos[index];
                  return Container(
                    width:
                        MediaQuery.of(context).size.width / 3 -
                        20, // 3 columnas visibles
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: Card(
                      elevation: 5,
                      color: _colorPorEstado(pedido['estado']),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
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
                                  'Pedido #${pedido['id']}',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  pedido['cliente'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Estado: ${pedido['estado']}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: pedido['estado'] == 'En preparación'
                                        ? Colors.redAccent
                                        : Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),

                            const Divider(thickness: 1.2, height: 20),

                            // PRODUCTOS
                            Expanded(
                              child: ListView(
                                physics: const NeverScrollableScrollPhysics(),
                                children: (pedido['productos'] as List<String>)
                                    .map(
                                      (producto) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 4.0,
                                        ),
                                        child: Text(
                                          '• $producto',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // BOTÓN ENTREGAR
            ElevatedButton.icon(
              onPressed: pedidos.isNotEmpty ? entregarPedido : null,
              icon: const Icon(Icons.check_circle_outline, size: 26),
              label: const Text(
                'ENTREGAR',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
