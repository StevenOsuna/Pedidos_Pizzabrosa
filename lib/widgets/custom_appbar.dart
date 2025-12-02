import 'package:flutter/material.dart';

PreferredSizeWidget customAppBar(String titulo) {
  return AppBar(
    backgroundColor: Colors.redAccent,
    elevation: 4,
    centerTitle: false,
    toolbarHeight: 65,

    title: Row(
      children: [
        // LOGO
        Image.asset(
          'assets/logo.jpg',
          width: 45,
          height: 45,
          fit: BoxFit.cover,
        ),

        const SizedBox(width: 12),

        // TÍTULO
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    ),
  );
}
