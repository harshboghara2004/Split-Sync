import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splitsync/Authentication/Methods/email_login.dart';
import 'package:splitsync/Database/users_data.dart';
import 'package:splitsync/Models/user.dart';
import 'package:splitsync/Screens/home_screen.dart';
import 'package:splitsync/utils/user_provider.dart';
import '../../../components/already_have_an_account_acheck.dart';
import '../../../../utils/constants.dart';
import '../../Signup/signup_screen.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({
    Key? key,
  }) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  Future<String> _loginUser() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    final res =
        await AuthEmailMethod().loginUser(email: email, password: password);
    return res;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            cursorColor: kPrimaryColor,
            decoration: const InputDecoration(
              hintText: "Your email",
              prefixIcon: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: Icon(Icons.person),
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
          const SizedBox(height: defaultPadding),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                _isLoading = true;
              });
              FocusScope.of(context).unfocus();
              final res = await _loginUser();
              setState(() {
                _isLoading = false;
              });
              print(res);
              if (res == 'Success') {
                User user = await UsersData()
                    .getUserByEmail(emailToFind: _emailController.text);
                final key = await UsersData()
                    .getFriendKeyByEmail(email: _emailController.text);
                user.friendsKey = key;
                // ignore: use_build_context_synchronously
                Provider.of<UserProvider>(context, listen: false).setUser(user);
                // ignore: use_build_context_synchronously
                print('to-home');
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (Route<dynamic> route) => false, // Remove all routes
                );
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
                        Text("Loading..."),
                      ],
                    ),
                  )
                : Text(
                    "Login".toUpperCase(),
                  ),
          ),
          const SizedBox(height: defaultPadding),
          AlreadyHaveAnAccountCheck(
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const SignUpScreen();
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
