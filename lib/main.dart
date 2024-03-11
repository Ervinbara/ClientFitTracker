import 'package:flutter/material.dart';
import 'package:clientfit_tracker/models/client.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coach Companion',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
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
    Client(name: 'John Doe', age: 30, initialWeight: 75.0),
    Client(name: 'Jane Smith', age: 25, initialWeight: 65.0),
    Client(name: 'Alice Johnson', age: 35, initialWeight: 70.0),
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
  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController weightController = TextEditingController();

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
            Client newClient = Client(
              name: nameController.text,
              age: int.tryParse(ageController.text) ?? 0,
              initialWeight: double.tryParse(weightController.text) ?? 0.0,
            );
            Navigator.of(context).pop(newClient);
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
              initialWeight: double.tryParse(weightController.text) ?? 0.0,
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