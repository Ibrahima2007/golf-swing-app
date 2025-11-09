import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/account_handler.dart';


class AccountCreationPage extends StatefulWidget {
  const AccountCreationPage({super.key});

  @override
  State<AccountCreationPage> createState() => _AccountCreationPageState();

  }

class _AccountCreationPageState extends State<AccountCreationPage> {
  final _formKey = GlobalKey<FormState>();
  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _password = '';

  var pagePadding = EdgeInsets.symmetric(horizontal: 20, vertical: 16);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      body: SingleChildScrollView(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Padding(
          padding: EdgeInsets.only(top: 80),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: pagePadding,
                child: Image(image: AssetImage('images/icon.png')),
              ),
              Padding(
                padding: pagePadding,
                child: Text(
                  "Create Your Account",
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: pagePadding,
                      child: TextFormField(
                        onSaved: (value) {
                          _firstName = value!;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your first name';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(),
                          hintText: 'First Name',
                        ),
                      ),
                    ),                  Padding(
                      padding: pagePadding,
                      child: TextFormField(
                        onSaved: (value) {
                          _lastName = value!;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your last name';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(),
                          hintText: 'Last Name',
                        ),
                      ),
                    ),
                    Padding(
                      padding: pagePadding,
                      child: TextFormField(
                        onSaved: (value) {
                          _email = value!;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(),
                          hintText: 'Email',
                        ),
                      ),
                    ),
                    Padding(
                      padding: pagePadding,
                      child: TextFormField(
                        obscureText: true,
                        onSaved: (value) {
                          _password = value!;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 8) {
                            return 'Please ensure your password is at least 8 characters long';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(),
                          hintText: 'Password (at least 8 characters)',
                        ),
                      ),
                    ),
                   Padding(
                      padding: pagePadding,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlue,
                          foregroundColor: Colors.white,
                          minimumSize: Size(300, 50)
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            final success = await Provider.of<AccountHandler>(context, listen: false).createAccount(_firstName, _lastName, _email, _password);
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Account created successfully!')),
                              );
                            }
                            else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Email already in use, please choose a different one.')),
                              );
                            }
                          }
                        },
                        child: const Text('Create Account'),
                      ),
                    ),
                  ],
                )
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(builder: (context) => const LoginScreen()),
                  );
                },
                child: Text('Already a member? Sign in')
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();

  }

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';

  var pagePadding = EdgeInsets.symmetric(horizontal: 20, vertical: 32);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      body: SingleChildScrollView(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Padding(
          padding: EdgeInsets.only(top: 80),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: pagePadding,
                child: Image(image: AssetImage('images/icon.png')),
              ),
              Padding(
                padding: pagePadding,
                child: Text(
                  "Log In",
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: pagePadding,
                      child: TextFormField(
                        onSaved: (value) {
                          _email = value!;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(),
                          hintText: 'Email',
                        ),
                      ),
                    ),                  Padding(
                      padding: pagePadding,
                      child: TextFormField(
                        onSaved: (value) {
                          _password = value!;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(),
                          hintText: 'Password',
                        ),
                      ),
                    ),
                   Padding(
                      padding: pagePadding,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlue,
                          foregroundColor: Colors.white,
                          minimumSize: Size(300, 50)
                        ),
                        onPressed: () {
                          //if (_formKey.currentState!.validate()) {
                            //_formKey.currentState!.save();
                            //Provider.of<AccountHandler>(context, listen: false).createAccount(_firstName, _lastName, _email, _password);
                          //}
                        },
                        child: const Text('Log In'),
                      ),
                    ),
                  ],
                )
              ),
              TextButton(
                onPressed: () {
                  return;
                },
                child: Text('Forgot Password')
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(builder: (context) => const AccountCreationPage()),
                  );
                },
                child: Text('Don\'t have an account?')
              ),
            ],
          ),
        ),
      ),
    );
  }
}