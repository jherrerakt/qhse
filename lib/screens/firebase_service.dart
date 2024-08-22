import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

class FirebaseServices {
  final databaseReference = FirebaseDatabase.instance.ref();
  final FirebaseStorage storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signInAnonymously() async {
    try {
      await _auth.signInAnonymously();
    } catch (e) {
      print("Error al iniciar sesión anónimamente: $e");
    }
  }

  Future<String> uploadImageToStorage(File image) async {
    final String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final Reference storageRef = storage.ref().child('images/$fileName');
    final UploadTask uploadTask = storageRef.putFile(image);

    final TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    final String downloadURL = await taskSnapshot.ref.getDownloadURL();

    await databaseReference.child('images').push().set({'url': downloadURL});

    return downloadURL;
  }

  void writeNewMessage(String message) {
    databaseReference.child('messages').push().set({'message': message});
  }
}
