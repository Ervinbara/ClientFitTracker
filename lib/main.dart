import 'package:flutter/material.dart';
import 'package:clientfit_tracker/models/client.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Importez les options de configuration Firebase
import 'login_page.dart';
import 'models/client.dart'; // Importez votre modèle Client
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/home': (context) => MyHomePage(), // Ajout de la route pour la page d'accueil
      },
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Client> clients = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des Clients'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _signOut, // Appel de la fonction de déconnexion
          ),
        ],
      ),
      body: StreamBuilder(
        stream: getClientsByUser(), // Utiliser la fonction pour récupérer les clients de l'utilisateur connecté
        builder: (BuildContext context, AsyncSnapshot<List<Client>> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            // Afficher la liste des clients associés à l'utilisateur connecté
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                final client = snapshot.data![index];
                return ListTile(
                  title: Text(client.name),
                  subtitle: Text('Age: ${client.age}, Poids initial: ${client.initialWeight} kg'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _deleteClient(context, client);
                    },
                  ),
                  onTap: () {
                    _editClient(context, client);
                  },
                );
              },
            );
          }
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

  void _signOut() async {
    try {
      await FirebaseAuth.instance.signOut(); // Déconnexion de l'utilisateur de Firebase
      Navigator.pushReplacementNamed(context, '/login'); // Redirection vers la page de login
    } catch (e) {
      print('Erreur lors de la déconnexion : $e');
    }
  }

  void _addClient(BuildContext context) async {
    // Récupérer l'utilisateur actuellement connecté
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
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
          addClientToFirestore(result, user.uid); // Ajouter le nouveau client à Firestore
        });
      }
    } else {
      // L'utilisateur n'est pas connecté, gérer cette situation en conséquence
      // Par exemple, afficher un message d'erreur ou rediriger vers la page de connexion
      Navigator.pushReplacementNamed(context, '/login');
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

      updateClientInFirestore(result); // Mettre à jour le client dans Firestore
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
          onPressed: () async {
            // Récupérer les valeurs saisies dans les champs du formulaire
            String name = nameController.text;
            int age = int.tryParse(ageController.text) ?? 0;
            double initialWeight = double.tryParse(weightController.text) ?? 0.0;

            // Vérifier si les champs de texte ne sont pas vides
            if (name.isNotEmpty && age != 0 && initialWeight != 0.0) {
              // Ajouter un nouveau client avec les valeurs récupérées
              Client newClient = Client(
                name: name,
                age: age,
                initialWeight: initialWeight,
              );

              Navigator.of(context).pop(newClient); // Fermer le dialogue et renvoyer le nouveau client
            } else {
              // Afficher un message d'erreur ou empêcher l'ajout du client
              // Vous pouvez ajouter un SnackBar ou une boîte de dialogue pour informer l'utilisateur
              // que tous les champs doivent être remplis.
            }
          },
          child: Text('Ajouter'),
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
              id: widget.client.id, // Passer l'ID du client existant
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

// Fonction pour récupérer les clients associés à l'utilisateur connecté
Stream<List<Client>> getClientsByUser() {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    return FirebaseFirestore.instance
        .collection('clients')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((document) => Client(
      id: document.id,
      name: document['name'],
      age: document['age'],
      initialWeight: document['initialWeight'],
    ))
        .toList());
  } else {
    // L'utilisateur n'est pas connecté, retourner un flux vide
    return Stream.value([]);
  }
}

// Fonction pour ajouter un client à Firestore avec l'ID de l'utilisateur
void addClientToFirestore(Client client, String userId) async {
  await FirebaseFirestore.instance.collection('clients').add({
    'userId': userId,
    'name': client.name,
    'age': client.age,
    'initialWeight': client.initialWeight,
  });
}

// Fonction pour mettre à jour un client dans Firestore
void updateClientInFirestore(Client client) async {
  await FirebaseFirestore.instance.collection('clients').doc(client.id).update({
    'name': client.name,
    'age': client.age,
    'initialWeight': client.initialWeight,
  });
}

// Fonction pour supprimer un client de Firestore
void deleteClientFromFirestore(Client client) async {
  await FirebaseFirestore.instance.collection('clients').doc(client.id).delete();
}
