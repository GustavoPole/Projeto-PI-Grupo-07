import 'package:flutter/material.dart';
import 'package:projeto_pi/screens/auth/register_screen.dart';
import 'package:projeto_pi/screens/home/home_screen.dart';
import 'package:projeto_pi/widgets/custom_text_field.dart';
import 'package:projeto_pi/services/api_service.dart'; // Importar o serviço de API

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[700],
      body: SingleChildScrollView(
        child: Column(children: [_buildTopSection(), _buildLoginForm(context)]),
      ),
    );
  }

  Widget _buildTopSection() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      alignment: Alignment.bottomCenter,
      child: const Text(
        'DietHub',
        style: TextStyle(
          color: Colors.white,
          fontSize: 48,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Seu plano alimentar começa aqui',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 30.0),
          CustomTextField(
            controller: _emailController,
            hintText: 'Email',
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 20.0),
          CustomTextField(
            controller: _passwordController,
            hintText: 'Senha',
            icon: Icons.lock,
            isPassword: true,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // Lógica para esqueci a senha
              },
              child: const Text(
                'Esqueceu a senha?',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: () async {
              // Adicionado 'async'
              final response = await ApiService.loginUser(
                _emailController.text,
                _passwordController.text,
              );

              if (response['success']) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Login bem-sucedido!'),
                  ), // Mensagem de sucesso
                );
                // Você pode salvar o token JWT aqui para futuras requisições
                // final String token = response['token'];
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              } else {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(response['message'])));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            child: const Text(
              'Entrar',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
          const SizedBox(height: 20.0),
          const Center(child: Text('ou')),
          const SizedBox(height: 20.0),
          OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RegisterScreen()),
              );
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              side: const BorderSide(color: Colors.green),
            ),
            child: const Text(
              'Criar conta',
              style: TextStyle(fontSize: 18, color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }
}
