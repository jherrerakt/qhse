// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

class CustomTableCell extends StatelessWidget {
  final Color backgroundColor;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;
  final VoidCallback onListIconPressed; // Acción del botón izquierdo
  final VoidCallback onAddIconPressed; // Acción del botón derecho

  const CustomTableCell({
    super.key,
    required this.backgroundColor,
    required this.iconColor,
    required this.title,
    required this.onTap, required this.onListIconPressed, required this.onAddIconPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 140,
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 8.0,
              left: 8.0,
              child: IconButton(
                iconSize: 40,
                icon: const Icon(Icons.list_alt),
                onPressed: onListIconPressed,
                color: iconColor,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8.0,
              right: 8.0,
              child: IconButton(
                iconSize: 20,
                icon: const Icon(Icons.add),
                onPressed:onAddIconPressed,
                color: backgroundColor,
                style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
