import 'package:flutter/material.dart';
import 'package:projeto_pi/widgets/custom_text_field.dart';
import 'package:projeto_pi/screens/home/home_screen.dart';
import 'package:projeto_pi/services/api_service.dart'; // Importar o serviço de API

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  String _objective = 'Emagrecer'; // Objetivo padrão

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[700],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [_buildTopSection(), _buildRegisterForm(context)],
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.2,
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

  Widget _buildRegisterForm(BuildContext context) {
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
            controller: _nameController,
            hintText: 'Nome',
            icon: Icons.person,
          ),
          const SizedBox(height: 20.0),
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
          const SizedBox(height: 20.0),
          CustomTextField(
            controller: _confirmPasswordController,
            hintText: 'Confirmar senha',
            icon: Icons.lock,
            isPassword: true,
          ),
          const SizedBox(height: 20.0),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _weightController,
                  hintText: 'Peso (kg)',
                  icon: Icons.scale,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: CustomTextField(
                  controller: _heightController,
                  hintText: 'Altura (cm)',
                  icon: Icons.height,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20.0),
          const Text(
            'Objetivo',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildObjectiveOption('Emagrecer'),
              _buildObjectiveOption('Manter'),
              _buildObjectiveOption('Ganhar massa'),
            ],
          ),
          const SizedBox(height: 30.0),
          ElevatedButton(
            onPressed: () async {
              // Adicionado 'async'
              if (_passwordController.text != _confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('As senhas não coincidem.')),
                );
                return;
              }

              final response = await ApiService.registerUser(
                _nameController.text,
                _emailController.text,
                _passwordController.text,
                double.tryParse(_weightController.text) ??
                    0.0, // Converte para double, default 0.0 se inválido
                double.tryParse(_heightController.text) ??
                    0.0, // Converte para double, default 0.0 se inválido
                _objective,
              );

              if (response['success']) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(response['message'])));
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
              'Cadastrar',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
          const SizedBox(height: 20.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Já tem conta?', style: TextStyle(color: Colors.grey)),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Entrar',
                  style: TextStyle(color: Colors.green),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildObjectiveOption(String title) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _objective = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: _objective == title ? Colors.green : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _objective == title ? Colors.green : Colors.transparent,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: _objective == title ? Colors.white : Colors.grey[700],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
