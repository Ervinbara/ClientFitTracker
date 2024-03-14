// database.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/client.dart';

void addClientToFirestore(Client client) {
  FirebaseFirestore.instance.collection('clients').add(client.toMap());
}

void updateClientInFirestore(Client client) {
  FirebaseFirestore.instance.collection('clients').doc(client.id).update(client.toMap());
}

void deleteClientFromFirestore(Client client) {
  FirebaseFirestore.instance.collection('clients').doc(client.id).delete();
}
