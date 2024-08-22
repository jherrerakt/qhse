import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:qhse/firebase_options.dart';
import 'package:qhse/screens/LoginScreen.dart';
import 'package:qhse/screens/UserDetails.dart';
import 'package:qhse/screens/firmulario_eventos_screen.dart';
import 'package:qhse/screens/formulario_riesgos_screen.dart';
import 'package:qhse/screens/home_screen.dart';
import 'package:qhse/screens/list_comunicacion_riesgos.dart';
import 'package:qhse/screens/list_eventos.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    FirebaseDatabase.instance.setPersistenceEnabled(true);
    runApp(const MyApp());
  } catch (e) {
    // Maneja errores de inicialización aquí
    print('Error al inicializar Firebase: $e');
    //Lanzar un error
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //Nunca va a cambiar
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color.fromARGB(255, 0, 25, 48)
          //colorScheme: const ColorScheme.dark()
          ),
      routes: {
        'authChecker': (_) => AuthChecker(),
        'login': (_) => LoginScreen(),
        'home': (_) => const HomeScreen(),
        '/formRiesgos': (_) => const FormularioRiesgosScreen(),
        '/listadoRiesgos': (_) => const ListComunicacionRiesgos(),
        '/formEventos': (_) => const FormularioEventosScreen(),
        '/listadoEventos': (_) => const ListEventos(),
        '/logout': (context) {
          User? user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            return UserDetailsScreen(user: user);
          } else {
            return LoginScreen();
          }
        },
      }, //Centra el texto
      initialRoute: 'authChecker',
    );
  }
}

class AuthChecker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ); // Puedes poner una pantalla de carga aquí
        } else if (snapshot.hasData) {
          return const HomeScreen(); // Usuario autenticado, redirige a la pantalla principal
        } else {
          return LoginScreen(); // Usuario no autenticado, muestra la pantalla de login
        }
      },
    );
  }
}
