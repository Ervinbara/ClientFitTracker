import 'package:flutter/material.dart';
import 'package:clientfit_tracker/models/client.dart';

class ClientDetailPage extends StatelessWidget {
  final Client client;

  ClientDetailPage({required this.client});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails du client'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Nom: ${client.name}'),
            Text('Age: ${client.age}'),
            Text('Poids initial: ${client.initialWeight} kg'),
            Text('Poids actuel: ${client.actualWeight} kg'),
            // Ajoutez d'autres détails du client ici selon vos besoins
          ],
        ),
      ),
    );
  }
}
