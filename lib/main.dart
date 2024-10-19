import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:splitsync/Authentication/Screens/Welcome/welcome_screen.dart';
import 'package:splitsync/Screens/home_screen.dart';
import 'package:splitsync/utils/constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:splitsync/utils/user_provider.dart';

// import 'package:firebase_auth/firebase_auth.dart';
String? userDataString;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  String apiKey = dotenv.env['API_KEY'] as String;
  String appId = dotenv.env['APP_ID'] as String;
  String messagingSenderId = dotenv.env['MESSAGE_SENDER_ID'] as String;
  String projectId = dotenv.env['PROJECT_ID'] as String;
  try {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: apiKey,
        appId: appId,
        messagingSenderId: messagingSenderId,
        projectId: projectId,
      ),
    );
  } catch (e) {
    print(e.toString());
  }
  print('app-start');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    reduce == false;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Split Sync',
      theme: ThemeData(
        primaryColor: kPrimaryColor,
        scaffoldBackgroundColor: Colors.white,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            foregroundColor: Colors.white,
            backgroundColor: kPrimaryColor,
            shape: const StadiumBorder(),
            maximumSize: const Size(double.infinity, 56),
            minimumSize: const Size(double.infinity, 56),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: kPrimaryLightColor,
          iconColor: kPrimaryColor,
          prefixIconColor: kPrimaryColor,
          contentPadding: EdgeInsets.symmetric(
              horizontal: defaultPadding, vertical: defaultPadding),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData) {
              // User is logged in
              return const HomeScreen();
            } else {
              // User is logged out
              return const WelcomeScreen();
            }
          } else {
            // Connection state is waiting or has an error
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
