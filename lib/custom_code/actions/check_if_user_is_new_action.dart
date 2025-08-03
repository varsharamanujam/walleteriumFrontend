// Automatic FlutterFlow imports
// Imports other custom actions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
import 'package:firebase_auth/firebase_auth.dart';

Future<bool> checkIfUserIsNewAction() async {
  // This action checks if the currently authenticated user's
  // account was created in the last 10 seconds.

  final user = FirebaseAuth.instance.currentUser;

  // If there's no user or no metadata, they are not a new user in this context.
  if (user == null || user.metadata.creationTime == null) {
    return false;
  }

  final creationTime = user.metadata.creationTime!;
  final currentTime = DateTime.now();

  // Return true if the difference is less than 10 seconds, otherwise false.
  return currentTime.difference(creationTime).inSeconds < 10;
}
