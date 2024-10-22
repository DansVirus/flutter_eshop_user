import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_eshop_user/auth/auth_service.dart';
import 'package:flutter_eshop_user/providers/user_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../pages/view_telescope_page.dart';
import '../utils/colors.dart';

class RegisterSection extends StatefulWidget {
  final VoidCallback onSuccess;
  final Function(String) onFailure;
  const RegisterSection({super.key, required this.onSuccess, required this.onFailure,});

  @override
  State<RegisterSection> createState() => _RegisterSectionState();
}

class _RegisterSectionState extends State<RegisterSection> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  bool _isObscure = true;

  @override
  void initState() {
    _emailController.text = 'user1@gmail.com';
    _passwordController.text = '123456';
    _nameController.text = 'Dino';
    _surnameController.text = 'Dasdas';
    _phoneNumberController.text = '6942357864';
    super.initState();
  }
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
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person),
                  labelText: 'Name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Field is empty!';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: TextFormField(
                controller: _surnameController,
                keyboardType: TextInputType.name,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person),
                  labelText: 'Surname',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Field is empty';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: TextFormField(
                controller: _phoneNumberController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.phone),
                  labelText: 'Mobile Number',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty ||
                  value.trim().length < 10) {
                    return 'Please provide a valid phone number';
                  }
                  return null;
                },
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _register,

                style: ElevatedButton.styleFrom(
                  backgroundColor: kShrineBrown900,
                  foregroundColor: kShrineSurfaceWhite,
                ),
                child: const Text('SIGN UP'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _register() async {
    if(_formKey.currentState!.validate()) {
      EasyLoading.show(status: 'Please wait...');
      final email = _emailController.text;
      final password = _passwordController.text;
      final name = _nameController.text;
      final surname = _surnameController.text;
      final phone = _phoneNumberController.text;

      try {
        final user = await AuthService.register(email, password);
        await Provider.of<UserProvider>(context, listen: false)
        .addUser(user: user, name: name, surname: surname, phone: phone);
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
    _nameController.dispose();
    _surnameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }
}


