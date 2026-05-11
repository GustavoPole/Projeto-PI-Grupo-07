import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projeto_pi/providers/app_state.dart';
import 'package:projeto_pi/services/api_service.dart';

class LogMealScreen extends StatefulWidget {
  const LogMealScreen({super.key});

  @override
  State<LogMealScreen> createState() => _LogMealScreenState();
}

class _LogMealScreenState extends State<LogMealScreen> {
  String _selectedMeal = 'Café da manhã';
  bool _isSaving = false;

  final List<String> _mealTypes = [
    'Café da manhã',
    'Lanche da manhã',
    'Almoço',
    'Lanche da tarde',
    'Jantar',
    'Ceia',
  ];

  final List<Map<String, dynamic>> _added = [];

  final List<Map<String, dynamic>> _suggestions = [
    {
      'name': 'Frango grelhado',
      'unit': '100g',
      'cal': 165,
      'p': 31,
      'c': 0,
      'g': 4,
    },
    {
      'name': 'Arroz integral',
      'unit': '100g',
      'cal': 111,
      'p': 3,
      'c': 23,
      'g': 1,
    },
    {
      'name': 'Ovo cozido',
      'unit': '1 unidade',
      'cal': 78,
      'p': 6,
      'c': 1,
      'g': 5,
    },
    {'name': 'Banana', 'unit': '1 média', 'cal': 89, 'p': 1, 'c': 23, 'g': 0},
    {
      'name': 'Iogurte grego',
      'unit': '170g',
      'cal': 100,
      'p': 17,
      'c': 6,
      'g': 0,
    },
    {'name': 'Aveia', 'unit': '40g', 'cal': 148, 'p': 5, 'c': 27, 'g': 3},
    {'name': 'Batata doce', 'unit': '100g', 'cal': 86, 'p': 2, 'c': 20, 'g': 0},
    {'name': 'Salmão', 'unit': '100g', 'cal': 208, 'p': 20, 'c': 0, 'g': 13},
    {
      'name': 'Whey Protein',
      'unit': '30g',
      'cal': 120,
      'p': 24,
      'c': 3,
      'g': 2,
    },
    {
      'name': 'Pão integral',
      'unit': '1 fatia',
      'cal': 69,
      'p': 3,
      'c': 12,
      'g': 1,
    },
    {'name': 'Maçã', 'unit': '1 média', 'cal': 72, 'p': 0, 'c': 19, 'g': 0},
    {
      'name': 'Feijão cozido',
      'unit': '100g',
      'cal': 77,
      'p': 5,
      'c': 14,
      'g': 0,
    },
  ];

  int get _totalCal => _added.fold(0, (s, f) => s + (f['cal'] as int));

  // Permite o mesmo alimento em períodos diferentes
  bool _isAddedInCurrentMeal(String foodName) {
    return _added.any(
      (f) => f['name'] == foodName && f['meal'] == _selectedMeal,
    );
  }

  void _addFood(Map<String, dynamic> food) {
    setState(() => _added.add({...food, 'meal': _selectedMeal}));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${food['name']} adicionado em $_selectedMeal!'),
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _removeFood(int i) => setState(() => _added.removeAt(i));

  Future<void> _save() async {
    if (_added.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Adicione pelo menos um alimento!'),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final state = context.read<AppState>();

    // Se tiver token, salva no banco também
    if (state.token.isNotEmpty) {
      for (final food in _added) {
        try {
          // Busca alimentos existentes no banco
          final alimentos = await ApiService.getAlimentos(state.token);
          final existing = alimentos.where(
            (a) =>
                a['Nome'].toString().toLowerCase() ==
                food['name'].toString().toLowerCase(),
          );

          int? alimentoId;
          if (existing.isNotEmpty) {
            alimentoId = existing.first['id'] as int;
          }

          if (alimentoId != null) {
            await ApiService.salvarRefeicao(
              token: state.token,
              alimentoId: alimentoId,
              quantidadeG: 100,
              tipo: 'consumido',
              refeicaoReferencia: food['meal'],
            );
          }
        } catch (_) {
          // Falha silenciosa — o item ainda será adicionado localmente
        }
      }
    }

    if (!mounted) return;
    Navigator.pop(context, List<Map<String, dynamic>>.from(_added));
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
              20,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
              ),
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
                    const Expanded(
                      child: Text(
                        'Registrar Refeição',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (_added.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$_totalCal kcal',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.white70, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Selecione o período. O mesmo alimento pode ser adicionado em períodos diferentes!',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 38,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _mealTypes.length,
                    itemBuilder: (_, i) {
                      final sel = _selectedMeal == _mealTypes[i];
                      final count = _added
                          .where((f) => f['meal'] == _mealTypes[i])
                          .length;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedMeal = _mealTypes[i]),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: sel
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Text(
                                _mealTypes[i],
                                style: TextStyle(
                                  color: sel
                                      ? const Color(0xFF1B5E20)
                                      : Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                              if (count > 0) ...[
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: sel
                                        ? const Color(0xFF2E7D32)
                                        : Colors.white.withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '$count',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Adicionados agrupados por período
                  if (_added.isNotEmpty) ...[
                    const Text(
                      'Adicionados',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Color(0xFF1B2B1C),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ..._buildGroupedAdded(),
                    const SizedBox(height: 16),
                  ],

                  // Sugestões
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Alimentos',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Color(0xFF1B2B1C),
                        ),
                      ),
                      Text(
                        'Período: $_selectedMeal',
                        style: const TextStyle(
                          color: Color(0xFF2E7D32),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Toque para adicionar no período selecionado',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                  const SizedBox(height: 10),

                  ..._suggestions.map((food) {
                    final addedInMeal = _isAddedInCurrentMeal(food['name']);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        onTap: () => _addFood(food),
                        tileColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        leading: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: addedInMeal
                                ? const Color(0xFF2E7D32).withValues(alpha: 0.1)
                                : const Color(0xFFF5F7F5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            addedInMeal ? Icons.check : Icons.add,
                            color: addedInMeal
                                ? const Color(0xFF2E7D32)
                                : Colors.grey[400],
                            size: 20,
                          ),
                        ),
                        title: Text(
                          food['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Color(0xFF1B2B1C),
                          ),
                        ),
                        subtitle: Text(
                          '${food['unit']} • ${food['cal']} kcal',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'P: ${food['p']}g',
                              style: const TextStyle(
                                color: Color(0xFF1565C0),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'C: ${food['c']}g',
                              style: const TextStyle(
                                color: Color(0xFFE65100),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'G: ${food['g']}g',
                              style: const TextStyle(
                                color: Color(0xFF6A1B9A),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),

          // BOTÃO SALVAR
          Container(
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              MediaQuery.of(context).padding.bottom + 12,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        _added.isEmpty
                            ? 'Adicione alimentos acima'
                            : 'Salvar ${_added.length} item${_added.length > 1 ? 's' : ''} (+$_totalCal kcal)',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildGroupedAdded() {
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final item in _added) {
      final meal = item['meal'] as String;
      grouped.putIfAbsent(meal, () => []).add(item);
    }

    final widgets = <Widget>[];
    for (final meal in _mealTypes) {
      if (!grouped.containsKey(meal)) continue;
      final items = grouped[meal]!;

      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            meal,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E7D32),
            ),
          ),
        ),
      );

      for (final food in items) {
        final globalIndex = _added.indexOf(food);
        widgets.add(
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF2E7D32).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF2E7D32),
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        food['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '${food['unit']} • ${food['cal']} kcal • P:${food['p']}g C:${food['c']}g G:${food['g']}g',
                        style: TextStyle(color: Colors.grey[500], fontSize: 11),
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
                  onPressed: () => _removeFood(globalIndex),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        );
      }
      widgets.add(const SizedBox(height: 8));
    }
    return widgets;
  }
}
