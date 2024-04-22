import 'package:firebase_auth/firebase_auth.dart';
import 'package:splitsync/Database/users_data.dart';
import 'package:splitsync/Models/user.dart' as model;

class AuthEmailMethod {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String> signUpNewUser({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return 'The account already exists for that email.';
      }
    } catch (e) {
      return e.toString();
    }

    return 'Success';
  }

  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided for that user.';
      }
    }

    return 'Success';
  }

  Future<String> deleteUser() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    if (user != null) {
      try {
        await user.delete();
        return 'User deleted successfully';
      } catch (e) {
        return ('Error deleting user: $e');
      }
    } else {
      return ('No user signed in');
    }
  }

  Future<String?> getCurrentUserEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String email = user.email!;
      return email;
    } else {
      return null;
    }
  }

  Future<String> logOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      return 'Successfully logged out';
    } catch (e) {
      return 'Something went wrong';
    }
  }

  Future<model.User> getCurrentUser() async {
    final email = await getCurrentUserEmail() as String;
    final model.User user =
        await UsersData().getUserByEmail(emailToFind: email);
    return user;
  }
}
