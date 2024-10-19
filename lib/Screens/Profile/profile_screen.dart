import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splitsync/Authentication/Methods/email_login.dart';
import 'package:splitsync/Authentication/Screens/Welcome/welcome_screen.dart';
import 'package:splitsync/Models/user.dart';
import 'package:splitsync/utils/user_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    User currentUser = Provider.of<UserProvider>(context).currentUser!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Username: ${currentUser.username}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Email: ${currentUser.email}',
              style: const TextStyle(fontSize: 18),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () async {
                await AuthEmailMethod().logOut();
                // ignore: use_build_context_synchronously
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WelcomeScreen(),
                  ),
                );
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
