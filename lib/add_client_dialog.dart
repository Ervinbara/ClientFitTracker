import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddClientDialog extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Ajouter un Nouveau Client'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            controller: nameController,
            decoration: InputDecoration(labelText: 'Nom'),
          ),
          TextField(
            controller: ageController,
            decoration: InputDecoration(labelText: 'Age'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: weightController,
            decoration: InputDecoration(labelText: 'Poids Initial (kg)'),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Fermer la boîte de dialogue sans rien faire
          },
          child: Text('Annuler'),
        ),
        TextButton(
          onPressed: () {
            // Ajouter un nouveau client et fermer la boîte de dialogue
            FirebaseFirestore.instance.collection('clients').add({
              'name': nameController.text,
              'age': int.tryParse(ageController.text) ?? 0,
              'initialWeight': double.tryParse(weightController.text) ?? 0.0,
            });
            Navigator.of(context).pop(); // Fermer le dialogue
          },
          child: Text('Ajouter'),
        ),
      ],
    );
  }
}
// TODO Implement this library.