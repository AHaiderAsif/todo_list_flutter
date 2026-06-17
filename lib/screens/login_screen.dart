import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _formkey = GlobalKey<FormState>();
  bool _isLogin = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('ToDo App', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Container(
          height: size.height,
          width: size.width,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFA5D6A7),
                Color(0xFFFFFFFF),
                Color(0xFFE8F5E9),
                Color(0xFFA5D6A7),
              ],
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 140),
              child: SizedBox(
                width: size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32).withAlpha(20),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Iconsax.task_square5,
                        color: Color(0xFF2E7D32),
                        size: 58,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        _isLogin ? 'Welcome Back!' : 'Create an account',
                        style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 24, letterSpacing: -0.5),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Form(
                      key: _formkey,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          spacing: 18,
                          children: [
                            TextFormField(
                              controller: _email,
                              style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w600),
                              decoration: InputDecoration(
                                hintText: 'Email Address',
                                label: const Text('Email'),
                                labelStyle: const TextStyle(color: Colors.black54),
                                floatingLabelStyle: const TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 1.5)),
                                filled: true,
                                fillColor: Colors.white54,
                                prefixIcon: const Icon(Iconsax.sms, color: Color(0xFF2E7D32)),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              validator: (value) => value != null && value.contains('@') ? null : 'Enter a valid email address',
                            ),
                            TextFormField(
                              controller: _password,
                              style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w600),
                              decoration: InputDecoration(
                                hintText: 'Password',
                                label: const Text('Password'),
                                labelStyle: const TextStyle(color: Colors.black54),
                                floatingLabelStyle: const TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 1.5)),
                                filled: true,
                                fillColor: Colors.white54,
                                prefixIcon: const Icon(Iconsax.lock, color: Color(0xFF2E7D32)),
                              ),
                              obscureText: true,
                              textInputAction: TextInputAction.done,
                              validator: (value) => value != null && value.length >= 6 ? null : 'Password must be at least 6 characters',
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                      child: authProvider.isLoading
                          ? const CircularProgressIndicator(color: Color(0xFF2E7D32))
                          : ElevatedButton(
                        onPressed: () async {
                          if (_formkey.currentState!.validate()) {
                            bool success;

                            if (_isLogin) {
                              success = await context.read<AuthProvider>().loginUser(
                                _email.text.trim(),
                                _password.text.trim(),
                              );
                            } else {
                              success = await context.read<AuthProvider>().signUpUser(
                                _email.text.trim(),
                                _password.text.trim(),
                              );
                            }

                            if (success) {
                              print("Auth Success!");
                              if (context.mounted) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                                );
                              }
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(authProvider.errorMessage ?? "Authentication Failed"),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              }
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF11998e),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 54),
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(_isLogin ? 'Sign In' : 'Get Started', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 5,
                        children: [
                          Text(
                            _isLogin ? "Don't have an account?" : "Already have an account?",
                            style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isLogin = !_isLogin;
                                _email.clear();
                                _password.clear();
                                _formkey.currentState?.reset();
                              });
                            },
                            child: Text(
                              _isLogin ? 'Sign Up' : 'Log In',
                              style: const TextStyle(color: Color(0xFF11998e), fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}