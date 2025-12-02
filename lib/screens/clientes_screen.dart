import 'package:flutter/material.dart';
import '../models/cliente.dart';
import '../services/cliente_service.dart';
import '../widgets/custom_appbar.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  final ClienteService clienteService = ClienteService();

  @override
  Widget build(BuildContext context) {
    final ancho = MediaQuery.of(context).size.width;
    final esCelular = ancho < 600;

    return Scaffold(
      appBar: customAppBar("Clientes frecuentes"),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () => _modalAgregarCliente(),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Cliente>>(
        stream: clienteService.obtenerClientes(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final clientes = snapshot.data!;

          if (clientes.isEmpty) {
            return const Center(child: Text("No hay clientes registrados"));
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final double cardWidth = esCelular ? ancho * 0.9 : ancho * 0.5;

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: clientes.length,
                itemBuilder: (context, index) {
                  final cliente = clientes[index];

                  return Center(
                    child: Container(
                      width: cardWidth,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Card(
                        elevation: 3,
                        child: ListTile(
                          title: Text(cliente.nombre),
                          subtitle: Text(
                            "${cliente.cel}\n${cliente.direccion}",
                          ),
                          isThreeLine: true,
                          trailing: PopupMenuButton(
                            onSelected: (value) {
                              if (value == "editar") {
                                _modalEditarCliente(cliente);
                              } else if (value == "eliminar") {
                                clienteService.eliminarCliente(cliente.id!);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: "editar",
                                child: Text("Editar"),
                              ),
                              const PopupMenuItem(
                                value: "eliminar",
                                child: Text("Eliminar"),
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

  // ======================================================
  // MODAL: AGREGAR CLIENTE
  // ======================================================
  void _modalAgregarCliente() {
    TextEditingController nombre = TextEditingController();
    TextEditingController cel = TextEditingController();
    TextEditingController direccion = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Agregar cliente"),
        content: SizedBox(
          width: 400,
          child: Column(
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
                decoration: const InputDecoration(labelText: "Direccion"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              if (nombre.text.isEmpty) return;

              final nuevo = Cliente(
                nombre: nombre.text,
                cel: cel.text,
                direccion: direccion.text,
                timestamp: DateTime.now().millisecondsSinceEpoch,
              );

              clienteService.agregarCliente(nuevo);
              Navigator.pop(context);
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  // ======================================================
  // MODAL: EDITAR CLIENTE
  // ======================================================
  void _modalEditarCliente(Cliente c) {
    TextEditingController nombre = TextEditingController(text: c.nombre);
    TextEditingController cel = TextEditingController(text: c.cel);
    TextEditingController direccion = TextEditingController(text: c.direccion);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Editar cliente"),
        content: SizedBox(
          width: 400,
          child: Column(
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
                decoration: const InputDecoration(labelText: "Direccion"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              final actualizado = Cliente(
                id: c.id,
                nombre: nombre.text,
                cel: cel.text,
                direccion: direccion.text,
                timestamp: c.timestamp,
              );

              clienteService.actualizarCliente(c.id!, actualizado);
              Navigator.pop(context);
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }
}
