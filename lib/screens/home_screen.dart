import 'package:flutter/material.dart';
import 'package:qhse/screens/table_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 245, 245),
      appBar: AppBar(
        title: const Text(
          'QHSE CL',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'LEMONMILK',
            color: Color.fromARGB(255, 0, 25, 48),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 158, 204, 236),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings,
                color: Color.fromARGB(255, 0, 25, 48), size: 30),
            onPressed: () {
              Navigator.pushNamed(context, '/logout');
            },
          ),
        ],
      ),
      body: isLandscape
          ? const SingleChildScrollView(
              child: Column(
                children: [
                  TableScreen(),
                ],
              ),
            )
          : const TableScreen(),
    );
  }
}
