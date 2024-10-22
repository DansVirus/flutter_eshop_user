import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// A service class for handling user authentication using Firebase Authentication.
class AuthService {

  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Retrieves the currently authenticated user, if available.
  static User? get currentUser => _auth.currentUser;

  /// Registers a new user with the provided [email] and [password].
  ///
  /// This method creates a new user account in Firebase Authentication and
  /// returns the authenticated [User] object once registration is successful.
  /// Throws an exception if registration fails.
  static Future<User> register(String email, String password) async {
    final credentials = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    return credentials.user!;
  }

  /// Logs in a user with the provided [email] and [password].
  ///
  /// This method signs the user in using Firebase Authentication and returns
  /// the authenticated [User] object once login is successful.
  /// Throws an exception if the login attempt fails.
  static Future<User> login(String email, String password) async {
    final credentials = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return credentials.user!;
  }

  /// Signs in a user using Google authentication.
  ///
  /// This method initiates a Google sign-in flow, retrieves the user's Google credentials,
  /// and authenticates the user with Firebase using those credentials.
  /// Returns a [UserCredential] object on successful sign-in.
  static Future<UserCredential> signWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken
    );

    return _auth.signInWithCredential(credential);
  }

  /// Logs out the currently authenticated user.
  ///
  /// This method signs the user out of Firebase Authentication.
  /// It returns a `Future` that completes once the sign-out process is finished.
  static Future<void> logout() {
    return _auth.signOut();
  }

}