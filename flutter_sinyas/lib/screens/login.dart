import 'package:flutter/material.dart';
import 'package:flutter_sinyas/widgets/grey_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/widgets/branding_panel.dart';
import '/widgets/button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_isLoading || !(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final user = response.user;
      if (user == null) {
        throw const AuthException('Login succeeded without returning a user.');
      }

      final profile = await Supabase.instance.client
          .from('profiles')
          .select('display_name')
          .eq('id', user.id)
          .maybeSingle();

      if (!mounted) return;

      if (profile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Your profile was not found. Please contact support.',
            ),
          ),
        );
        return;
      }

      Navigator.pushReplacementNamed(context, '/home', arguments: profile);
    } on AuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not connect to Supabase: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 1000;
            final panelTop = constraints.maxHeight * (compact ? 0.16 : 0.25);

            if (!compact) {
              // Tablet Screen
              return Row(
                children: [
                  Expanded(flex: 1, child: BrandingPanel()),
                  Expanded(flex: 2, child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(64),
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
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: const [AutofillHints.email],
                              style: const TextStyle(
                                fontSize: 32,
                                color: Color(0xFF002247),
                              ),
                              decoration: InputDecoration(
                                hintText: 'Email',
                                hintStyle: const TextStyle(
                                  color: Color(0xFFA3A3A3),
                                  fontSize: 32,
                                  height: 1.2,
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
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Enter your email';
                                }
                                return null;
                              },
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
                                    _obscurePassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                hintText: 'Password',
                                hintStyle: const TextStyle(
                                  color: Color(0xFFA3A3A3),
                                  fontSize: 32,
                                  height: 1.2,
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
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Enter your password';
                                }
                                return null;
                              },
                              // color: Color(0xFFFAFCFA),
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                style: ButtonStyle(
                                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                                ),
                                onPressed: () {},
                                child: Text(
                                  'Forgot password?',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: Color(0xFFA3A3A3),
                                    fontFamily: 'Dongle',
                                    height: 1.2
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: Button(
                                title: _isLoading ? 'SIGNING IN...' : 'LOG IN',
                                onTap: _handleLogin,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Text(
                                  'Not a user yet?',
                                  style: TextStyle(fontSize: 24),
                                ),
                                const SizedBox(width: 4),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacementNamed(context, '/signup');
                                  },
                                  style: ButtonStyle(
                                    foregroundColor: WidgetStateProperty.all(const Color(0xFF1EADC3)),
                                    overlayColor: WidgetStateProperty.all(Colors.transparent),
                                    padding: WidgetStateProperty.all(EdgeInsets.zero),
                                    minimumSize: WidgetStateProperty.all(Size.zero),
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    'Create an account.',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontFamily: 'Dongle',
                                      height: 1.2,
                                    ),
                                  ),
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
                                  child: Text('or', style: TextStyle(fontSize: 24)),
                                ),
                                Expanded(child: Divider(thickness: 2)),
                              ],
                            ),
                            Row(
                              spacing: 12,
                              children: [
                                Expanded(
                                  child: GreyButton(
                                    title: 'Google',
                                    icon: Icon(
                                      Icons.language,
                                      color: Color(0xFF1877F2),
                                    ),
                                    onTap: () => {},
                                  ),
                                ),
                                Expanded(
                                  child: GreyButton(
                                    title: 'Facebook',
                                    icon: Icon(
                                      Icons.facebook,
                                      color: Color(0xFF1877F2),
                                    ),
                                    onTap: () => {},
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextButton.icon(
                              onPressed: () =>
                                  Navigator.pushNamed(context, '/quiz-demo'),
                              icon: const Icon(Icons.preview_outlined),
                              label: const Text('Preview lesson layouts'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
            return Center(
              // Mobile View
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
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
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
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter your email';
                          }
                          return null;
                        },
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
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
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
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter your password';
                          }
                          return null;
                        },
                        // color: Color(0xFFFAFCFA),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          style: ButtonStyle(
                            overlayColor: WidgetStateProperty.all(Colors.transparent),
                          ),
                          onPressed: () {},
                          child: Text(
                            'Forgot password?',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 24,
                              color: Color(0xFFA3A3A3),
                              fontFamily: 'Dongle',
                              height: 1.2
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: Button(
                          title: _isLoading ? 'SIGNING IN...' : 'LOG IN',
                          onTap: _handleLogin,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text(
                            'Not a user yet?',
                            style: TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: 4),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/signup');
                            },
                            style: ButtonStyle(
                              foregroundColor: WidgetStateProperty.all(const Color(0xFF1EADC3)),
                              overlayColor: WidgetStateProperty.all(Colors.transparent),
                              padding: WidgetStateProperty.all(EdgeInsets.zero),
                              minimumSize: WidgetStateProperty.all(Size.zero),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Create an account.',
                              style: TextStyle(
                                fontSize: 24,
                                fontFamily: 'Dongle',
                                height: 1.2,
                              ),
                            ),
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
                            child: Text('or', style: TextStyle(fontSize: 24)),
                          ),
                          Expanded(child: Divider(thickness: 2)),
                        ],
                      ),
                      Row(
                        spacing: 12,
                        children: [
                          Expanded(
                            child: GreyButton(
                              title: 'Google',
                              icon: Icon(
                                Icons.language,
                                color: Color(0xFF1877F2),
                              ),
                              onTap: () => {},
                            ),
                          ),
                          Expanded(
                            child: GreyButton(
                              title: 'Facebook',
                              icon: Icon(
                                Icons.facebook,
                                color: Color(0xFF1877F2),
                              ),
                              onTap: () => {},
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextButton.icon(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/quiz-demo'),
                        icon: const Icon(Icons.preview_outlined),
                        label: const Text('Preview lesson layouts'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
