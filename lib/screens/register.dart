import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({
    super.key,
    required this.onRegisterSuccess,
  });

  final VoidCallback onRegisterSuccess;

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController fullNameController =
      TextEditingController();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  // ============================================================
  // STATE
  // ============================================================

  bool obscurePassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  // ============================================================
  // FIREBASE REGISTER
  // ============================================================

  Future<void> _register() async {
    final fullName = fullNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // ------------------------------------------------------------
    // VALIDATION
    // ------------------------------------------------------------

    if (fullName.isEmpty) {
      _showMessage(
        'Please enter your full name.',
        isError: true,
      );
      return;
    }

    if (email.isEmpty) {
      _showMessage(
        'Please enter your university email.',
        isError: true,
      );
      return;
    }

    if (!email.contains('@')) {
      _showMessage(
        'Please enter a valid email address.',
        isError: true,
      );
      return;
    }

    if (password.isEmpty) {
      _showMessage(
        'Please create a password.',
        isError: true,
      );
      return;
    }

    if (password.length < 6) {
      _showMessage(
        'Password must be at least 6 characters.',
        isError: true,
      );
      return;
    }

    // ------------------------------------------------------------
    // START LOADING
    // ------------------------------------------------------------

    setState(() {
      isLoading = true;
    });

    try {
      // ----------------------------------------------------------
      // CREATE FIREBASE ACCOUNT
      // ----------------------------------------------------------

      final UserCredential userCredential =
          await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // ----------------------------------------------------------
      // SAVE FULL NAME TO FIREBASE AUTH
      // ----------------------------------------------------------

      await userCredential.user?.updateDisplayName(fullName);

      // ----------------------------------------------------------
      // SIGN OUT
      //
      // Firebase automatically logs the newly-created user in.
      // We sign them out because your flow is:
      //
      // Register
      //     ↓
      // Account created
      //     ↓
      // Login page
      //     ↓
      // User enters credentials
      //     ↓
      // Dashboard
      // ----------------------------------------------------------

      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      // ----------------------------------------------------------
      // CLEAR REGISTER FORM
      // ----------------------------------------------------------

      fullNameController.clear();
      emailController.clear();
      passwordController.clear();

      // ----------------------------------------------------------
      // RETURN TO LOGIN
      // ----------------------------------------------------------

      widget.onRegisterSuccess();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message;

      switch (e.code) {
        case 'email-already-in-use':
          message =
              'An account already exists with this email.';
          break;

        case 'invalid-email':
          message =
              'Please enter a valid email address.';
          break;

        case 'weak-password':
          message =
              'Password is too weak. Use at least 6 characters.';
          break;

        case 'operation-not-allowed':
          message =
              'Email/password registration is not enabled in Firebase.';
          break;

        case 'network-request-failed':
          message =
              'Network error. Please check your internet connection.';
          break;

        case 'too-many-requests':
          message =
              'Too many requests. Please try again later.';
          break;

        default:
          message =
              e.message ?? 'Registration failed. Please try again.';
      }

      _showMessage(
        message,
        isError: true,
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Something went wrong. Please try again.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // SHOW MESSAGE
  // ============================================================

  void _showMessage(
    String message, {
    required bool isError,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Colors.red
            : Colors.green,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Create your account',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xff142d4b),
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Join your university campus network.',
          style: TextStyle(
            fontSize: 11,
            color: Color(0xff4b5563),
          ),
        ),

        const SizedBox(height: 20),

        // ========================================================
        // FULL NAME
        // ========================================================

        const _RegisterLabel('FULL NAME'),

        const SizedBox(height: 5),

        _RegisterInput(
          icon: Icons.person_outline,
          hint: 'Your full name',
          controller: fullNameController,
          keyboardType: TextInputType.name,
        ),

        const SizedBox(height: 15),

        // ========================================================
        // UNIVERSITY EMAIL
        // ========================================================

        const _RegisterLabel('UNIVERSITY EMAIL'),

        const SizedBox(height: 5),

        _RegisterInput(
          icon: Icons.alternate_email,
          hint: 'name.student@puthisastra.edu.kh',
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
        ),

        const SizedBox(height: 15),

        // ========================================================
        // PASSWORD
        // ========================================================

        const _RegisterLabel('PASSWORD'),

        const SizedBox(height: 5),

        _RegisterInput(
          icon: Icons.lock_outline,
          hint: 'Create a secure password',
          controller: passwordController,
          obscure: obscurePassword,
          suffix: IconButton(
            icon: Icon(
              obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              size: 17,
            ),
            onPressed: () {
              setState(() {
                obscurePassword =
                    !obscurePassword;
              });
            },
          ),
        ),

        const SizedBox(height: 21),

        // ========================================================
        // CREATE ACCOUNT BUTTON
        // ========================================================

        SizedBox(
          width: double.infinity,
          height: 42,
          child: ElevatedButton(
            onPressed: isLoading ? null : _register,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff062b55),
              foregroundColor: Colors.white,
              disabledBackgroundColor:
                  const Color(0xff8a9aaa),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),

        const SizedBox(height: 14),

        const Center(
          child: Text(
            'By signing up, you agree to the Terms of Service.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9,
              color: Color(0xff6b7280),
            ),
          ),
        ),
      ],
    );
  }
}

// ================================================================
// REGISTER LABEL
// ================================================================

class _RegisterLabel extends StatelessWidget {
  const _RegisterLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 9,
        fontWeight: FontWeight.w700,
        color: Color(0xff243a55),
        letterSpacing: .2,
      ),
    );
  }
}

// ================================================================
// REGISTER INPUT
// ================================================================

class _RegisterInput extends StatelessWidget {
  const _RegisterInput({
    required this.icon,
    required this.hint,
    required this.controller,
    this.obscure = false,
    this.suffix,
    this.keyboardType,
  });

  final IconData icon;
  final String hint;
  final TextEditingController controller;
  final bool obscure;
  final Widget? suffix;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(
        fontSize: 12,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontSize: 11,
          color: Color(0xff788190),
        ),
        prefixIcon: Icon(
          icon,
          size: 17,
          color: const Color(0xff4c5767),
        ),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xfff0f4fe),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(
            color: Color(0xffc8cfdb),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(
            color: Color(0xffc8cfdb),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(
            color: Color(0xff062b55),
            width: 1.2,
          ),
        ),
      ),
    );
  }
}