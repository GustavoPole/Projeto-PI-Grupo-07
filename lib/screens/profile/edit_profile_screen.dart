import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projeto_pi/providers/app_state.dart';
import 'package:projeto_pi/services/api_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaAtualController = TextEditingController();
  final _novaSenhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  bool _isSavingProfile = false;
  bool _isSavingPassword = false;
  int _selectedTab = 0; // 0 = dados, 1 = senha

  static const _green = Color(0xFF2E7D32);
  static const _greenDark = Color(0xFF1B5E20);

  @override
  void initState() {
    super.initState();
    final state = context.read<AppState>();
    _nomeController.text = state.userName;
    _emailController.text = state.userEmail;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaAtualController.dispose();
    _novaSenhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              error ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: error ? const Color(0xFFD32F2F) : _green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _saveProfile() async {
    final nome = _nomeController.text.trim();
    final email = _emailController.text.trim();

    if (nome.isEmpty || email.isEmpty) {
      _snack('Preencha todos os campos.', error: true);
      return;
    }

    setState(() => _isSavingProfile = true);

    final state = context.read<AppState>();
    final res = await ApiService.updateProfile(
      token: state.token,
      nome: nome,
      email: email,
    );

    if (!mounted) return;

    if (res['success'] == true) {
      state.setUser(nome, email);
      _snack('Perfil atualizado com sucesso!');
    } else {
      _snack(res['message'] ?? 'Erro ao atualizar perfil.', error: true);
    }

    setState(() => _isSavingProfile = false);
  }

  Future<void> _savePassword() async {
    final atual = _senhaAtualController.text.trim();
    final nova = _novaSenhaController.text.trim();
    final confirmar = _confirmarSenhaController.text.trim();

    if (atual.isEmpty || nova.isEmpty || confirmar.isEmpty) {
      _snack('Preencha todos os campos.', error: true);
      return;
    }
    if (nova != confirmar) {
      _snack('As senhas não coincidem.', error: true);
      return;
    }
    if (nova.length < 6) {
      _snack('A nova senha deve ter pelo menos 6 caracteres.', error: true);
      return;
    }

    setState(() => _isSavingPassword = true);

    final state = context.read<AppState>();
    final res = await ApiService.changePassword(
      token: state.token,
      currentPassword: atual,
      newPassword: nova,
    );

    if (!mounted) return;

    if (res['success'] == true) {
      _senhaAtualController.clear();
      _novaSenhaController.clear();
      _confirmarSenhaController.clear();
      _snack('Senha alterada com sucesso!');
    } else {
      _snack(res['message'] ?? 'Erro ao alterar senha.', error: true);
    }

    setState(() => _isSavingPassword = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      body: Column(
        children: [
          // HEADER
          Container(
            padding: EdgeInsets.fromLTRB(
              16,
              MediaQuery.of(context).padding.top + 12,
              16,
              0,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [_greenDark, _green]),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Editar Perfil',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Tabs
                Row(
                  children: [
                    _tab('Dados', 0),
                    const SizedBox(width: 8),
                    _tab('Senha', 1),
                  ],
                ),
              ],
            ),
          ),

          // CONTEÚDO
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _selectedTab == 0 ? _buildDadosTab() : _buildSenhaTab(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tab(String label, int index) {
    final sel = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: sel ? Colors.white : Colors.white.withValues(alpha: 0.15),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: sel ? _green : Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildDadosTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        _label('Nome completo'),
        const SizedBox(height: 8),
        _field(_nomeController, 'Seu nome', Icons.person_outline),
        const SizedBox(height: 16),
        _label('E-mail'),
        const SizedBox(height: 8),
        _field(
          _emailController,
          'seu@email.com',
          Icons.email_outlined,
          type: TextInputType.emailAddress,
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isSavingProfile ? null : _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: _green,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: _isSavingProfile
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Salvar alterações',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSenhaTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        _label('Senha atual'),
        const SizedBox(height: 8),
        _field(
          _senhaAtualController,
          '••••••',
          Icons.lock_outline,
          isPassword: true,
        ),
        const SizedBox(height: 16),
        _label('Nova senha'),
        const SizedBox(height: 8),
        _field(
          _novaSenhaController,
          'Mínimo 6 caracteres',
          Icons.lock_outline,
          isPassword: true,
        ),
        const SizedBox(height: 16),
        _label('Confirmar nova senha'),
        const SizedBox(height: 8),
        _field(
          _confirmarSenhaController,
          'Repita a nova senha',
          Icons.lock_outline,
          isPassword: true,
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isSavingPassword ? null : _savePassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: _green,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: _isSavingPassword
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Alterar senha',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _label(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: Color(0xFF37474F),
    ),
  );

  Widget _field(
    TextEditingController controller,
    String hint,
    IconData icon, {
    TextInputType type = TextInputType.text,
    bool isPassword = false,
  }) {
    return _PasswordField(
      controller: controller,
      hint: hint,
      icon: icon,
      type: type,
      isPassword: isPassword,
    );
  }
}

// Widget auxiliar para campo com toggle de senha
class _PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType type;
  final bool isPassword;

  const _PasswordField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.type,
    required this.isPassword,
  });

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _obscure = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      keyboardType: widget.type,
      obscureText: _obscure,
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        prefixIcon: Icon(widget.icon, color: Colors.grey[400], size: 20),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey[400],
                  size: 20,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
