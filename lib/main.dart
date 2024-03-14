import 'package:flutter/material.dart';
import 'package:clientfit_tracker/models/client.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Importez les options de configuration Firebase
import 'my_widget.dart';
import 'add_client_dialog.dart'; // Importer le dialogue pour ajouter un client
import 'models/client.dart'; // Importez votre modèle Client
import 'database.dart'; // Importez la fonction addClient

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Utilisez les options de configuration Firebase
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mon Application',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Client> clients = [
    Client(name: 'John Doe', age: 30, initialWeight: 75.0, id: ''),
    Client(name: 'Jane Smith', age: 25, initialWeight: 65.0, id: ''),
    Client(name: 'Alice Johnson', age: 35, initialWeight: 70.0, id: ''),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des Clients'),
      ),
      body: ListView.builder(
        itemCount: clients.length,
        itemBuilder: (BuildContext context, int index) {
          final client = clients[index];
          return ListTile(
            title: Text(client.name),
            subtitle: Text('Age: ${client.age}, Poids initial: ${client.initialWeight} kg'),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                // Appeler la méthode de suppression lorsqu'un bouton de suppression est appuyé
                _deleteClient(context, client);
              },
            ),
            onTap: () {
              _editClient(context, client);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addClient(context);
        },
        tooltip: 'Ajouter un Client',
        child: Icon(Icons.add),
      ),
    );
  }

  void _addClient(BuildContext context) async {
    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddClientDialog(); // Créer et afficher une boîte de dialogue pour ajouter un nouveau client
      },
    );

    if (result != null) {
      // Si result est différent de null, cela signifie qu'un nouveau client a été ajouté
      setState(() {
        clients.add(result); // Ajouter le nouveau client à la liste des clients
        addClientToFirestore(result); // Ajouter le nouveau client à Firestore
      });
    }
  }

  void _editClient(BuildContext context, Client client) async {
    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditClientDialog(client: client); // Créer et afficher une boîte de dialogue pour modifier le client
      },
    );

    if (result != null) {
      // Si result est différent de null, cela signifie que le client a été modifié
      setState(() {
        // Mettre à jour les détails du client dans la liste des clients
        int index = clients.indexOf(client);
        clients[index] = result;
        updateClientInFirestore(result); // Mettre à jour le client dans Firestore
      });
    }
  }

  void _deleteClient(BuildContext context, Client client) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation de suppression'),
          content: Text('Voulez-vous vraiment supprimer ce client ?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fermer la boîte de dialogue sans rien faire
              },
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                // Supprimer le client de la liste
                setState(() {
                  clients.remove(client);
                  deleteClientFromFirestore(client); // Supprimer le client de Firestore
                });
                Navigator.of(context).pop(); // Fermer la boîte de dialogue
              },
              child: Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }
}

class AddClientDialog extends StatefulWidget {
  @override
  _AddClientDialogState createState() => _AddClientDialogState();
}

class _AddClientDialogState extends State<AddClientDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Ajouter un client'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: InputDecoration(labelText: 'Nom'),
            onChanged: (value) => {/* Mettre à jour le nom du client */},
          ),
          TextField(
            decoration: InputDecoration(labelText: 'Age'),
            onChanged: (value) => {/* Mettre à jour l'âge du client */},
          ),
          TextField(
            decoration: InputDecoration(labelText: 'Poids initial'),
            onChanged: (value) => {/* Mettre à jour le poids initial du client */},
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Créer un nouvel objet Client avec les données du formulaire
            Client newClient = Client(
              name: 'John Doe', // Remplacez par les données du formulaire
              age: 30, // Remplacez par les données du formulaire
              initialWeight: 75.5, id: '1', // Remplacez par les données du formulaire
            );

            // Ajouter le nouveau client à Firestore
            addClientToFirestore(newClient);

            // Fermer le dialogue
            Navigator.of(context).pop();
          },
          child: Text('Ajouter'),
        ),
      ],
    );
  }
}

class EditClientDialog extends StatefulWidget {
  final Client client;

  EditClientDialog({required this.client});

  @override
  _EditClientDialogState createState() => _EditClientDialogState();
}

class _EditClientDialogState extends State<EditClientDialog> {
  late TextEditingController nameController;
  late TextEditingController ageController;
  late TextEditingController weightController;

  @override
  void initState() {
    super.initState();
    // Initialiser les contrôleurs de texte avec les détails du client existant
    nameController = TextEditingController(text: widget.client.name);
    ageController = TextEditingController(text: widget.client.age.toString());
    weightController = TextEditingController(text: widget.client.initialWeight.toString());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Modifier le Client'),
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
            // Modifier le client et fermer la boîte de dialogue
            Client updatedClient = Client(
              name: nameController.text,
              age: int.tryParse(ageController.text) ?? 0,
              initialWeight: double.tryParse(weightController.text) ?? 0.0, id: '',
            );
            Navigator.of(context).pop(updatedClient);
          },
          child: Text('Enregistrer'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    // Libérer les ressources des contrôleurs de texte
    nameController.dispose();
    ageController.dispose();
    weightController.dispose();
    super.dispose();
  }
}
