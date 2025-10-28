import 'package:flutter/material.dart';
import 'generar_pedido_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text('Pedidos_Pizzabrosa',
            style: TextStyle(fontStyle: FontStyle.italic)),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildButton(context, 'Generar pedido', Colors.green, () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => GenerarPedidoScreen()));
            }),
            const SizedBox(height: 20),
            _buildButton(context, 'Historial de pedidos', Colors.green, () {}),
            const SizedBox(height: 20),
            _buildButton(context, 'Clientes frecuentes', Colors.green, () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
      BuildContext context, String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 20),
      ),
    );
  }
}
