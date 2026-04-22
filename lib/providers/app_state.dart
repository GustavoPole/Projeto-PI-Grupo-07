import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  // --- DADOS DO USUÁRIO ---
  String _userName = '';
  String _userEmail = '';

  String get userName => _userName;
  String get userEmail => _userEmail;

  void setUser(String name, String email) {
    _userName = name;
    _userEmail = email;
    notifyListeners();
  }

  void clearUser() {
    _userName = '';
    _userEmail = '';
    _hasPlan = false;
    _meals = [];
    _caloriesConsumed = 0;
    _protein = 0;
    _carbs = 0;
    _fat = 0;
    _waterIntake = 0;
    notifyListeners();
  }

  // --- DADOS DO PLANO ---
  bool _hasPlan = false;
  String _goal = '';
  double _weight = 0;
  double _height = 0;
  int _age = 0;
  String _gender = '';
  String _activityLevel = '';
  double _waterGoal = 2.5;

  // Metas calculadas
  double _caloriesGoal = 0;
  double _proteinGoal = 0;
  double _carbsGoal = 0;
  double _fatGoal = 0;

  bool get hasPlan => _hasPlan;
  String get goal => _goal;
  double get weight => _weight;
  double get height => _height;
  int get age => _age;
  String get gender => _gender;
  String get activityLevel => _activityLevel;
  double get waterGoal => _waterGoal;
  double get caloriesGoal => _caloriesGoal;
  double get proteinGoal => _proteinGoal;
  double get carbsGoal => _carbsGoal;
  double get fatGoal => _fatGoal;

  void setPlan({
    required String goal,
    required double weight,
    required double height,
    required int age,
    required String gender,
    required String activityLevel,
    required double waterGoal,
  }) {
    _goal = goal;
    _weight = weight;
    _height = height;
    _age = age;
    _gender = gender;
    _activityLevel = activityLevel;
    _waterGoal = waterGoal;
    _hasPlan = true;

    // Calcula metas com base nos dados (fórmula de Harris-Benedict)
    _calculateGoals();
    notifyListeners();
  }

  void _calculateGoals() {
    // TMB (Taxa Metabólica Basal) - Harris-Benedict
    double tmb;
    if (_gender == 'Masculino') {
      tmb = 88.36 + (13.4 * _weight) + (4.8 * _height) - (5.7 * _age);
    } else {
      tmb = 447.6 + (9.2 * _weight) + (3.1 * _height) - (4.3 * _age);
    }

    // Fator de atividade
    final Map<String, double> activityFactors = {
      'Sedentário': 1.2,
      'Levemente Ativo': 1.375,
      'Moderadamente Ativo': 1.55,
      'Muito Ativo': 1.725,
      'Atleta': 1.9,
    };
    final factor = activityFactors[_activityLevel] ?? 1.2;
    double tdee = tmb * factor;

    // Ajusta com base no objetivo
    switch (_goal) {
      case 'Emagrecimento':
        tdee *= 0.85; // déficit de 15%
        break;
      case 'Ganho de Massa':
        tdee *= 1.10; // superávit de 10%
        break;
      case 'Melhora da Performance':
        tdee *= 1.05;
        break;
      default:
        break; // Manutenção = sem ajuste
    }

    _caloriesGoal = tdee.roundToDouble();

    // Macros baseados no objetivo
    switch (_goal) {
      case 'Emagrecimento':
        _proteinGoal = (_weight * 2.0).roundToDouble();
        _fatGoal = (_caloriesGoal * 0.25 / 9).roundToDouble();
        _carbsGoal = ((_caloriesGoal - (_proteinGoal * 4) - (_fatGoal * 9)) / 4)
            .roundToDouble();
        break;
      case 'Ganho de Massa':
        _proteinGoal = (_weight * 2.2).roundToDouble();
        _fatGoal = (_caloriesGoal * 0.25 / 9).roundToDouble();
        _carbsGoal = ((_caloriesGoal - (_proteinGoal * 4) - (_fatGoal * 9)) / 4)
            .roundToDouble();
        break;
      default:
        _proteinGoal = (_weight * 1.8).roundToDouble();
        _fatGoal = (_caloriesGoal * 0.30 / 9).roundToDouble();
        _carbsGoal = ((_caloriesGoal - (_proteinGoal * 4) - (_fatGoal * 9)) / 4)
            .roundToDouble();
    }
  }

  // --- CONSUMO DO DIA ---
  double _caloriesConsumed = 0;
  double _protein = 0;
  double _carbs = 0;
  double _fat = 0;
  double _waterIntake = 0;
  List<Map<String, dynamic>> _meals = [];

  double get caloriesConsumed => _caloriesConsumed;
  double get protein => _protein;
  double get carbs => _carbs;
  double get fat => _fat;
  double get waterIntake => _waterIntake;
  List<Map<String, dynamic>> get meals => _meals;

  void addMeals(List<Map<String, dynamic>> newFoods) {
    for (final food in newFoods) {
      _meals.add(food);
      _caloriesConsumed += (food['cal'] as int).toDouble();
      _protein += (food['p'] as int).toDouble();
      _carbs += (food['c'] as int).toDouble();
      _fat += (food['g'] as int).toDouble();
    }
    notifyListeners();
  }

  void removeMeal(int index) {
    final food = _meals[index];
    _caloriesConsumed -= (food['cal'] as int).toDouble();
    _protein -= (food['p'] as int).toDouble();
    _carbs -= (food['c'] as int).toDouble();
    _fat -= (food['g'] as int).toDouble();
    _meals.removeAt(index);
    notifyListeners();
  }

  void setWater(double liters) {
    _waterIntake = liters;
    notifyListeners();
  }
}
