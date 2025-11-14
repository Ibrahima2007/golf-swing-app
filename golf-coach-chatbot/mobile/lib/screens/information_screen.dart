import 'package:flutter/material.dart';
import 'package:mobile/screens/profile_screen.dart';

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

  // Date Picker Method
  Future<void> pickDOB() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime(2005),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        dob = "${date.month}/${date.day}/${date.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryGreen = Colors.green;
    final skyBlue = Colors.lightBlue;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 Top Row (Back + Profile Icon)
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

            // 🔹 Centered Content
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // DOB Field (Date Picker)
                      buildDatePicker("Date of Birth", dob, pickDOB),

                      // Dropdowns
                      buildDropdown(
                        "Role",
                        role,
                        (v) => setState(() => role = v),
                        ["Player", "Coach", "Viewer"],
                      ),
                      buildDropdown(
                        "Privacy",
                        privacy,
                        (v) => setState(() => privacy = v),
                        ["Public", "Friends Only", "Private"],
                      ),
                      buildDropdown(
                        "Level of Golf",
                        golfLevel,
                        (v) => setState(() => golfLevel = v),
                        ["Beginner", "Intermediate", "Advanced", "Pro"],
                      ),
                      buildDropdown(
                        "Gender",
                        gender,
                        (v) => setState(() => gender = v),
                        ["Male", "Female", "Other"],
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

                      // 🔹 Save Button (Matches your theme)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: skyBlue,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(250, 55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          // TODO: Save user data to backend or local storage
                          Navigator.push(context,
                              MaterialPageRoute<void>(builder: (context) => const ProfileScreen()));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Changes Saved"),
                            ),
                          );
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

  // 🔹 Reusable Dropdown Builder
  Widget buildDropdown(String label, String? value,
      Function(String?) onChanged, List<String> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
              items: items
                  .map((item) =>
                      DropdownMenuItem(value: item, child: Text(item)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 DOB Date Picker Field UI
  Widget buildDatePicker(
      String label, String? value, VoidCallback onTapHandler) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                  Text(value ?? "Select DOB",
                      style: const TextStyle(fontSize: 15)),
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
