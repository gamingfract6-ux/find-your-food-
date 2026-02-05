import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final AuthService instance = AuthService._init();
  AuthService._init();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  String? _userToken;
  String? _userName;
  String? _userEmail;
  String? _userPhotoUrl;

  // Getters
  String? get userToken => _userToken;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  String? get userPhotoUrl => _userPhotoUrl;
  bool get isAuthenticated => _userToken != null;

  // Initialize - Check for saved session
  Future<bool> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _userToken = prefs.getString('auth_token');
    _userName = prefs.getString('user_name');
    _userEmail = prefs.getString('user_email');
    _userPhotoUrl = prefs.getString('user_photo_url');
    
    return isAuthenticated;
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      
      if (account == null) {
        // User canceled the sign-in
        return false;
      }

      final GoogleSignInAuthentication auth = await account.authentication;
      
      // Get ID token for backend validation
      final idToken = auth.idToken;
      
      if (idToken == null) {
        throw Exception('Failed to get ID token');
      }

      // In production, you would send this token to your backend for validation
      // For now, we'll use it as our auth token
      _userToken = idToken;
      _userName = account.displayName ?? 'User';
      _userEmail = account.email;
      _userPhotoUrl = account.photoUrl;

      // Save session
      await _saveSession();

      return true;
    } catch (e) {
      print('Google Sign-In Error: $e');
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _clearSession();
      
      _userToken = null;
      _userName = null;
      _userEmail = null;
      _userPhotoUrl = null;
    } catch (e) {
      print('Sign Out Error: $e');
    }
  }

  // Save session to SharedPreferences
  Future<void> _saveSession() async {
    final prefs = await SharedPreferences.getInstance();
    if (_userToken != null) await prefs.setString('auth_token', _userToken!);
    if (_userName != null) await prefs.setString('user_name', _userName!);
    if (_userEmail != null) await prefs.setString('user_email', _userEmail!);
    if (_userPhotoUrl != null) await prefs.setString('user_photo_url', _userPhotoUrl!);
  }

  // Clear session
  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_photo_url');
  }

  // Check if user is signed in
  Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }

  // Silent sign-in (auto sign-in if previously signed in)
  Future<bool> signInSilently() async {
    try {
      final account = await _googleSignIn.signInSilently();
      if (account != null) {
        final auth = await account.authentication;
        final idToken = auth.idToken;
        
        if (idToken != null) {
          _userToken = idToken;
          _userName = account.displayName ?? 'User';
          _userEmail = account.email;
          _userPhotoUrl = account.photoUrl;
          await _saveSession();
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Silent Sign-In Error: $e');
      return false;
    }
  }
}
