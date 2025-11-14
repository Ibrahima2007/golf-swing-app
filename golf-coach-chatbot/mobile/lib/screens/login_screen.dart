import 'package:flutter/material.dart';
import 'package:mobile/screens/home_page.dart';
import 'package:provider/provider.dart';
import 'package:dob_input_field/dob_input_field.dart';
import 'package:country_picker/country_picker.dart';
import '../services/account_handler.dart';

class Globals {
  static String sessionToken = '';
}


InputDecoration inputBoxDecoration(String hint) { 
  return InputDecoration(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(),
    hintText: hint,
    counterText: '',
  );
}

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
                        decoration: inputBoxDecoration('First Name'),
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
                        decoration: inputBoxDecoration('Last Name'),
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
                        decoration: inputBoxDecoration('Email'),
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
                        decoration: inputBoxDecoration('Password (at least 8 characters)'),
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
                            if (success.isNotEmpty) {
                              Globals.sessionToken = success;
                              Navigator.push(
                                context,
                                MaterialPageRoute<void>(builder: (context) => const AccountCreationPagePart1()),
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
                        decoration: inputBoxDecoration('Email'),
                      ),
                    ),                  Padding(
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
                          return null;
                        },
                        decoration: inputBoxDecoration('Password'),
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
                            final success = await Provider.of<AccountHandler>(context, listen: false).login(_email, _password);
                            if (success.isNotEmpty) {
                              Globals.sessionToken = success;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Successful login!')),
                              );
                            }
                            else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Account not found.')),
                              );
                            }
                          }
                        },
                        child: const Text('Log In'),
                      ),
                    ),
                  ],
                )
              ),
              TextButton(
                onPressed: () {
                  Provider.of<AccountHandler>(context, listen: false).getUserInfo(Globals.sessionToken);
                },
                child: Text('Forgot Password')
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
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

var accountCreationHeader = Padding(
  padding: EdgeInsets.only(top:60, left: 20, right: 20, bottom: 20),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
      Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text("Welcome!", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          ),
          Text("Fill out your profile real quick!", style: TextStyle(fontSize: 16)),
        ]
      ),
      Padding(
        padding: EdgeInsets.only(left: 16),
        child: Image(image: AssetImage('images/icon.png'), width: 64, height: 64),
      ),
    ],
  ),
);

class AccountCreationPagePart1 extends StatefulWidget {
  const AccountCreationPagePart1({super.key});

  @override
  State<AccountCreationPagePart1> createState() => _AccountCreationPagePart1State();

}

class _AccountCreationPagePart1State extends State<AccountCreationPagePart1> {
  final _formKey = GlobalKey<FormState>();

  var _dateOfBirth = DateTime.now();
  String _role = '';
  String _privacy = '';
  String _golf = '';
  String _gender = '';
  String _country = 'Select your country';

  var pagePadding = EdgeInsets.symmetric(horizontal: 20, vertical: 16);

  String roleValue = "Role";
  var roles = ["Role", "Student", "Coach"];

  String privacyValue = "Privacy";
  var privacies = ["Privacy", "Public", "Private"];

  String golfValue = "Level of Golf";
  var golfs = ["Level of Golf", "Novice", "Amateur", "Professional", "Expert"];

  String genderValue = "Gender";
  var genders = ["Gender", "Male", "Female", "Other", "Prefer not to say"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      body: Center(
        child: Column(
          children: <Widget>[
            accountCreationHeader,
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: pagePadding,
                    child: DOBInputField(
                      inputDecoration: inputBoxDecoration('Date of Birth'),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                      showLabel: true,
                      fieldLabelText: "Date of Birth",
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      showCursor: true,
                      onDateSaved:(value) => _dateOfBirth = value,
                    ),
                  ),
                  Padding(
                    padding: pagePadding,
                    child: DropdownButtonFormField(
                      decoration: inputBoxDecoration('Role'),
                      initialValue: roleValue,
                      onChanged: (String? newValue) {
                        setState(() {
                          roleValue = newValue!;
                        });
                      },
                      onSaved:(newValue) => _role = newValue!,
                      validator: (value) => value == "Role" ? 'Please select a role' : null,
                      items: roles.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                  Padding(
                    padding: pagePadding,
                    child: DropdownButtonFormField(
                      decoration: inputBoxDecoration('Privacy'),
                      initialValue: privacyValue,
                      onChanged: (String? newValue) {
                        setState(() {
                          privacyValue = newValue!;
                        });
                      },
                      onSaved:(newValue) => _privacy = newValue!,
                      validator: (value) => value == "Privacy" ? 'Please select a privacy level' : null,
                      items: privacies.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                  Padding(
                    padding: pagePadding,
                    child: DropdownButtonFormField(
                      decoration: inputBoxDecoration('Level of Golf'),
                      initialValue: golfValue,
                      onChanged: (String? newValue) {
                        setState(() {
                          golfValue = newValue!;
                        });
                      },
                      onSaved:(newValue) => _golf = newValue!,
                      validator: (value) => value == "Level of Golf" ? 'Please select a golf level' : null,
                      items: golfs.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                  Padding(
                    padding: pagePadding,
                    child: DropdownButtonFormField(
                      decoration: inputBoxDecoration('Gender'),
                      initialValue: genderValue,
                      onChanged: (String? newValue) {
                        setState(() {
                          genderValue = newValue!;
                        });
                      },
                      onSaved:(newValue) => _gender = newValue!,
                      validator: (value) => value == "Gender" ? 'Please select a gender' : null,
                      items: genders.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                  Padding(
                    padding: pagePadding,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        minimumSize: Size(400, 50)
                      ),
                      child: Text(_country),
                      onPressed: () {
                        showCountryPicker(
                          context: context,
                          onSelect: (Country country) {
                            setState(() {
                              _country = country.name;
                            });
                          }
                        );
                      }
                    )
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
                          final success = await Provider.of<AccountHandler>(context, listen: false).updateAccountDetails(_dateOfBirth, _role, _privacy, _golf, _gender, _country, Globals.sessionToken);
                          if (success.isNotEmpty) {
                            Globals.sessionToken = success;
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(builder: (context) => const HomePage()),
                            );
                          }
                          else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Email already in use, please choose a different one.')),
                            );
                          }
                        }
                      },
                      child: Text('Submit'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}