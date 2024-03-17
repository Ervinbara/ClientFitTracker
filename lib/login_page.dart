import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool _isCreatingAccount = false;

  Future<void> _login(BuildContext context) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      print('User logged in: ${userCredential.user!.uid}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login successful.'),
          duration: Duration(seconds: 3),
        ),
      );
      // Naviguer vers la page suivante après la connexion réussie
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      print('Login error: $e');
      // Afficher un message d'erreur à l'utilisateur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed. Please check your email and password.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final FirebaseAuth _auth = FirebaseAuth.instance;

      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        final UserCredential authResult = await _auth.signInWithCredential(credential);
        final User? user = authResult.user;

        if (user != null) {
          assert(!user.isAnonymous);
          assert(await user.getIdToken() != null);

          final User currentUser = _auth.currentUser!;
          assert(user.uid == currentUser.uid);

          print('signInWithGoogle succeeded: $user');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Google Sign-In successful.'),
              duration: Duration(seconds: 3),
            ),
          );

          // Vérifie si l'utilisateur est nouvellement enregistré
          if (authResult.additionalUserInfo!.isNewUser) {
            // Ajouter ici le code pour enregistrer les informations de l'utilisateur dans la base de données Firebase
            // Par exemple :
            await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
              'displayName': user.displayName ?? '',
              'email': user.email ?? '',
              'photoURL': user.photoURL ?? '',
            });
            print('New user registered: ${user.uid}');
          }

          // Naviguer vers la page suivante après la connexion réussie
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } catch (error) {
      print('signInWithGoogle failed: $error');
      // Afficher un message d'erreur à l'utilisateur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google Sign-In failed. Please try again.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }



  Future<void> _createAccount(BuildContext context) async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Passwords do not match.'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Enregistrer les informations de l'utilisateur dans Firestore
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'email': emailController.text,
        // Ajoutez d'autres champs que vous souhaitez sauvegarder
      });

      print('User created: ${userCredential.user!.uid}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Account created successfully.'),
          duration: Duration(seconds: 3),
        ),
      );

      Navigator.pushReplacementNamed(context, '/home');

    } catch (e) {

      print('Account creation error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Account creation failed. Please try again.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isCreatingAccount ? 'Create Account' : 'Login'), // Modifier le titre de l'AppBar
        leading: _isCreatingAccount ? IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _isCreatingAccount = false;
            });
          },
        ) : null,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
              ),
            ),
            SizedBox(height: 16.0),
            if (_isCreatingAccount) ...[
              // Formulaire de création de compte
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  hintText: 'Confirm your password',
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () => _createAccount(context),
                child: Text('Create Account'),
              ),
            ] else ...[
              // Formulaire de connexion
              ElevatedButton(
                onPressed: () => _login(context),
                child: Text('Login'),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () => _signInWithGoogle(context),
                child: Text('Login with Google'),
              ),
              SizedBox(height: 16.0),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isCreatingAccount = true;
                  });
                },
                child: Text('Create Account'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
