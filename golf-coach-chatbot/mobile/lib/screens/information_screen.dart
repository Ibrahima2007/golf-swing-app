import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/screens/login_screen.dart';
import 'package:mobile/screens/profile_screen.dart';
import 'package:mobile/services/account_handler.dart';

// TEMPORARY — Replace this with SharedPreferences later
var sessionToken = Globals.sessionToken;

class InformationPage extends StatefulWidget {
  const InformationPage({super.key});

  @override
  State<InformationPage> createState() => _InformationPageState();
}

class _InformationPageState extends State<InformationPage> {
  String? dob;
  String? role;
  String? privacy;
  String? golfLevel;
  String? gender;
  String? country;

  final accountHandler = AccountHandler();

  @override
  void initState() {
    super.initState();
    loadUserInfo();
  }

  Future<void> loadUserInfo() async {
    if (sessionToken.isEmpty) return;

    final userInfo = await accountHandler.getUserInfo(sessionToken);
    if (userInfo == null) return;

    setState(() {
      dob = formatDob(userInfo['date-of-birth']);
      role = userInfo['role'];
      privacy = userInfo['privacy'];
      golfLevel = userInfo['level-of-golf'];
      gender = userInfo['gender'];
      country = userInfo['country'];
    });
  }

  Future<void> pickDOB() async {
    DateTime initialDate = DateTime.now();
    if (dob != null) {
      try {
        initialDate = DateFormat('MM/dd/yyyy').parse(dob!);
      } catch (_) {}
    }

    DateTime? date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        dob = DateFormat('MM/dd/yyyy').format(date);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final skyBlue = Colors.lightBlue;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  IconButton(
                    icon: const Icon(Icons.person),
                    onPressed: () {
                      Navigator.pushNamed(context, '/profile');
                    },
                  ),
                ],
              ),
            ),

            // CONTENT
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      buildDatePicker("Date of Birth", dob, pickDOB),
                      buildDropdown(
                        "Role",
                        role,
                        (v) => setState(() => role = v),
                        ["Role", "Student", "Coach"],
                      ),
                      buildDropdown(
                        "Privacy",
                        privacy,
                        (v) => setState(() => privacy = v),
                        ["Privacy", "Public", "Private"],
                      ),
                      buildDropdown(
                        "Level of Golf",
                        golfLevel,
                        (v) => setState(() => golfLevel = v),
                        ["Level of Golf", "Novice", "Amateur", "Professional", "Expert"],
                      ),
                      buildDropdown(
                        "Gender",
                        gender,
                        (v) => setState(() => gender = v),
                        ["Gender", "Male", "Female", "Other", "Prefer not to say"],
                      ),
                      buildDropdown(
                        "Country",
                        country,
                        (v) => setState(() => country = v),
                        [
                          "United States",
                          "Canada",
                          "United Kingdom",
                          "Australia",
                          "Other"
                        ],
                      ),
                      const SizedBox(height: 40),

                      // SAVE CHANGES BUTTON
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: skyBlue,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(250, 55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          if (sessionToken.isEmpty) return;

                          // Update all fields in the database
                          final result = await accountHandler.updateAccountDetails(
                            dob,
                            role,
                            privacy,
                            golfLevel,
                            gender,
                            country,
                            sessionToken,
                          );

                          if (result == "success") {
                            // Show success message
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Changes Saved")),
                            );

                            // Navigate back to ProfileScreen
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ProfileScreen(),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Failed to save changes")),
                            );
                          }
                        },
                        child: const Text(
                          "Save Changes",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dropdown builder
  Widget buildDropdown(
    String label,
    String? value,
    Function(String?) onChanged,
    List<String> items,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              underline: const SizedBox(),
              hint: Text("Select $label"),
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  // Date Picker builder
  Widget buildDatePicker(String label, String? value, VoidCallback onTapHandler) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 5),
          GestureDetector(
            onTap: onTapHandler,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(value ?? "Select DOB", style: const TextStyle(fontSize: 15)),
                  const Icon(Icons.calendar_today),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// DOB formatter
String? formatDob(String? raw) {
  if (raw == null) return null;

  try {
    // RFC 1123 format
    DateFormat rfcFormat = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'", 'en_US');
    DateTime parsed = rfcFormat.parseUtc(raw).toLocal();
    return DateFormat('MM/dd/yyyy').format(parsed);
  } catch (_) {
    try {
      // ISO 8601 fallback
      DateTime parsed = DateTime.parse(raw);
      return DateFormat('MM/dd/yyyy').format(parsed);
    } catch (e) {
      print("DOB format error: $e");
      return null;
    }
  }
}
