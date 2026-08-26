import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'register.dart';
import 'dashboard.dart';

class HomeLogin extends StatefulWidget {
  const HomeLogin({super.key});

  @override
  State<HomeLogin> createState() => _HomeLoginState();
}

class _HomeLoginState extends State<HomeLogin> {
  bool isLogin = true;
  bool obscurePassword = true;
  bool isLoading = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ============================================================
  // FIREBASE LOGIN
  // ============================================================

  Future<void> _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // ------------------------------------------------------------
    // VALIDATION
    // ------------------------------------------------------------

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Please enter your email and password.', isError: true);
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
      // FIREBASE LOGIN
      // ----------------------------------------------------------

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      // ----------------------------------------------------------
      // LOGIN SUCCESS
      // ----------------------------------------------------------

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message;

      switch (e.code) {
        case 'invalid-credential':
          message = 'Invalid email or password.';
          break;

        case 'user-not-found':
          message = 'No account found with this email.';
          break;

        case 'wrong-password':
          message = 'Incorrect password.';
          break;

        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;

        case 'user-disabled':
          message = 'This account has been disabled.';
          break;

        case 'too-many-requests':
          message = 'Too many login attempts. Please try again later.';
          break;

        case 'network-request-failed':
          message = 'Network error. Please check your internet connection.';
          break;

        default:
          message = e.message ?? 'Login failed. Please try again.';
      }

      _showMessage(message, isError: true);
    } catch (e) {
      if (!mounted) return;

      _showMessage('Something went wrong. Please try again.', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // REGISTER SUCCESS
  // ============================================================

  void _registerSuccess() {
    if (!mounted) return;

    setState(() {
      isLogin = true;
    });

    // Clear login fields
    emailController.clear();
    passwordController.clear();

    _showMessage('Account created successfully. Please login.', isError: false);
  }

  // ============================================================
  // SHOW MESSAGE
  // ============================================================

  void _showMessage(String message, {required bool isError}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f6fd),
      body: SafeArea(
        child: SizedBox.expand(
          child: Container(
            color: const Color(0xfff5f6fd),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                20,
                62,
                20,
                24 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                children: [
                  // ==================================================
                  // MAIN CARD
                  // ==================================================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: const Color(0xffd2d7e0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ==================================================
                        // LOGO / TITLE
                        // ==================================================
                        const Row(
                          children: [
                            Icon(
                              Icons.school_outlined,
                              color: Color(0xff062b55),
                              size: 25,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Campus Found',
                              style: TextStyle(
                                color: Color(0xff062b55),
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // ==================================================
                        // LOGIN / REGISTER TABS
                        // ==================================================
                        Row(
                          children: [
                            _Tab(
                              label: 'LOGIN',
                              selected: isLogin,
                              onTap: () {
                                setState(() {
                                  isLogin = true;
                                });
                              },
                            ),

                            const SizedBox(width: 22),

                            _Tab(
                              label: 'REGISTER',
                              selected: !isLogin,
                              onTap: () {
                                setState(() {
                                  isLogin = false;
                                });
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        // ==================================================
                        // LOGIN / REGISTER FORM
                        // ==================================================
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          child: isLogin
                              ? _LoginForm(
                                  key: const ValueKey('login'),
                                  emailController: emailController,
                                  passwordController: passwordController,
                                  obscurePassword: obscurePassword,
                                  isLoading: isLoading,
                                  togglePassword: () {
                                    setState(() {
                                      obscurePassword = !obscurePassword;
                                    });
                                  },
                                  onLogin: _login,
                                )
                              : RegisterForm(
                                  key: const ValueKey('register'),
                                  onRegisterSuccess: _registerSuccess,
                                ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 27),

                  // ==================================================
                  // FOOTER
                  // ==================================================
                  const Icon(
                    Icons.verified_user_outlined,
                    size: 12,
                    color: Color(0xff7f8999),
                  ),

                  const SizedBox(height: 3),

                  const Text(
                    'OFFICIAL STUDENT SERVICES',
                    style: TextStyle(
                      fontSize: 8,
                      letterSpacing: 1,
                      color: Color(0xff7f8999),
                    ),
                  ),

                  const SizedBox(height: 7),

                  const Text(
                    '© 2024 University of Puthisastra. All Rights Reserved.',
                    style: TextStyle(fontSize: 8, color: Color(0xff9ca3af)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ================================================================
// TAB
// ================================================================

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 34,
        alignment: Alignment.topCenter,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected
                  ? const Color(0xff062b55)
                  : const Color(0xffd7dae1),
              width: selected ? 2 : 1,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? const Color(0xff062b55) : const Color(0xff3f4652),
          ),
        ),
      ),
    );
  }
}

// ================================================================
// LOGIN FORM
// ================================================================

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.togglePassword,
    required this.onLogin,
    required this.isLoading,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback togglePassword;
  final VoidCallback onLogin;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Welcome Back',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xff142d4b),
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Log in with your university credentials.',
          style: TextStyle(fontSize: 11, color: Color(0xff4b5563)),
        ),

        const SizedBox(height: 21),

        const _Label('UNIVERSITY EMAIL'),

        const SizedBox(height: 5),

        _Input(
          icon: Icons.alternate_email,
          hint: 'name.student@puthisastra.edu.kh',
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
        ),

        const SizedBox(height: 16),

        const Row(
          children: [
            Expanded(child: _Label('PASSWORD')),
            Text(
              'FORGOT PASSWORD?',
              style: TextStyle(
                fontSize: 9,
                color: Color(0xff16375c),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),

        const SizedBox(height: 5),

        _Input(
          icon: Icons.lock_outline,
          hint: '••••••••',
          controller: passwordController,
          obscure: obscurePassword,
          suffix: IconButton(
            icon: Icon(
              obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              size: 17,
            ),
            onPressed: togglePassword,
          ),
        ),

        const SizedBox(height: 16),

        // ==========================================================
        // LOGIN BUTTON
        // ==========================================================
        SizedBox(
          width: double.infinity,
          height: 42,
          child: ElevatedButton(
            onPressed: isLoading ? null : onLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff062b55),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xff8a9aaa),
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
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 5),
                      Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
          ),
        ),

        const SizedBox(height: 22),

        const _Divider(),

        const SizedBox(height: 20),

        const _SocialButtons(),

        const SizedBox(height: 26),

        const Center(
          child: Column(
            children: [
              Text(
                'New to the university network?',
                style: TextStyle(fontSize: 10, color: Color(0xff5b6470)),
              ),
              SizedBox(height: 3),
              Text(
                'Create an Account',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xffb36b1e),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ================================================================
// LABEL
// ================================================================

class _Label extends StatelessWidget {
  const _Label(this.text);

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
// INPUT
// ================================================================

class _Input extends StatelessWidget {
  const _Input({
    required this.icon,
    required this.hint,
    this.controller,
    this.obscure = false,
    this.suffix,
    this.keyboardType,
  });

  final IconData icon;
  final String hint;
  final TextEditingController? controller;
  final bool obscure;
  final Widget? suffix;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 12),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 11, color: Color(0xff788190)),
        prefixIcon: Icon(icon, size: 17, color: const Color(0xff4c5767)),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xfff0f4fe),
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: Color(0xffc8cfdb)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: Color(0xffc8cfdb)),
        ),
      ),
    );
  }
}

// ================================================================
// DIVIDER
// ================================================================

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'OR CONTINUE WITH',
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: .5,
              color: Color(0xff4b5563),
            ),
          ),
        ),
        Expanded(child: Divider()),
      ],
    );
  }
}

// ================================================================
// SOCIAL BUTTONS
// ================================================================

class _SocialButtons extends StatelessWidget {
  const _SocialButtons();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _Social(
            label: 'Google',
            child: Text(
              'G',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xff4285f4),
                fontSize: 15,
              ),
            ),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _Social(
            label: 'Apple',
            child: Icon(Icons.apple, size: 16, color: Colors.black),
          ),
        ),
      ],
    );
  }
}

// ================================================================
// SOCIAL BUTTON
// ================================================================

class _Social extends StatelessWidget {
  const _Social({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          side: const BorderSide(color: Color(0xffc8cfdb)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            child,
            const SizedBox(width: 7),
            Text(
              label,
              style: const TextStyle(color: Color(0xff27364a), fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
