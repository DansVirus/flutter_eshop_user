import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_eshop_user/pages/view_telescope_page.dart';
import 'package:flutter_eshop_user/utils/colors.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_service.dart';

class LoginSection extends StatefulWidget {
  final VoidCallback onSuccess;
  final Function(String) onFailure;

  const LoginSection({
    super.key,
    required this.onSuccess,
    required this.onFailure,
  });

  @override
  State<LoginSection> createState() => _LoginSectionState();
}

class _LoginSectionState extends State<LoginSection> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isObscure = true;

 /* @override
  void initState() {
    _emailController.text = 'user1@gmail.com';
    _passwordController.text = '123456';
    super.initState();
  }*/

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.email),
                  labelText: 'Email Address',
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      !value.contains('@') ||
                      !value.contains('.')) {
                    return 'Please provide a valid email';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: TextFormField(
                controller: _passwordController,
                obscureText: _isObscure,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock),
                  labelText: 'Password',
                  suffixIcon: IconButton( // Use IconButton instead of Icon for interactivity
                    icon: Icon(
                      _isObscure ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure; // Toggle the password visibility
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty ||
                      value.trim().length < 6) {
                    return 'Please provide a valid password';
                  }
                  return null;
                },
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kShrineBrown900,
                  foregroundColor: kShrineSurfaceWhite,
                ),
                child: const Text('SIGN IN'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _login() async {
    if(_formKey.currentState!.validate()) {
      EasyLoading.show(status: 'Please wait...');
      final email = _emailController.text;
      final password = _passwordController.text;

      try {
        final user = await AuthService.login(email, password);
        EasyLoading.dismiss();
        widget.onSuccess();
        context.goNamed(ViewTelescopePage.routeName);
      } on FirebaseAuthException catch(error) {
        EasyLoading.dismiss();
        widget.onFailure(error.message!);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
