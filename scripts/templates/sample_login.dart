import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoffeeLoginPage extends StatefulWidget {
  const CoffeeLoginPage({super.key});

  @override
  _CoffeeLoginPageState createState() => _CoffeeLoginPageState();
}

class _CoffeeLoginPageState extends State<CoffeeLoginPage> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFBF5EF),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 400.w,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32).r,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10.r)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/coffee.png',
                  height: 200.h,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 24.h),
                _buildTextField(
                  hint: 'Enter Username',
                  icon: Icons.person,
                  obscure: false,
                ),
                SizedBox(height: 16.h),
                _buildTextField(
                  hint: 'Enter Password',
                  icon: Icons.lock,
                  obscure: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(color: Colors.brown.shade700),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.local_cafe_rounded),
                  label: Text("Sign In"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.amber.shade100,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12).r,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                RichText(
                  text: TextSpan(
                    text: "Not Registered? ",
                    style: TextStyle(color: Colors.brown.shade400),
                    children: [
                      TextSpan(
                        text: "Sign Up",
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                        // Add tap gesture recognizer if needed
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    required IconData icon,
    required bool obscure,
    Widget? suffixIcon,
  }) {
    return TextField(
      obscureText: obscure,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.brown.shade400),
        suffixIcon: suffixIcon,
        hintText: hint,
        filled: true,
        fillColor: Color(0xFFF9EFD7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
