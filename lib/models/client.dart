import 'package:flutter/foundation.dart';

class Client {
  final String id; // Ajoutez cette ligne pour définir l'identifiant du client
  final String name;
  final int age;
  final double initialWeight;
  final double actualWeight;

  Client({
    this.id = '', // Ajoutez cette ligne pour initialiser l'identifiant
    required this.name,
    required this.age,
    required this.initialWeight,
    required this.actualWeight
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id, // Ajoutez cette ligne pour inclure l'identifiant dans la carte des propriétés
      'name': name,
      'age': age,
      'initialWeight': initialWeight,
      'actualWeight': actualWeight,
    };
  }
}
