import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. SIGN UP LOGIC (Auth + Firestore Data Save)
  Future<String?> signUpUser({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      // user register
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Firestore Database user details
      if (credential.user != null) {
        await _firestore.collection('users').doc(credential.user!.uid).set({
          'uid': credential.user!.uid,
          'fullName': fullName.trim(),
          'email': email.trim(),
          'phone': phone.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return null; // Null means Success
    } on FirebaseAuthException catch (e) {
      return e.message; // Firebase Error Message
    } catch (e) {
      return e.toString();
    }
  }

  // LOGIN LOGIC
  Future<String?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // LOGOUT LOGIC
  Future<void> signOut() async {
    await _auth.signOut();
  }
  //google sigin
  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;

      await googleSignIn.initialize();

      // 3. Pehle purana session clear karein taake account selection popup theek se aaye
      await googleSignIn.signOut();

      // Authenticate (Sign-in trigger)
      if (!googleSignIn.supportsAuthenticate()) {
        return "Google Sign-In is not supported on this platform.";
      }

      final GoogleSignInAccount googleUser = await googleSignIn.authenticate();

      // get uthentication tokens
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final GoogleSignInClientAuthorization authorization = await googleUser
          .authorizationClient
          .authorizeScopes(['email', 'profile']);

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: authorization.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(
          credential);
      User? user = userCredential.user;

      if (user != null) {
        var userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (!userDoc.exists) {
          await _firestore.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'fullName': user.displayName ?? 'Google User',
            'email': user.email ?? '',
            'phone': user.phoneNumber ?? '',
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }
      return null; // success
    } catch (e) {
      return e.toString();
    }
  }


}