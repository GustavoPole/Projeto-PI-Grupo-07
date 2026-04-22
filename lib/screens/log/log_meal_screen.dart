import 'package:flutter/material.dart';

class LogMealScreen extends StatefulWidget {
  const LogMealScreen({super.key});

  @override
  State<LogMealScreen> createState() => _LogMealScreenState();
}

class _LogMealScreenState extends State<LogMealScreen> {
  String _selectedMeal = 'Café da manhã';
  bool _isLoading = false;

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

  void _addFood(Map<String, dynamic> food) {
    setState(() => _added.add({...food, 'meal': _selectedMeal}));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${food['name']} adicionado!'),
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
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    // Retorna a lista de alimentos para a home_screen processar
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
                          color: Colors.white.withOpacity(0.15),
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
                          color: Colors.white.withOpacity(0.2),
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
                const SizedBox(height: 16),
                SizedBox(
                  height: 38,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _mealTypes.length,
                    itemBuilder: (_, i) {
                      final sel = _selectedMeal == _mealTypes[i];
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
                                : Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _mealTypes[i],
                            style: TextStyle(
                              color: sel
                                  ? const Color(0xFF1B5E20)
                                  : Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
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
                  // Adicionados
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
                    ..._added.asMap().entries.map((e) {
                      final food = e.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFF2E7D32).withOpacity(0.3),
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
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 11,
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
                              onPressed: () => _removeFood(e.key),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                  ],

                  // Sugestões
                  const Text(
                    'Alimentos',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Color(0xFF1B2B1C),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Toque para adicionar',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  ..._suggestions.map((food) {
                    final isAdded = _added.any(
                      (f) => f['name'] == food['name'],
                    );
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        onTap: isAdded ? null : () => _addFood(food),
                        tileColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        leading: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: isAdded
                                ? const Color(0xFF2E7D32).withOpacity(0.1)
                                : const Color(0xFFF5F7F5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            isAdded ? Icons.check : Icons.add,
                            color: isAdded
                                ? const Color(0xFF2E7D32)
                                : Colors.grey[400],
                            size: 20,
                          ),
                        ),
                        title: Text(
                          food['name'],
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: isAdded
                                ? Colors.grey[400]
                                : const Color(0xFF1B2B1C),
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
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isLoading
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
                            : 'Salvar ${_added.length} alimento${_added.length > 1 ? 's' : ''} (+$_totalCal kcal)',
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
}
