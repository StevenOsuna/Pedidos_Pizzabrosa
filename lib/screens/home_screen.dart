import 'package:flutter/material.dart';
import 'cocina_screen.dart';
import 'menu_page.dart';
import 'historial_screen.dart';
import 'clientes_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double ancho = MediaQuery.of(context).size.width;
    final bool esCelular = ancho < 500;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text(
          'Pedidos Pizzabrosa',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _botonPrincipal(
                    texto: "Generar pedido",
                    color: Colors.green,
                    esCelular: esCelular,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MenuPage()),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  _botonPrincipal(
                    texto: "Historial de pedidos",
                    color: Colors.green,
                    esCelular: esCelular,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => HistorialScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  _botonPrincipal(
                    texto: "Clientes frecuentes",
                    color: Colors.green,
                    esCelular: esCelular,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ClientesScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  _botonPrincipal(
                    texto: "Pantalla de cocina",
                    color: Colors.green,
                    esCelular: esCelular,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CocinaScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _botonPrincipal({
    required String texto,
    required Color color,
    required bool esCelular,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: esCelular ? double.infinity : 400,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.symmetric(
            horizontal: 40,
            vertical: esCelular ? 18 : 22,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          texto,
          style: TextStyle(color: Colors.white, fontSize: esCelular ? 18 : 22),
        ),
      ),
    );
  }
}
