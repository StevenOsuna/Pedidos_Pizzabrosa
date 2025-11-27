import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/pedidos.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  final _db = FirebaseDatabase.instance.ref("pedidos");
  String filtro =
      "todos"; // todos, En espera, En preparación, Siguiente, Entregado

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text("Historial de Pedidos"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildFiltros(),

          Expanded(
            child: StreamBuilder(
              stream: _db.onValue,
              builder: (context, snapshot) {
                if (!snapshot.hasData ||
                    snapshot.data!.snapshot.value == null) {
                  return const Center(
                    child: Text("No hay pedidos registrados"),
                  );
                }

                Map rawData = snapshot.data!.snapshot.value as Map;
                List<Pedido> pedidos = [];

                rawData.forEach((key, value) {
                  final map = Map<String, dynamic>.from(value);
                  pedidos.add(Pedido.fromJson(map, key.toString()));
                });

                pedidos.sort((a, b) => b.timestamp.compareTo(a.timestamp));

                if (filtro != "todos") {
                  pedidos = pedidos.where((p) => p.estado == filtro).toList();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: pedidos.length,
                  itemBuilder: (context, index) {
                    final pedido = pedidos[index];

                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(pedido),
                            const SizedBox(height: 8),

                            // LISTA DE PIZZAS DEL PEDIDO
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: pedido.items.map((item) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    "• ${item.paquete} - ${item.tamano}"
                                    "${item.notas.isNotEmpty ? " (${item.notas})" : ""}",
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 12),
                            _buildFooter(pedido),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ------------------- UI COMPONENTES ----------------------

  Widget _buildFiltros() {
    return SizedBox(
      height: 55,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        children: [
          _botonFiltro("todos", "Todos"),
          _botonFiltro("En espera", "Espera"),
          _botonFiltro("En preparación", "Preparando"),
          _botonFiltro("Siguiente", "Siguiente"),
          _botonFiltro("Entregado", "Entregado"),
        ],
      ),
    );
  }

  Widget _botonFiltro(String valor, String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: ChoiceChip(
        label: Text(texto),
        selected: filtro == valor,
        selectedColor: Colors.redAccent,
        onSelected: (_) {
          setState(() => filtro = valor);
        },
      ),
    );
  }

  Widget _buildHeader(Pedido pedido) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Pedido #${pedido.id}",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _colorEstado(pedido.estado),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            pedido.estado,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(Pedido pedido) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _formatoFecha(pedido.timestamp),
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
        Row(
          children: [
            TextButton(
              onPressed: () => _mostrarDetalles(pedido),
              child: const Text("Detalles"),
            ),
            TextButton(
              onPressed: () => _cambiarEstado(pedido),
              child: const Text("Estado"),
            ),
          ],
        ),
      ],
    );
  }

  // ------------------- ACCIONES ----------------------

  Color _colorEstado(String estado) {
    switch (estado) {
      case "En preparación":
        return Colors.green;
      case "Siguiente":
        return Colors.orange;
      case "En espera":
        return Colors.grey;
      case "Entregado":
        return Colors.blueGrey;
      default:
        return Colors.black;
    }
  }

  String _formatoFecha(int ms) {
    final f = DateTime.fromMillisecondsSinceEpoch(ms);
    return "${f.day}/${f.month}/${f.year} ${f.hour}:${f.minute.toString().padLeft(2, '0')}";
  }

  void _mostrarDetalles(Pedido p) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Pedido #${p.id}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Cliente: ${p.clienteNombre}"),
            Text("Número: ${p.clienteCel}"),
            Text("Dirección: ${p.clienteDireccion}"),
            const SizedBox(height: 10),

            const Text(
              "Pizzas:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),

            ...p.items.map(
              (i) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  "${i.paquete} - ${i.tamano}"
                  "${i.notas.isNotEmpty ? " (${i.notas})" : ""}",
                ),
              ),
            ),

            const SizedBox(height: 10),
            Text("Estado: ${p.estado}"),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("Cerrar"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _cambiarEstado(Pedido pedido) {
    final estados = ["En espera", "En preparación", "Siguiente", "Entregado"];

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Cambiar estado"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: estados.map((e) {
            return ListTile(
              title: Text(e),
              onTap: () {
                FirebaseDatabase.instance
                    .ref("pedidos/${pedido.id}/estado")
                    .set(e);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
