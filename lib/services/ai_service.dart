import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// ============================================================
// AI SERVICE — DietHub
// ============================================================
// Este arquivo é o ponto central de integração com a IA.
// Atualmente os métodos retornam dados simulados (mock).
//
// PARA IMPLEMENTAR A IA:
// 1. Escolha a IA: Gemini ou OpenAI
// 2. Adicione a chave de API no .env do servidor Node.js
// 3. Substitua os métodos abaixo pelas chamadas reais
// 4. O servidor Node.js já tem as rotas preparadas em server.js
// ============================================================

class AiService {
  static String get _baseUrl {
    if (kIsWeb) return 'http://localhost:3000';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }

  // ============================================================
  // GERAR PLANO ALIMENTAR
  // ============================================================
  // Recebe os dados do usuário e retorna um plano alimentar.
  //
  // IMPLEMENTAÇÃO FUTURA:
  // - Chamar POST /api/generate-plan no servidor Node.js
  // - O servidor irá chamar a API da IA com os dados do usuário
  // - A IA retornará um plano com refeições, macros e calorias
  // ============================================================
  static Future<Map<String, dynamic>> generatePlan({
    required String goal,
    required double weight,
    required double height,
    required int age,
    required String gender,
    required String activityLevel,
    required double waterGoal,
    required List<String> allergies,
    required List<String> preferences,
    required List<String> pathologies,
  }) async {
    try {
      // TODO: Descomentar quando a IA estiver implementada no servidor
      /*
      final response = await http.post(
        Uri.parse('$_baseUrl/api/generate-plan'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'goal': goal,
          'weight': weight,
          'height': height,
          'age': age,
          'gender': gender,
          'activityLevel': activityLevel,
          'waterGoal': waterGoal,
          'allergies': allergies,
          'preferences': preferences,
          'pathologies': pathologies,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      */

      // DADOS SIMULADOS — remover quando a IA estiver implementada
      await Future.delayed(const Duration(seconds: 2));
      return _mockPlan(goal: goal, weight: weight);
    } catch (e) {
      return {'error': 'Erro ao gerar plano: $e'};
    }
  }

  // ============================================================
  // REGISTRAR FUGA DA DIETA
  // ============================================================
  // Recebe o que o usuário comeu fora do plano e retorna
  // sugestões de ajuste para o restante do dia.
  //
  // IMPLEMENTAÇÃO FUTURA:
  // - Chamar POST /api/diet-escape no servidor Node.js
  // - A IA analisará o item consumido e sugerirá compensações
  // ============================================================
  static Future<Map<String, dynamic>> analyzeDietEscape({
    required String foodDescription,
    required double caloriesConsumed,
    required double caloriesGoal,
  }) async {
    try {
      // TODO: Descomentar quando a IA estiver implementada no servidor
      /*
      final response = await http.post(
        Uri.parse('$_baseUrl/api/diet-escape'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'foodDescription': foodDescription,
          'caloriesConsumed': caloriesConsumed,
          'caloriesGoal': caloriesGoal,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      */

      // DADOS SIMULADOS — remover quando a IA estiver implementada
      await Future.delayed(const Duration(seconds: 2));
      return _mockDietEscape(foodDescription);
    } catch (e) {
      return {'error': 'Erro ao analisar fuga: $e'};
    }
  }

  // ============================================================
  // SUGESTÃO DE TROCAS DE ALIMENTOS
  // ============================================================
  // Recebe um alimento e retorna alternativas nutricionalmente
  // equivalentes sugeridas pela IA.
  //
  // IMPLEMENTAÇÃO FUTURA:
  // - Chamar POST /api/food-swap no servidor Node.js
  // - A IA sugerirá trocas baseadas no perfil do usuário
  // ============================================================
  static Future<List<Map<String, dynamic>>> suggestFoodSwap({
    required String foodName,
    required String goal,
    required List<String> allergies,
    required List<String> preferences,
  }) async {
    try {
      // TODO: Descomentar quando a IA estiver implementada no servidor
      /*
      final response = await http.post(
        Uri.parse('$_baseUrl/api/food-swap'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'foodName': foodName,
          'goal': goal,
          'allergies': allergies,
          'preferences': preferences,
        }),
      );
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
      */

      // DADOS SIMULADOS — remover quando a IA estiver implementada
      await Future.delayed(const Duration(seconds: 1));
      return _mockFoodSwap(foodName);
    } catch (e) {
      return [];
    }
  }

  // ============================================================
  // DADOS SIMULADOS (MOCK)
  // ============================================================
  // Estes métodos serão removidos quando a IA for implementada.
  // Eles existem apenas para o app funcionar durante o desenvolvimento.
  // ============================================================

  static Map<String, dynamic> _mockPlan({
    required String goal,
    required double weight,
  }) {
    return {
      'success': true,
      'plan': {
        'summary': 'Plano personalizado gerado para seu objetivo de $goal',
        'meals': [
          {
            'name': 'Café da manhã',
            'time': '07:00',
            'foods': [
              '3 ovos mexidos',
              '2 fatias de pão integral',
              'Café sem açúcar',
            ],
            'calories': 420,
          },
          {
            'name': 'Lanche da manhã',
            'time': '10:00',
            'foods': ['1 banana', '30g de aveia'],
            'calories': 230,
          },
          {
            'name': 'Almoço',
            'time': '12:30',
            'foods': [
              '150g frango grelhado',
              '100g arroz integral',
              'Salada à vontade',
            ],
            'calories': 520,
          },
          {
            'name': 'Lanche da tarde',
            'time': '15:30',
            'foods': ['170g iogurte grego', '1 maçã'],
            'calories': 180,
          },
          {
            'name': 'Jantar',
            'time': '19:00',
            'foods': ['100g salmão', '100g batata doce', 'Brócolis no vapor'],
            'calories': 380,
          },
        ],
      },
    };
  }

  static Map<String, dynamic> _mockDietEscape(String food) {
    return {
      'success': true,
      'analysis': {
        'message':
            'Identificamos a fuga com "$food". Sem problemas, vamos ajustar!',
        'adjustments': [
          {'type': 'reduce', 'food': 'Arroz do jantar', 'amount': '-80g'},
          {'type': 'reduce', 'food': 'Pão do lanche', 'amount': '-1 fatia'},
          {'type': 'add', 'food': 'Caminhada leve', 'amount': '+20 minutos'},
        ],
        'motivation':
            'Uma refeição não define sua jornada. O que importa é a consistência ao longo do tempo!',
      },
    };
  }

  static List<Map<String, dynamic>> _mockFoodSwap(String food) {
    return [
      {
        'original': food,
        'suggestion': 'Batata doce',
        'reason': 'Menor índice glicêmico e mais fibras',
        'ratio': '100g → 120g',
        'calories': 86,
      },
      {
        'original': food,
        'suggestion': 'Quinoa',
        'reason': 'Proteína completa e sem glúten',
        'ratio': '100g → 80g',
        'calories': 120,
      },
      {
        'original': food,
        'suggestion': 'Mandioca cozida',
        'reason': 'Opção regional com bom valor nutricional',
        'ratio': '100g → 130g',
        'calories': 125,
      },
    ];
  }
}
