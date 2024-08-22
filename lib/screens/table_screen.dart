import 'package:flutter/material.dart';
import 'package:qhse/screens/widgets/custom_table_cell.dart';

class TableScreen extends StatelessWidget {
  const TableScreen();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(),
          1: FlexColumnWidth(),
        },
        children: [
          TableRow(
            children: [
              CustomTableCell(
                  backgroundColor: const Color.fromARGB(255, 247, 42, 0),
                  iconColor: const Color.fromARGB(255, 127, 21, 0),
                  title: 'AP01-Gestión de Eventos',
                  onTap: () {
                    Navigator.pushNamed(context, '/listadoEventos');
                  },
                  onAddIconPressed: () {
                    Navigator.pushNamed(context, '/formEventos');
                  },
                  onListIconPressed: () {
                    Navigator.pushNamed(context, '/listadoEventos');
                  }),
              CustomTableCell(
                backgroundColor: const Color.fromARGB(255, 203, 0, 59),
                iconColor: const Color.fromARGB(255, 127, 0, 37),
                title: 'AP02-Comunicación de Riesgos',
                onTap: //llamar a la pantalla de lista comunicación de riesgos
                    () {
                  Navigator.pushNamed(context, '/listadoRiesgos');
                },
                onAddIconPressed: () {
                  Navigator.pushNamed(context, '/formRiesgos');
                },
                onListIconPressed: () {
                  Navigator.pushNamed(context, '/listadoRiesgos');
                },
              ),
            ],
          ),

          // Agrega más filas aquí
        ],
      ),
    );
  }
}
