import 'package:flutter/material.dart';
import '../models/cliente.dart';
import '../models/item_pedido.dart';
import '../models/pedidos.dart';
import '../services/cliente_service.dart';
import '../services/pedido_service.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final clienteService = ClienteService();
  final pedidoService = PedidoService();
  // Cliente seleccionado
  String? clienteNombre;
  String? clienteTelefono;
  String? clienteDireccion;

  // Opciones del menú
  final List<String> paquetes = [
    "Mexicana",
    "Peperoni",
    "Hawaiana",
    "Champiñones",
  ];

  final List<String> tamanos = [
    "Familiar (8)",
    "SuperPizza (20)",
    "MegaPizza (40)",
  ];

  String? clienteId;
  String? paqueteSeleccionado;
  String? tamanoSeleccionado;
  final TextEditingController notasCtrl = TextEditingController();

  // Carrito de pizzas agregadas
  List<Map<String, dynamic>> carrito = [];

  // -----------------------------------------------
  // Modal para seleccionar o agregar cliente
  // -----------------------------------------------
  void abrirModalCliente() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Clientes",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Seleccionar cliente existente
              ElevatedButton(
                onPressed: () async {
                  final lista = await clienteService.obtenerClientes();

                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Seleccionar cliente"),
                      content: SizedBox(
                        height: 300,
                        width: 300,
                        child: ListView(
                          children: lista.map((c) {
                            return ListTile(
                              title: Text(c.nombre),
                              subtitle: Text(c.telefono),
                              onTap: () {
                                setState(() {
                                  clienteId = c.id;
                                  clienteNombre = c.nombre;
                                  clienteTelefono = c.telefono;
                                  clienteDireccion = c.direccion;
                                });
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  );
                },
                child: const Text("Seleccionar cliente existente"),
              ),

              const SizedBox(height: 15),

              // Agregar cliente nuevo
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  abrirFormClienteNuevo();
                },
                child: const Text("Agregar cliente nuevo"),
              ),
            ],
          ),
        );
      },
    );
  }

  void abrirFormClienteNuevo() {
    final nombreCtrl = TextEditingController();
    final telCtrl = TextEditingController();
    final dirCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Nuevo Cliente",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: nombreCtrl,
                decoration: const InputDecoration(labelText: "Nombre"),
              ),
              TextField(
                controller: telCtrl,
                decoration: const InputDecoration(labelText: "Teléfono"),
              ),
              TextField(
                controller: dirCtrl,
                decoration: const InputDecoration(labelText: "Dirección"),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () async {
                  final cliente = Cliente(
                    nombre: nombreCtrl.text,
                    telefono: telCtrl.text,
                    direccion: dirCtrl.text,
                  );

                  final id = await clienteService.agregarCliente(cliente);

                  setState(() {
                    clienteId = id;
                    clienteNombre = cliente.nombre;
                    clienteTelefono = cliente.telefono;
                    clienteDireccion = cliente.direccion;
                  });

                  Navigator.pop(context);
                },
                child: const Text("Guardar cliente"),
              ),
            ],
          ),
        );
      },
    );
  }

  // -----------------------------------------------
  // Agregar pizza al carrito
  // -----------------------------------------------
  void agregarAlPedido() {
    if (paqueteSeleccionado == null || tamanoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecciona paquete y tamaño")),
      );
      return;
    }

    setState(() {
      carrito.add({
        "paquete": paqueteSeleccionado,
        "tamaño": tamanoSeleccionado,
        "notas": notasCtrl.text,
      });
      notasCtrl.clear();
    });
  }

  // -----------------------------------------------
  // Generar comanda
  // -----------------------------------------------
  void generarComanda() async {
    if (clienteId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecciona o agrega un cliente")),
      );
      return;
    }

    if (carrito.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Agrega productos al pedido")),
      );
      return;
    }

    final items = carrito.map((item) {
      return ItemPedido(
        paquete: item["paquete"],
        tamano: item["tamaño"],
        notas: item["notas"],
        cantidad: 1,
        precio: 0, // después ponemos precio real
      );
    }).toList();

    final pedido = Pedido(
      clienteId: clienteId!,
      clienteNombre: clienteNombre!,
      items: items,
      estado: "espera",
      timestamp: DateTime.now().millisecondsSinceEpoch,
      total: 0,
    );

    await pedidoService.agregarPedido(pedido);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Pedido enviado a cocina")));

    setState(() {
      carrito.clear();
    });
  }

  // -----------------------------------------------
  // UI PRINCIPAL
  // -----------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Generar Pedido"),
        backgroundColor: Colors.redAccent,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // -----------------------------------------------
            // 1. Sección Cliente
            // -----------------------------------------------
            Card(
              elevation: 3,
              child: ListTile(
                title: Text(
                  clienteNombre ?? "Seleccionar cliente",
                  style: const TextStyle(fontSize: 18),
                ),
                subtitle: clienteTelefono != null
                    ? Text("$clienteTelefono • $clienteDireccion")
                    : const Text("Toca para seleccionar o agregar"),
                trailing: const Icon(Icons.person),
                onTap: abrirModalCliente,
              ),
            ),

            const SizedBox(height: 20),

            // -----------------------------------------------
            // 2. Selección paquete
            // -----------------------------------------------
            const Text("Paquete", style: TextStyle(fontSize: 18)),
            Wrap(
              spacing: 10,
              children: paquetes.map((p) {
                return ChoiceChip(
                  label: Text(p),
                  selected: paqueteSeleccionado == p,
                  onSelected: (_) => setState(() => paqueteSeleccionado = p),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // -----------------------------------------------
            // 3. Selección tamaño
            // -----------------------------------------------
            const Text("Tamaño", style: TextStyle(fontSize: 18)),
            Wrap(
              spacing: 10,
              children: tamanos.map((t) {
                return ChoiceChip(
                  label: Text(t),
                  selected: tamanoSeleccionado == t,
                  onSelected: (_) => setState(() => tamanoSeleccionado = t),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // -----------------------------------------------
            // 4. Notas
            // -----------------------------------------------
            TextField(
              controller: notasCtrl,
              decoration: const InputDecoration(
                labelText: "Notas adicionales",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            ElevatedButton(
              onPressed: agregarAlPedido,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text("Agregar al pedido"),
            ),

            const SizedBox(height: 20),

            // -----------------------------------------------
            // 5. Carrito
            // -----------------------------------------------
            const Text("Pedido actual:", style: TextStyle(fontSize: 18)),
            ...carrito.map(
              (item) => ListTile(
                title: Text("${item['paquete']} - ${item['tamaño']}"),
                subtitle: Text(item["notas"]),
              ),
            ),

            const SizedBox(height: 20),

            // -----------------------------------------------
            // 6. Botón generar comanda
            // -----------------------------------------------
            ElevatedButton(
              onPressed: generarComanda,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.all(16),
              ),
              child: const Text(
                "Generar Comanda",
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
