import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:qhse/screens/LoginScreen.dart'; // Asegúrate de importar la pantalla de login

class UserDetailsScreen extends StatelessWidget {
  final User user;

  UserDetailsScreen({required this.user});

  final DatabaseReference gruposRef =
      FirebaseDatabase.instance.ref().child('grupos');

  Future<String?> getGroupNameByEmail(String email) async {
    DataSnapshot snapshot =
        (await gruposRef.orderByChild('email').equalTo(email).once()).snapshot;

    if (snapshot.exists) {
      Map<dynamic, dynamic> grupos = snapshot.value as Map<dynamic, dynamic>;
      for (var entry in grupos.entries) {
        Map<dynamic, dynamic> grupoData = entry.value as Map<dynamic, dynamic>;
        return grupoData['nombre'] as String?;
      }
    }
    return null; // Retorna null si no se encontró el grupo
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'USUARIO',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'LEMONMILK',
              color: Color.fromARGB(255, 0, 25, 48),
            ),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 158, 204, 236),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/user.png', // Ruta a tu imagen de usuario predeterminada
                fit: BoxFit
                    .cover, // Asegura que la imagen cubra todo el área del círculo
                width: 160, // Doble del radio
                height: 160,
              ),
              const SizedBox(height: 40),
              Text(
                user.displayName ?? 'No disponible',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                user.email ?? 'No disponible',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 40),
              FutureBuilder<String?>(
                future: getGroupNameByEmail(user.email!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return const Text('Error al cargar el grupo');
                  } else if (!snapshot.hasData || snapshot.data == null) {
                    return const Text('Grupo no encontrado');
                  } else {
                    return Text(
                      'Grupo: ${snapshot.data}',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.blueAccent,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 180),
              ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 158, 204, 236),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text(
                  'Cerrar sesión',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color.fromARGB(255, 0, 25, 48),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
