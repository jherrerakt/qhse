import 'package:firebase_auth/firebase_auth.dart';

class GlobalData {
  static String imagenCuerpo = "";
  static User user = FirebaseAuth.instance.currentUser!;
}
