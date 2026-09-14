import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static bool _registrationInProgress = false;

  bool get isRegistrationInProgress => _registrationInProgress;

  void beginRegistration() {
    _registrationInProgress = true;
  }

  void finishRegistration() {
    _registrationInProgress = false;
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges {
    return _auth.authStateChanges();
  }

  User? get currentUser {
    return _auth.currentUser;
  }

  Future<UserCredential> register(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> login(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
