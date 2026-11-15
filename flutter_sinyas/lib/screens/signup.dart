import 'package:flutter/material.dart';
import 'package:flutter_sinyas/widgets/grey_button.dart';
import '/widgets/button.dart';

/*

  Log In

  SizedBox 12

  email or username
  password
  forgot password


  button
  not a user yet? create an account
  ---- or ----
  google fb 

*/

class SignupScreen extends StatefulWidget{
  const SignupScreen({super.key});
  
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>{
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if(_formKey.currentState!.validate()){
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(seconds: 2));
      if(!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logged in ass ${_emailController.text}')),
      );
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: SafeArea(
        child: 
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxHeight < 1000;
              final panelTop = constraints.maxHeight * (compact ? 0.16 : 0.25);
              
              if (!compact){ // Tablet Screen
                return Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text('heyt'),
                    ),
                    Expanded(
                      flex: 1,
                      child: Center(
                          child: Text('hey'),
                        ),
                    )
                  ],
                );
              } 
              return Center( // Mobile View
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Email or username
                      Text(
                        'Log in',
                        style: TextStyle(
                          color: Color(0xFF002247),
                          fontSize: 80,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 0,
                              offset: const Offset(2, 2),
                            ),
                          ],
                          
                        ),
                      ),
                      TextFormField(
                        controller: _emailController,
                        style: const TextStyle(
                          fontSize: 32,
                          color: Color(0xFF002247),
                        ),
                        decoration: InputDecoration(
                          hintText: 'Email',
                          hintStyle: const TextStyle(
                            color: Color(0xFFA3A3A3),
                            fontSize: 32,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFFAFCFA),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                            color: Color(0xFFEBECEB),
                            width: 2,
                          ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                            color: Color(0xFF1EADC3),
                            width: 2,
                          )
                          )
                        ),
                        // color: Color(0xFFFAFCFA),
                      ),
                      const SizedBox(height: 12),
                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(
                          fontSize: 32,
                          color: Color(0xFF002247),
                        ),
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: Icon(   
                              _obscurePassword ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                              _obscurePassword = !_obscurePassword;
                            }
                            );
                          }
                          ),
                          hintText: 'Password',
                          hintStyle: const TextStyle(
                            color: Color(0xFFA3A3A3),
                            fontSize: 32,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFFAFCFA),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                            color: Color(0xFFEBECEB),
                            width: 2,
                          ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                            color: Color(0xFF1EADC3),
                            width: 2,
                          )
                          )
                        ),
                        // color: Color(0xFFFAFCFA),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: Text(
                            'Forgot password?',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 24,
                              color: Color(0xFFA3A3A3),
                            )
                          )
                        )
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity, 
                        child: Button(
                          title: 'LOGIN', 
                          onTap: () {
                            String enteredName = _emailController.text;
                            String enteredPassword = _passwordController.text;
                            debugPrint("Password: $enteredPassword");
                            debugPrint("Email/username: $enteredName");
                        },
                      ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text(
                            'Already have an account?',
                            style: TextStyle(
                              fontSize: 24,
                            )),
                          const SizedBox(width: 4),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/login');
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF1EADC3),
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,            
                            ),
                            child: const Text(
                              'Log in.',
                              style: TextStyle(
                                fontSize: 24,
                              ))
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: const [
                          Expanded(child: Divider(thickness: 2)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'or',
                              style: TextStyle(
                                fontSize: 24,
                              )),
                          ),
                          Expanded(child: Divider(thickness: 2)),
                        ],
                      ),
                      Row(
                        spacing: 12,
                          children: [
                            Expanded(
                              child: GreyButton(title: 'Google', 
                              icon:  Icon(Icons.language, color: Color(0xFF1877F2)),
                              onTap: () => {})
                            ),
                            Expanded(
                              child: GreyButton(title: 'Facebook', 
                              icon: Icon(Icons.facebook, color: Color(0xFF1877F2)),
                              onTap: () => {})
                            ),
                          ],
                        )
                     ]
                  )
                ),
                )
              );
            } 
          ),
        )
    );
  }
}