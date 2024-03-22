// database.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/client.dart';

void addClientToFirestore(Client client) {
  FirebaseFirestore.instance.collection('clients').add(client.toMap());
}

Future<void> updateClientInFirestore(Client client) async {
  try {
    await FirebaseFirestore.instance.collection('clients').doc(client.id).update({
      'name': client.name,
      'age': client.age,
      'initialWeight': client.initialWeight,
      'actualWeight': client.actualWeight,
    });
    print('Client updated successfully');
  } catch (e) {
    print('Error updating client: $e');
  }
}


void deleteClientFromFirestore(Client client) {
  FirebaseFirestore.instance.collection('clients').doc(client.id).delete();
}
