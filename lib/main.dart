import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(PedidosPizzabrosaApp());
}

class PedidosPizzabrosaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pedidos Pizzabrosa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.red,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: Colors.green,
        ),
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: const Color(0xFFE0E0E0),
      ),
      home: HomeScreen(),
    );
  }
}
