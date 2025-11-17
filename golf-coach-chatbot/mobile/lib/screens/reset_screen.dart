import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/account_handler.dart';
import 'login_screen.dart';

InputDecoration inputBoxDecoration(String hint) { 
  return InputDecoration(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(),
    hintText: hint,
    counterText: '',
  );
}

class ResetPasswordSendPage extends StatefulWidget {
  const ResetPasswordSendPage({super.key});

  @override
  State<ResetPasswordSendPage> createState() => _ResetPasswordSendPage();

  }

class _ResetPasswordSendPage extends State<ResetPasswordSendPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';

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
                  "What is your email?",
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
                        decoration: inputBoxDecoration('Email'),
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
                            final success = await Provider.of<AccountHandler>(context, listen: false).sendResetPasswordEmail(_email);
                            if (success.isNotEmpty) {
                              
                              Navigator.push(
                                context,
                                MaterialPageRoute<void>(builder: (context) => const ResetPasswordCodePage()),
                              );
                            }
                            else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Account not found.')),
                              );
                            }
                          }
                        },
                        child: const Text('Send Email'),
                      ),
                    ),
                  ],
                )
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Go back to log in')
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ResetPasswordCodePage extends StatefulWidget {
  const ResetPasswordCodePage({super.key});

  @override
  State<ResetPasswordCodePage> createState() => _ResetPasswordCodePage();

  }

class _ResetPasswordCodePage extends State<ResetPasswordCodePage> {
  final _formKey = GlobalKey<FormState>();
  String _reset = '';

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
                  "Input the code you were emailed below",
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
                          _reset = value!;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your code';
                          }
                          return null;
                        },
                        decoration: inputBoxDecoration('Code'),
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
                            final success = await Provider.of<AccountHandler>(context, listen: false).resetPasswordCode(_reset);
                            if (success.isNotEmpty) {
                              Globals.sessionToken = success;
                              Navigator.push(
                                context,
                                MaterialPageRoute<void>(builder: (context) => const ResetPasswordPage()),
                              );
                            }
                            else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Invalid Code')),
                              );
                            }
                          }
                        },
                        child: const Text('Submit Code'),
                      ),
                    ),
                  ],
                )
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Didn\'t recieve code?')
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPage();

  }

class _ResetPasswordPage extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  String _password = '';
  String _confirmPassword = '';

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
                  "Enter your new password",
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
                          _password = value!;
                        },
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.length < 8) {
                            return 'Please ensure your new password is at least 8 characters long';
                          }
                          return null;
                        },
                        decoration: inputBoxDecoration('Enter new password'),
                      ),
                    ),
                    Padding(
                      padding: pagePadding,
                      child: TextFormField(
                        onSaved: (value) {
                          _confirmPassword = value!;
                        },
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.length < 8) {
                            return 'Please ensure your new password is at least 8 characters long';
                          }
                          return null;
                        },
                        decoration: inputBoxDecoration('Enter new password'),
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
                            if (_password == _confirmPassword) {
                            final success = await Provider.of<AccountHandler>(context, listen: false).resetPassword(_password, Globals.sessionToken);
                              if (success.isNotEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Password succesfully changed')),
                                );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(builder: (context) => const AccountCreationPage()),
                                );
                              }
                              else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Failed to reset password')),
                                );
                              }
                            }
                            else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Please ensure your passwords match')),
                              );
                            }
                          }
                        },
                        child: const Text('Change Password'),
                      ),
                    ),
                  ],
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
}
