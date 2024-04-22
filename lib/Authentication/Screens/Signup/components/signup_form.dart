import 'package:flutter/material.dart';
import 'package:splitsync/Authentication/Methods/email_login.dart';
import 'package:splitsync/Database/users_data.dart';
import 'package:splitsync/Screens/home_screen.dart';

import '../../../components/already_have_an_account_acheck.dart';
import '../../../../utils/constants.dart';
import '../../Login/login_screen.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({
    Key? key,
  }) : super(key: key);

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController =  TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  Future<String> _signUpUser() async {
    
    final username = _usernameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;

    var res = await AuthEmailMethod().signUpNewUser(username: username, email: email, password: password);
    
    if (res != 'Success') {
      return res;
    }

    res = await UsersData().addUser(username: username, email: email);
    return res;

  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: defaultPadding),
            child: TextFormField(
              controller: _usernameController,
              textInputAction: TextInputAction.next,
              cursorColor: kPrimaryColor,
              onSaved: (username) {},
              decoration: const InputDecoration(
                hintText: "Your username",
                prefixIcon: Padding(
                  padding: EdgeInsets.all(defaultPadding),
                  child: Icon(Icons.person),
                ),
              ),
            ),
          ),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            cursorColor: kPrimaryColor,
            onSaved: (email) {},
            decoration: const InputDecoration(
              hintText: "Your email",
              prefixIcon: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: Icon(Icons.email),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: defaultPadding),
            child: TextFormField(
              controller: _passwordController,
              textInputAction: TextInputAction.done,
              obscureText: true,
              cursorColor: kPrimaryColor,
              decoration: const InputDecoration(
                hintText: "Your password",
                prefixIcon: Padding(
                  padding: EdgeInsets.all(defaultPadding),
                  child: Icon(Icons.lock),
                ),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding / 2),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                _isLoading = true;
              });
              FocusScope.of(context).unfocus();
              final res = await _signUpUser();
              setState(() {
                _isLoading = false;
              });
              if (res == 'Success') {
                // ignore: use_build_context_synchronously
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomeScreen(),
                  ),
                );
              } else {
                print(res);
              }
            },
            child: _isLoading
                ? const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: Colors.white,
                        ),
                        SizedBox(width: 8.0),
                        Text(
                          "Loading..."
                        ),
                      ],
                    ),
                  )
                : Text(
                    "SignUp".toUpperCase(),
                  ),
          ),
          const SizedBox(height: defaultPadding),
          AlreadyHaveAnAccountCheck(
            login: false,
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const LoginScreen();
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}