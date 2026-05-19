import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_pi/providers/app_state.dart';

void main() {
  group('AppState Tests', () {
    late AppState appState;

    setUp(() {
      appState = AppState();
    });

    test('CT10 - Atualização do AppState: setPlan deve calcular metas nutricionais corretamente', () {
      appState.setPlan(
        goal: 'Manutenção',
        weight: 70,
        height: 170,
        age: 25,
        gender: 'Masculino',
        activityLevel: 'Sedentário',
        waterGoal: 2.5,
      );

      // Valores esperados aproximados para TMB (Harris-Benedict) e macros
      // TMB para Masculino, 70kg, 170cm, 25 anos: 88.36 + (13.4 * 70) + (4.8 * 170) - (5.7 * 25) = 1699.86
      // TDEE (Sedentário, fator 1.2): 1699.86 * 1.2 = 2039.832
      // Objetivo Manutenção: sem ajuste, então CaloriesGoal = 2040 (arredondado)
      // Macros para Manutenção: Proteína (1.8g/kg) = 126g, Gordura (30% cal) = 68g, Carboidratos (restante) = 231g

      expect(appState.hasPlan, isTrue);
      expect(appState.caloriesGoal, closeTo(2040, 1)); // Permitir pequena variação devido a arredondamento
      expect(appState.proteinGoal, closeTo(126, 1));
      expect(appState.fatGoal, closeTo(68, 1));
      expect(appState.carbsGoal, closeTo(231, 1));
    });

    test('CT09 - Registro de refeições: addMeals deve atualizar o consumo diário', () {
      appState.setPlan(
        goal: 'Manutenção',
        weight: 70,
        height: 170,
        age: 25,
        gender: 'Masculino',
        activityLevel: 'Sedentário',
        waterGoal: 2.5,
      );

      final food1 = {'name': 'Arroz', 'cal': 130, 'p': 3, 'c': 28, 'g': 0};
      final food2 = {'name': 'Frango', 'cal': 165, 'p': 31, 'c': 0, 'g': 4};

      appState.addMeals([food1]);
      expect(appState.caloriesConsumed, 130);
      expect(appState.protein, 3);
      expect(appState.carbs, 28);
      expect(appState.fat, 0);

      appState.addMeals([food2]);
      expect(appState.caloriesConsumed, 130 + 165);
      expect(appState.protein, 3 + 31);
      expect(appState.carbs, 28 + 0);
      expect(appState.fat, 0 + 4);
    });

    test('removeMeal deve remover refeição e atualizar o consumo diário', () {
      appState.setPlan(
        goal: 'Manutenção',
        weight: 70,
        height: 170,
        age: 25,
        gender: 'Masculino',
        activityLevel: 'Sedentário',
        waterGoal: 2.5,
      );

      final food1 = {'name': 'Arroz', 'cal': 130, 'p': 3, 'c': 28, 'g': 0};
      final food2 = {'name': 'Frango', 'cal': 165, 'p': 31, 'c': 0, 'g': 4};

      appState.addMeals([food1, food2]);
      expect(appState.meals.length, 2);
      expect(appState.caloriesConsumed, 130 + 165);

      appState.removeMeal(0); // Remove Arroz
      expect(appState.meals.length, 1);
      expect(appState.caloriesConsumed, 165);
      expect(appState.protein, 31);
      expect(appState.carbs, 0);
      expect(appState.fat, 4);
    });

    test('setWater deve atualizar a ingestão de água', () {
      appState.setWater(1.5);
      expect(appState.waterIntake, 1.5);

      appState.setWater(3.0);
      expect(appState.waterIntake, 3.0);
    });

    test('clearUser deve resetar todos os dados do usuário e plano', () {
      appState.setUser('Teste', 'teste@email.com');
      appState.setToken('some_token');
      appState.setPlan(
        goal: 'Emagrecimento',
        weight: 80,
        height: 180,
        age: 30,
        gender: 'Feminino',
        activityLevel: 'Muito Ativo',
        waterGoal: 3.0,
      );
      appState.addMeals([{'name': 'Salada', 'cal': 50, 'p': 5, 'c': 10, 'g': 1}]);

      expect(appState.userName, 'Teste');
      expect(appState.hasPlan, isTrue);
      expect(appState.meals.isNotEmpty, isTrue);

      appState.clearUser();

      expect(appState.userName, '');
      expect(appState.userEmail, '');
      expect(appState.token, '');
      expect(appState.hasPlan, isFalse);
      expect(appState.allergies, isEmpty);
      expect(appState.preferences, isEmpty);
      expect(appState.meals, isEmpty);
      expect(appState.caloriesConsumed, 0);
      expect(appState.protein, 0);
      expect(appState.carbs, 0);
      expect(appState.fat, 0);
      expect(appState.waterIntake, 0);
    });
  });
}
