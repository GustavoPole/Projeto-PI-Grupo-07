import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const DietHubApp());
}

// ==========================================
// --- SERVIÇO DE API ---
// ==========================================

// ⚠️  Troque pelo IP da sua máquina se rodar no celular físico.
//     No emulador Android, 10.0.2.2 aponta para o localhost do PC.
//     No iOS Simulator, use localhost diretamente.
const String _baseUrl = 'http://localhost:3000';

// Token JWT guardado em memória durante a sessão
String? authToken;

class ApiService {
  // --- LOGIN ---
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // --- REGISTRO ---
  static Future<Map<String, dynamic>> register(
      String nome, String cpf, String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
          {'nome': nome, 'cpf': cpf, 'email': email, 'password': password}),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // --- PERFIL (rota protegida — exemplo) ---
  static Future<Map<String, dynamic>> getProfile() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}

// ==========================================
// --- GERENCIADOR DE TEMA GLOBAL ---
// ==========================================
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

class DietHubApp extends StatelessWidget {
  const DietHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, mode, __) {
        return MaterialApp(
          title: 'DietHub IA',
          debugShowCheckedModeBanner: false,
          themeMode: mode,

          // --- TEMA DARK NEON ---
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: const Color(0xFF39FF14),
            scaffoldBackgroundColor: const Color(0xFF000000),
            textTheme: GoogleFonts.lexendTextTheme(ThemeData.dark().textTheme),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFF111111),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none),
              labelStyle: const TextStyle(color: Colors.grey),
              prefixIconColor: const Color(0xFF39FF14),
            ),
            cardTheme: CardThemeData(
              color: const Color(0xFF0D0D0D),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Color(0xFF1A1A1A), width: 1),
              ),
            ),
          ),

          // --- TEMA LIGHT CREME ---
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: const Color(0xFF2E7D32),
            scaffoldBackgroundColor: const Color(0xFFFDFCF0),
            textTheme: GoogleFonts.lexendTextTheme(ThemeData.light().textTheme),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              prefixIconColor: const Color(0xFF2E7D32),
            ),
            cardTheme: CardThemeData(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
          ),

          initialRoute: '/login',
          routes: {
            '/login': (context) => const LoginPage(),
            '/home': (context) => const MainNavigation(),
          },
        );
      },
    );
  }
}

// ==========================================
// --- 0. TELA DE LOGIN ---
// ==========================================
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obfuscatePassword = true;
  bool _isLoading = false;

  // Chama a API real de login
  Future<void> _doLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnack('Preencha e-mail e senha.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final data = await ApiService.login(email, password);

      if (!mounted) return;

      if (data['token'] != null) {
        authToken = data['token']; // salva o JWT
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        _showSnack(data['message'] ?? 'Credenciais inválidas.');
      }
    } catch (e) {
      _showSnack('Erro de conexão. Verifique se o servidor está rodando.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _showRegisterDialog() {
    showDialog(
      context: context,
      builder: (ctx) => const RegisterDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            const SizedBox(height: 80),

            // --- LOGO ---
            Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.shield_outlined,
                    size: 100, color: Theme.of(context).primaryColor),
                Icon(Icons.eco_rounded,
                    size: 50,
                    color: Theme.of(context).primaryColor
                      ..withValues(alpha: 0.5)),
                Positioned(
                    bottom: 10,
                    child: Icon(Icons.bolt_rounded,
                        size: 25, color: isDark ? Colors.white : Colors.amber)),
              ],
            ),

            const SizedBox(height: 15),

            Text(
              "DIETHUB",
              style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                  letterSpacing: 4),
            ),
            const Text("Sua Nutrição Personalizada com IA",
                style: TextStyle(color: Colors.grey, fontSize: 12)),

            const SizedBox(height: 60),

            // --- CAMPO EMAIL ---
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Email",
                hintText: "seu@email.com",
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),

            const SizedBox(height: 20),

            // --- CAMPO SENHA ---
            TextField(
              controller: _passwordController,
              obscureText: _obfuscatePassword,
              decoration: InputDecoration(
                labelText: "Senha",
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                      _obfuscatePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey),
                  onPressed: () =>
                      setState(() => _obfuscatePassword = !_obfuscatePassword),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: Text("Esqueceu a senha?",
                    style: TextStyle(
                        color: isDark ? Colors.grey : Colors.green[900],
                        fontSize: 12)),
              ),
            ),

            const SizedBox(height: 40),

            // --- BOTÃO ENTRAR ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _doLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  elevation: 5,
                  shadowColor: Theme.of(context).primaryColor
                    ..withValues(alpha: 0.5),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            color: Colors.black, strokeWidth: 2))
                    : const Text(
                        "ENTRAR",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 2),
                      ),
              ),
            ),

            const SizedBox(height: 25),

            // --- BOTÃO CADASTRAR ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Ainda não tem conta?",
                    style: TextStyle(color: Colors.grey)),
                TextButton(
                  onPressed: _showRegisterDialog,
                  child: Text(
                    "CADASTRAR",
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// --- DIALOG DE REGISTRO ---
// ==========================================
class RegisterDialog extends StatefulWidget {
  const RegisterDialog({super.key});

  @override
  State<RegisterDialog> createState() => _RegisterDialogState();
}

class _RegisterDialogState extends State<RegisterDialog> {
  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _doRegister() async {
    final nome = _nomeController.text.trim();
    final cpf = _cpfController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (nome.isEmpty || cpf.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preencha todos os campos.')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final data = await ApiService.register(nome, cpf, email, password);

      if (!mounted) return;

      Navigator.pop(context); // fecha o dialog
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Cadastro realizado!')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro de conexão com o servidor.')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).cardTheme.color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text("Novo Cadastro"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: _nomeController,
                decoration: const InputDecoration(
                    labelText: 'Nome completo',
                    prefixIcon: Icon(Icons.person_outline))),
            const SizedBox(height: 12),
            TextField(
                controller: _cpfController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'CPF', prefixIcon: Icon(Icons.badge_outlined))),
            const SizedBox(height: 12),
            TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined))),
            const SizedBox(height: 12),
            TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: 'Senha', prefixIcon: Icon(Icons.lock_outline))),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCELAR")),
        ElevatedButton(
          onPressed: _isLoading ? null : _doRegister,
          style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor),
          child: _isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      color: Colors.black, strokeWidth: 2))
              : const Text("CADASTRAR",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

// ==========================================
// --- NAVEGAÇÃO PRINCIPAL (BOTTOM BAR) ---
// ==========================================
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const PlanPage(),
    const FugaPage(),
    const SwapPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
              top: BorderSide(
                  color: isDark ? const Color(0xFF1A1A1A) : Colors.black12)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_rounded), label: 'Plano'),
            BottomNavigationBarItem(
                icon: Icon(Icons.restaurant_menu), label: 'Fuga'),
            BottomNavigationBarItem(
                icon: Icon(Icons.swap_horizontal_circle), label: 'Trocas'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded), label: 'Perfil'),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// --- 1. TELA DE PLANO ALIMENTAR (HOME) ---
// ==========================================
class PlanPage extends StatelessWidget {
  const PlanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("DIETHUB"),
        actions: [
          IconButton(
              icon: const Icon(Icons.notifications_none), onPressed: () {})
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Olá!",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const Text("Sua meta de hoje está 65% concluída.",
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 25),
            _buildMacroSection(context),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Refeições",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                TextButton(onPressed: () {}, child: const Text("Ver todas")),
              ],
            ),
            const SizedBox(height: 10),
            _buildMealItem(context, "Café da Manhã",
                "3 Ovos, 1 fatia de pão, Café", "08:00", true),
            _buildMealItem(context, "Almoço", "150g Frango, 100g Arroz, Salada",
                "12:30", false),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
            color: Theme.of(context).primaryColor..withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
              color: Theme.of(context).primaryColor..withValues(alpha: 0.5),
              blurRadius: 20,
              spreadRadius: 5)
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _macroCircle("Prot", "145g", Colors.blue, 0.8),
              _macroCircle("Carb", "210g", Colors.orange, 0.5),
              _macroCircle("Fat", "60g", Colors.red, 0.3),
            ],
          ),
          const Divider(height: 40, color: Color(0xFF1A1A1A)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Calorias Totais",
                  style: TextStyle(color: Colors.grey)),
              Text("1.850 / 2.200 kcal",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _macroCircle(String label, String value, Color color, double percent) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                  value: percent,
                  strokeWidth: 6,
                  color: color,
                  backgroundColor: color..withValues(alpha: 0.5)),
            ),
            Text(label[0], style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildMealItem(
      BuildContext context, String name, String desc, String time, bool done) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: done ? Theme.of(context).primaryColor : Colors.grey
                ..withValues(alpha: 0.5),
              shape: BoxShape.circle),
          child: Icon(done ? Icons.check : Icons.access_time,
              color: done ? Colors.black : Colors.grey),
        ),
        title: Text(name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Text(desc),
        trailing:
            Text(time, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// ==========================================
// --- 2. TELA DE FUGA ---
// ==========================================
class FugaPage extends StatefulWidget {
  const FugaPage({super.key});

  @override
  State<FugaPage> createState() => _FugaPageState();
}

class _FugaPageState extends State<FugaPage> {
  final TextEditingController _fugaController = TextEditingController();
  bool _isProcessing = false;

  void _simularAjusteIA() async {
    if (_fugaController.text.isEmpty) return;
    setState(() => _isProcessing = true);

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardTheme.color,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome, color: Color(0xFF39FF14), size: 40),
            const SizedBox(height: 15),
            const Text("Ajuste de IA Concluído",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text(
                "Para compensar esse alimento, reduzi 40g de carboidratos do seu jantar e adicionei 15 min de caminhada.",
                textAlign: TextAlign.center),
            const SizedBox(height: 25),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF39FF14),
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text("ENTENDIDO",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
    setState(() {
      _isProcessing = false;
      _fugaController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("REGISTRAR FUGA")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(15.0),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.amber),
                    SizedBox(width: 15),
                    Expanded(
                        child: Text(
                            "Fugiu da dieta? Relaxa. Informe o que comeu e a IA ajustará suas próximas refeições.")),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _fugaController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "O que você comeu?",
                hintText: "Ex: 2 fatias de pizza de calabresa...",
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _simularAjusteIA,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
                child: _isProcessing
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text("ANALISAR COM IA",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// --- 3. TELA DE TROCAS ---
// ==========================================
class SwapPage extends StatefulWidget {
  const SwapPage({super.key});

  @override
  State<SwapPage> createState() => _SwapPageState();
}

class _SwapPageState extends State<SwapPage> {
  final List<Map<String, String>> _swaps = [
    {"original": "Arroz Branco", "sub": "Batata Doce", "ratio": "100g -> 120g"},
    {"original": "Pão de Forma", "sub": "Tapioca", "ratio": "2 fatias -> 40g"},
    {"original": "Ovo", "sub": "Whey Protein", "ratio": "2 unid -> 20g"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("TROCAS INTELIGENTES")),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _swaps.length,
        itemBuilder: (context, index) {
          final item = _swaps[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey..withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['original']!,
                          style: const TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey)),
                      const Icon(Icons.arrow_downward,
                          size: 16, color: Colors.grey),
                      Text(item['sub']!,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor
                        ..withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10)),
                  child: Text(item['ratio']!,
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ),
                IconButton(
                  icon: const Icon(Icons.check_circle_outline),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content:
                            Text("Plano atualizado para ${item['sub']}!")));
                  },
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

// ==========================================
// --- 4. TELA DE PERFIL ---
// ==========================================
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text("PERFIL")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: const Color(0xFF1A1A1A),
                child: Icon(Icons.person,
                    size: 60, color: Theme.of(context).primaryColor),
              ),
            ),
            const SizedBox(height: 30),

            _buildProfileTile(
                Icons.fitness_center, "Meu Objetivo", "Ganho de Massa"),
            _buildProfileTile(Icons.monitor_weight, "Peso Atual", "78.5 kg"),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: Divider(color: Color(0xFF1A1A1A)),
            ),

            // SWITCH DE TEMA
            ValueListenableBuilder<ThemeMode>(
              valueListenable: themeNotifier,
              builder: (_, mode, __) {
                return SwitchListTile(
                  secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode,
                      color: Theme.of(context).primaryColor),
                  title: const Text("Modo Claro"),
                  subtitle: const Text("Alternar entre Neon e Creme"),
                  value: mode == ThemeMode.light,
                  onChanged: (value) {
                    themeNotifier.value =
                        value ? ThemeMode.light : ThemeMode.dark;
                  },
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text("Sair da Conta",
                  style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                authToken = null; // limpa o token ao sair
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTile(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey),
      title: Text(title),
      trailing: Text(value,
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
    );
  }
}
