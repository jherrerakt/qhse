import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qhse/screens/home_screen.dart';

class LoginScreen extends StatelessWidget {
  Future<void> authenticate(BuildContext context) async {
    try {
      print("Entro al provider");

      final microsoftProvider = MicrosoftAuthProvider();
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithProvider(microsoftProvider);

      User? user = userCredential.user;

      if (user != null) {
        // Si la autenticación es exitosa, navega a la pantalla de detalles del usuario
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (error) {
      print("Error de autenticación: $error");

      // Si la autenticación falla, muestra un popup
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Error de autenticación"),
            content: const Text(
                "No se pudo autenticar con Microsoft. Por favor, inténtalo de nuevo."),
            actions: [
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop(); // Cierra el popup
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/logoqhse.png',
                  width: 180.0,
                ),
                const SizedBox(height: 10),
                const Text(
                  'QHSE CL',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'LEMONMILK',
                    color: Color.fromARGB(255, 0, 25, 48),
                  ),
                ),
                const SizedBox(height: 120),
                Container(
                  width: 400,
                  child: Column(
                    children: [
                      Container(
                        width: 400,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              const Color.fromARGB(255, 158, 204, 236),
                            ),
                          ),
                          onPressed: () => authenticate(context),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/Microsoft.png', // Reemplaza con la ruta real de tu logo
                                  height:
                                      24, // Ajusta la altura según tus necesidades
                                  width:
                                      24, // Ajusta el ancho según tus necesidades
                                ),
                                const SizedBox(
                                    width:
                                        10), // Ajusta el espacio entre el logo y el texto
                                const Text(
                                  'SSO',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color.fromARGB(255, 0, 25, 48),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
