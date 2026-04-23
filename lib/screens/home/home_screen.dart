import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:projeto_pi/providers/app_state.dart';
import 'package:projeto_pi/screens/auth/login_screen.dart';
import 'package:projeto_pi/screens/plan/create_plan_screen.dart';
import 'package:projeto_pi/screens/log/log_meal_screen.dart';
import 'package:projeto_pi/services/ai_service.dart';
import 'package:projeto_pi/screens/scan/scan_plan_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animCtrl;
  late Animation<double> _fade;

  final _swapController = TextEditingController();
  List<Map<String, dynamic>> _swapResults = [];
  bool _swapLoading = false;
  String _swapError = '';
  bool _swapSearched = false;

  static String get _baseUrl {
    if (kIsWeb) return 'http://localhost:3000';
    if (defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:3000';
    return 'http://localhost:3000';
  }

  bool _planLoading = true;
  Map<String, dynamic>? _dbPlan;

  Future<void> _loadDbPlan() async {
    final token = context.read<AppState>().token;
    if (token.isEmpty) {
      if (mounted) setState(() => _planLoading = false);
      return;
    }
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/api/my-plan'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (mounted) {
          setState(() {
            if (data['success'] == true && data['hasPlan'] == true) {
              _dbPlan = Map<String, dynamic>.from(data['plan']);
            } else {
              _dbPlan = null;
            }
          });
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _planLoading = false);
  }

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fade = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDbPlan());
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _swapController.dispose();
    super.dispose();
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Sair da conta',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text('Tem certeza que deseja sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AppState>().clearUser();
              Navigator.pop(ctx);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Sair', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      body: FadeTransition(
        opacity: _fade,
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildHomePage(),
            _buildFugasPage(),
            _buildTrocasPage(),
            _buildPerfilPage(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ==========================================
  // HOME PAGE
  // ==========================================
  Widget _buildHomePage() {
    final state = context.watch<AppState>();
    final firstName = state.userName.isNotEmpty
        ? state.userName.split(' ')[0]
        : 'você';

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 110,
          floating: false,
          pinned: true,
          backgroundColor: const Color(0xFF1B5E20),
          elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: FlexibleSpaceBar(
            collapseMode: CollapseMode.pin,
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 48, 20, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Olá, $firstName! 👋',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                        const Text(
                          'dietHub',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                    ),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    onPressed: _logout,
                    tooltip: 'Sair',
                  ),
                ],
              ),
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_planLoading)
                  _buildPlanLoadingCard()
                else if (_dbPlan != null)
                  _buildDbPlanSection(_dbPlan!)
                else if (state.hasPlan) ...[
                  _buildCaloriesCard(state),
                  const SizedBox(height: 16),
                  _buildMacrosRow(state),
                  const SizedBox(height: 16),
                  _buildWaterCard(state),
                  const SizedBox(height: 16),
                  _buildMealsSection(state),
                ] else
                  _buildNoPlanCard(),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoPlanCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.restaurant_menu,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Crie seu plano\nalimentar personalizado',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Preencha seus dados e receba um plano\ncompleto adaptado aos seus objetivos.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreatePlanScreen()),
              ),
              icon: const Icon(
                Icons.add_circle_outline,
                color: Color(0xFF1B5E20),
              ),
              label: const Text(
                'Criar Plano Alimentar',
                style: TextStyle(
                  color: Color(0xFF1B5E20),
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanLoadingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        children: [
          CircularProgressIndicator(color: Color(0xFF2E7D32)),
          SizedBox(height: 16),
          Text(
            'Carregando seu plano alimentar...',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // PLANO DO BANCO — refeições colapsáveis
  // ==========================================
  Widget _buildDbPlanSection(Map<String, dynamic> plan) {
    const green = Color(0xFF2E7D32);
    const greenLight = Color(0xFFE8F5E9);
    final refeicoes = (plan['refeicoes'] as List?) ?? [];
    final dataCriacao = plan['data_criacao']?.toString().split('T')[0] ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cabeçalho do plano
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: green.withOpacity(0.25),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.restaurant_menu, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan['nome'] ?? 'Plano Alimentar',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (dataCriacao.isNotEmpty)
                      Text(
                        'Criado em $dataCriacao  •  ${refeicoes.length} refeições',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _planLoading = true;
                    _dbPlan = null;
                  });
                  _loadDbPlan();
                },
                icon: const Icon(Icons.refresh, color: Colors.white70, size: 20),
                tooltip: 'Atualizar',
              ),
            ],
          ),
        ),

        // Refeições colapsáveis
        const Text(
          'Refeições do plano',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        ...refeicoes.asMap().entries.map((entry) {
          final i = entry.key;
          final ref = entry.value as Map;
          return _buildDbMealCard(ref, i, green, greenLight);
        }),
      ],
    );
  }

  Widget _buildDbMealCard(Map ref, int index, Color green, Color greenLight) {
    final alimentos = (ref['alimentos'] as List?) ?? [];
    final totalCal = alimentos.fold<double>(
      0,
      (sum, a) => sum + (double.tryParse(a['calorias']?.toString() ?? '0') ?? 0),
    );

    final mealIcons = [
      Icons.wb_sunny_outlined,
      Icons.free_breakfast_outlined,
      Icons.lunch_dining_outlined,
      Icons.bakery_dining_outlined,
      Icons.dinner_dining_outlined,
      Icons.nightlight_round_outlined,
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: greenLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              mealIcons[index % mealIcons.length],
              color: green,
              size: 22,
            ),
          ),
          title: Text(
            ref['nome']?.toString() ?? 'Refeição',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          subtitle: Row(
            children: [
              if ((ref['horario']?.toString() ?? '').isNotEmpty) ...[
                Icon(Icons.access_time, size: 12, color: Colors.grey[400]),
                const SizedBox(width: 3),
                Text(
                  ref['horario'].toString(),
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                const SizedBox(width: 10),
              ],
              Icon(Icons.local_fire_department, size: 12, color: Colors.orange[300]),
              const SizedBox(width: 3),
              Text(
                '${totalCal.toInt()} kcal  •  ${alimentos.length} item(s)',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
          iconColor: green,
          collapsedIconColor: Colors.grey[400],
          children: alimentos.isEmpty
              ? [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Nenhum alimento cadastrado.',
                      style: TextStyle(color: Colors.grey[400], fontSize: 13),
                    ),
                  ),
                ]
              : alimentos.map<Widget>((al) {
                  final cal = double.tryParse(al['calorias']?.toString() ?? '0') ?? 0;
                  final prot = al['proteinas']?.toString() ?? '0';
                  final carb = al['carbos']?.toString() ?? '0';
                  final gord = al['gorduras']?.toString() ?? '0';
                  final qtd = (al['quantidade_g'] as num?)?.toStringAsFixed(0) ?? '?';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                al['nome']?.toString() ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'P: ${prot}g  •  C: ${carb}g  •  G: ${gord}g',
                                style: TextStyle(color: Colors.grey[500], fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.orange[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${cal.toInt()} kcal',
                                style: TextStyle(
                                  color: Colors.orange[800],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${qtd}g',
                              style: TextStyle(color: Colors.grey[400], fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
        ),
      ),
    );
  }

  Widget _buildCaloriesCard(AppState state) {
    final percent = (state.caloriesConsumed / state.caloriesGoal).clamp(
      0.0,
      1.0,
    );
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Calorias de Hoje',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${state.caloriesConsumed.toInt()} / ${state.caloriesGoal.toInt()} kcal',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _calStat(
                'Consumidas',
                '${state.caloriesConsumed.toInt()}',
                Colors.greenAccent,
              ),
              _calStat(
                'Restantes',
                '${(state.caloriesGoal - state.caloriesConsumed).toInt()}',
                Colors.orangeAccent,
              ),
              _calStat('Meta', '${state.caloriesGoal.toInt()}', Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  Widget _calStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildMacrosRow(AppState state) {
    return Row(
      children: [
        Expanded(
          child: _macroCard(
            'Proteínas',
            state.protein,
            state.proteinGoal,
            const Color(0xFF1565C0),
            Icons.fitness_center,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _macroCard(
            'Carboidratos',
            state.carbs,
            state.carbsGoal,
            const Color(0xFFE65100),
            Icons.grain,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _macroCard(
            'Gorduras',
            state.fat,
            state.fatGoal,
            const Color(0xFF6A1B9A),
            Icons.water_drop,
          ),
        ),
      ],
    );
  }

  Widget _macroCard(
    String label,
    double current,
    double goal,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 8),
          Text(
            '${current.toInt()}g',
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            '/ ${goal.toInt()}g',
            style: TextStyle(color: Colors.grey[400], fontSize: 11),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (current / goal).clamp(0.0, 1.0),
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 5,
            ),
          ),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildWaterCard(AppState state) {
    final percent = (state.waterIntake / state.waterGoal).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1565C0).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.water_drop,
                      color: Color(0xFF1565C0),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Hidratação',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                ],
              ),
              Text(
                '${state.waterIntake.toStringAsFixed(1)}L / ${state.waterGoal.toStringAsFixed(1)}L',
                style: const TextStyle(
                  color: Color(0xFF1565C0),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: const Color(0xFF1565C0).withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF1565C0),
              ),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(8, (i) {
              final cups = state.waterGoal / 8;
              final filled = state.waterIntake >= (i + 1) * cups;
              return GestureDetector(
                onTap: () {
                  context.read<AppState>().setWater(
                    ((i + 1) * cups).clamp(0.0, state.waterGoal),
                  );
                },
                child: Icon(
                  Icons.water_drop,
                  color: filled
                      ? const Color(0xFF1565C0)
                      : const Color(0xFF1565C0).withOpacity(0.15),
                  size: 26,
                ),
              );
            }),
          ),
          const SizedBox(height: 6),
          Text(
            'Toque nas gotas para registrar',
            style: TextStyle(color: Colors.grey[400], fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildMealsSection(AppState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Refeições de Hoje',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1B2B1C),
              ),
            ),
            TextButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LogMealScreen()),
                );
                if (result != null && result is List<Map<String, dynamic>>) {
                  context.read<AppState>().addMeals(result);
                }
              },
              icon: const Icon(Icons.add, size: 16, color: Color(0xFF2E7D32)),
              label: const Text(
                'Registrar',
                style: TextStyle(
                  color: Color(0xFF2E7D32),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (state.meals.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.restaurant, color: Colors.grey[300], size: 40),
                  const SizedBox(height: 8),
                  Text(
                    'Nenhuma refeição registrada hoje',
                    style: TextStyle(color: Colors.grey[400], fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ...state.meals.asMap().entries.map((entry) {
          final i = entry.key;
          final meal = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Color(0xFF2E7D32),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            meal['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: Color(0xFF1B2B1C),
                            ),
                          ),
                          Text(
                            meal['meal'] ?? '',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${meal['unit']}',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${meal['cal']} kcal',
                        style: const TextStyle(
                          color: Color(0xFF2E7D32),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 18,
                  ),
                  onPressed: () => context.read<AppState>().removeMeal(i),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ==========================================
  // FUGAS (placeholder)
  // ==========================================
  Widget _buildFugasPage() => _placeholder('Fuga da Dieta', Icons.fastfood);

  Future<void> _searchSwap() async {
    final food = _swapController.text.trim();
    if (food.isEmpty) return;
    final state = context.read<AppState>();
    setState(() {
      _swapLoading = true;
      _swapError = '';
      _swapResults = [];
      _swapSearched = true;
    });
    final results = await AiService.suggestFoodSwap(
      foodName: food,
      goal: state.goal,
      allergies: state.allergies.toList(),
      preferences: state.preferences.toList(),
      token: state.token,
    );
    if (!mounted) return;
    setState(() {
      _swapLoading = false;
      _swapResults = results;
      if (results.isEmpty) _swapError = 'Nenhuma sugestão encontrada. Tente outro alimento.';
    });
  }

  Widget _buildTrocasPage() {
    const green = Color(0xFF2E7D32);
    const greenLight = Color(0xFFE8F5E9);

    return SafeArea(
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.swap_horiz, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Trocar Alimento',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Substitutos inteligentes com IA',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Campo de busca
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _swapController,
                          textCapitalization: TextCapitalization.sentences,
                          onSubmitted: (_) => _searchSwap(),
                          decoration: const InputDecoration(
                            hintText: 'Ex: Arroz branco, Frango, Leite...',
                            hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                            prefixIcon: Icon(Icons.search, color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _swapLoading ? null : _searchSwap,
                        child: Container(
                          margin: const EdgeInsets.all(6),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          decoration: BoxDecoration(
                            color: green,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: _swapLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Buscar',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Conteúdo
          Expanded(
            child: _swapLoading
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(color: green),
                        const SizedBox(height: 16),
                        Text(
                          'Consultando a IA...',
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : !_swapSearched
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: greenLight,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.swap_horiz, size: 48, color: green),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Substitua qualquer alimento',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Digite um alimento acima e a IA sugerirá 3 alternativas nutricionalmente equivalentes, respeitando suas alergias e preferências.',
                                style: TextStyle(color: Colors.grey[500], fontSize: 14, height: 1.5),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : _swapError.isNotEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.error_outline, size: 48, color: Colors.orange),
                                  const SizedBox(height: 16),
                                  Text(
                                    _swapError,
                                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: _searchSwap,
                                    style: ElevatedButton.styleFrom(backgroundColor: green),
                                    child: const Text('Tentar novamente', style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView(
                            padding: const EdgeInsets.all(20),
                            children: [
                              // Alimento pesquisado
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: greenLight,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: green.withOpacity(0.3)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.info_outline, color: green, size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: RichText(
                                        text: TextSpan(
                                          style: const TextStyle(color: Colors.black87, fontSize: 13),
                                          children: [
                                            const TextSpan(text: 'Substitutos para: '),
                                            TextSpan(
                                              text: _swapController.text.trim(),
                                              style: const TextStyle(fontWeight: FontWeight.w700, color: green),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Cards de sugestão
                              ..._swapResults.asMap().entries.map((entry) {
                                final i = entry.key;
                                final swap = entry.value;
                                final icons = [Icons.eco, Icons.grain, Icons.local_dining];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.06),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: greenLight,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Icon(icons[i % icons.length], color: green, size: 24),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                swap['suggestion'] ?? '',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                swap['reason'] ?? '',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 13,
                                                  height: 1.4,
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              Row(
                                                children: [
                                                  if (swap['ratio'] != null)
                                                    _swapChip(
                                                      Icons.swap_horiz,
                                                      swap['ratio'],
                                                      Colors.blue[50]!,
                                                      Colors.blue[700]!,
                                                    ),
                                                  const SizedBox(width: 8),
                                                  if (swap['calories'] != null)
                                                    _swapChip(
                                                      Icons.local_fire_department,
                                                      '${swap['calories']} kcal',
                                                      Colors.orange[50]!,
                                                      Colors.orange[700]!,
                                                    ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                              const SizedBox(height: 8),
                              // Botão nova busca
                              OutlinedButton.icon(
                                onPressed: () {
                                  _swapController.clear();
                                  setState(() {
                                    _swapSearched = false;
                                    _swapResults = [];
                                    _swapError = '';
                                  });
                                },
                                icon: const Icon(Icons.search, size: 18),
                                label: const Text('Nova busca'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: green,
                                  side: const BorderSide(color: green),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ],
                          ),
          ),
        ],
      ),
    );
  }

  Widget _swapChip(IconData icon, String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: fg, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ==========================================
  // PERFIL
  // ==========================================
  Widget _buildPerfilPage() {
    final state = context.watch<AppState>();
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xFF2E7D32).withOpacity(0.1),
              child: const Icon(
                Icons.person,
                size: 50,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              state.userName.isNotEmpty ? state.userName : 'Usuário',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            Text(
              state.userEmail.isNotEmpty
                  ? state.userEmail
                  : 'email@exemplo.com',
              style: TextStyle(color: Colors.grey[500]),
            ),
            const SizedBox(height: 30),

            if (!state.hasPlan)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withOpacity(0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF2E7D32).withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Color(0xFF2E7D32),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Crie seu plano alimentar para ver seus dados aqui.',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

            if (state.hasPlan) ...[
              _profileTile(Icons.flag_outlined, 'Objetivo', state.goal),
              _profileTile(
                Icons.monitor_weight_outlined,
                'Peso',
                '${state.weight.toStringAsFixed(1)} kg',
              ),
              _profileTile(
                Icons.height,
                'Altura',
                '${state.height.toStringAsFixed(0)} cm',
              ),
              _profileTile(Icons.cake_outlined, 'Idade', '${state.age} anos'),
              _profileTile(
                Icons.directions_run,
                'Atividade',
                state.activityLevel,
              ),
              _profileTile(
                Icons.local_fire_department_outlined,
                'Meta Calórica',
                '${state.caloriesGoal.toInt()} kcal/dia',
              ),
              _profileTile(
                Icons.water_drop_outlined,
                'Meta de Água',
                '${state.waterGoal.toStringAsFixed(1)} L/dia',
              ),
            ],

            const SizedBox(height: 20),

            // Botão Scan do plano alimentar
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ScanPlanScreen()),
                  ).then((_) {
                    setState(() {
                      _planLoading = true;
                      _dbPlan = null;
                    });
                    _loadDbPlan();
                  });
                },
                icon: const Icon(Icons.document_scanner_rounded, color: Colors.white),
                label: const Text(
                  'Scan do plano alimentar',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  'Sair da conta',
                  style: TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileTile(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2E7D32), size: 22),
          const SizedBox(width: 14),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder(String title, IconData icon) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: const Color(0xFF2E7D32)),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Em breve...',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: const Color(0xFF2E7D32),
        unselectedItemColor: Colors.grey[400],
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fastfood_rounded),
            label: 'Fugas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz_rounded),
            label: 'Trocas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
