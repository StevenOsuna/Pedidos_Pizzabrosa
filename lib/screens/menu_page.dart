import 'package:flutter/material.dart';
import '../models/pedidos.dart';
import '../services/pedido_service.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final PedidoService pedidoService = PedidoService();

  String paquete = "";
  String tamano = "";
  TextEditingController notasController = TextEditingController();
  Map<String, String> cliente = {"nombre": "", "cel": "", "direccion": ""};

  final List<String> paquetes = [
    "Mexicana",
    "Pepperoni",
    "Hawaiana",
    "Champiñones",
  ];

  final List<String> tamanos = [
    "Familiar (8)",
    "Superpizza (20)",
    "MegaPizza (40)",
  ];

  @override
  Widget build(BuildContext context) {
    final ancho = MediaQuery.of(context).size.width;
    final esCelular = ancho < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Generar pedido"),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Paquetes
            Text(
              "Selecciona el paquete:",
              style: TextStyle(
                fontSize: esCelular ? 18 : 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Wrap(
              spacing: 10,
              children: paquetes.map((p) {
                return ChoiceChip(
                  label: Text(p),
                  selected: paquete == p,
                  onSelected: (v) => setState(() => paquete = p),
                  selectedColor: Colors.redAccent,
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Tamaños
            Text(
              "Tamaño:",
              style: TextStyle(
                fontSize: esCelular ? 18 : 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Wrap(
              spacing: 10,
              children: tamanos.map((t) {
                return ChoiceChip(
                  label: Text(t),
                  selected: tamano == t,
                  onSelected: (v) => setState(() => tamano = t),
                  selectedColor: Colors.redAccent,
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Notas
            Text(
              "Notas adicionales:",
              style: TextStyle(
                fontSize: esCelular ? 18 : 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextField(
              controller: notasController,
              decoration: const InputDecoration(
                hintText: "Sin cebolla, salsa aparte, etc...",
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),

            const SizedBox(height: 25),

            // Cliente
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _agregarClienteModal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.symmetric(vertical: esCelular ? 18 : 22),
                ),
                child: Text(
                  cliente["nombre"]!.isEmpty
                      ? "Agregar cliente (opcional)"
                      : "Cliente: ${cliente['nombre']}",
                  style: TextStyle(fontSize: esCelular ? 18 : 20),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Registrar pedido
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _registrarPedido,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: esCelular ? 18 : 22),
                ),
                child: Text(
                  "Registrar pedido",
                  style: TextStyle(fontSize: esCelular ? 18 : 22),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Modal cliente
  void _agregarClienteModal() {
    TextEditingController nombre = TextEditingController();
    TextEditingController cel = TextEditingController();
    TextEditingController direccion = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Agregar cliente"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombre,
              decoration: const InputDecoration(labelText: "Nombre"),
            ),
            TextField(
              controller: cel,
              decoration: const InputDecoration(labelText: "Celular"),
            ),
            TextField(
              controller: direccion,
              decoration: const InputDecoration(labelText: "Dirección"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                cliente["nombre"] = nombre.text;
                cliente["cel"] = cel.text;
                cliente["direccion"] = direccion.text;
              });
              Navigator.pop(context);
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  // Guardar pedido en Firebase
  Future<void> _registrarPedido() async {
    if (paquete.isEmpty || tamano.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecciona paquete y tamaño")),
      );
      return;
    }

    // Cliente genérico si no se llenó
    final String clienteNombre = cliente["nombre"]!.isEmpty
        ? "Cliente sin registro"
        : cliente["nombre"]!;
    final String clienteCel = cliente["cel"]!.isEmpty ? "-" : cliente["cel"]!;
    final String clienteDir = cliente["direccion"]!.isEmpty
        ? "-"
        : cliente["direccion"]!;

    final item = PedidoItem(
      paquete: paquete,
      tamano: tamano,
      notas: notasController.text,
    );

    final pedido = Pedido(
      clienteNombre: clienteNombre,
      clienteCel: clienteCel,
      clienteDireccion: clienteDir,
      estado: "espera",
      timestamp: DateTime.now().millisecondsSinceEpoch,
      items: [item],
    );

    await pedidoService.agregarPedido(pedido);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Pedido registrado exitosamente")),
    );

    Navigator.pop(context);
  }
}
