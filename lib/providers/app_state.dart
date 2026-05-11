import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  // --- DADOS DO USUÁRIO ---
  String _userName = '';
  String _userEmail = '';
  String _token = '';
  int _userId = 0;

  String get userName => _userName;
  String get userEmail => _userEmail;
  String get token => _token;
  int get userId => _userId;

  void setUser(String name, String email) {
    _userName = name;
    _userEmail = email;
    notifyListeners();
  }

  void setToken(String token) {
    _token = token;
    notifyListeners();
  }

  void setUserId(int id) {
    _userId = id;
    notifyListeners();
  }

  void clearUser() {
    _userName = '';
    _userEmail = '';
    _token = '';
    _userId = 0;
    _hasPlan = false;
    _goal = '';
    _weight = 0;
    _height = 0;
    _age = 0;
    _gender = '';
    _activityLevel = '';
    _waterGoal = 2.5;
    _allergies = [];
    _preferences = [];
    _caloriesGoal = 0;
    _proteinGoal = 0;
    _carbsGoal = 0;
    _fatGoal = 0;
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
  List<String> _allergies = [];
  List<String> _preferences = [];

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
  List<String> get allergies => List.unmodifiable(_allergies);
  List<String> get preferences => List.unmodifiable(_preferences);
  double get caloriesGoal => _caloriesGoal;
  double get proteinGoal => _proteinGoal;
  double get carbsGoal => _carbsGoal;
  double get fatGoal => _fatGoal;

  // Chamado ao CRIAR plano manualmente
  void setPlan({
    required String goal,
    required double weight,
    required double height,
    required int age,
    required String gender,
    required String activityLevel,
    required double waterGoal,
    List<String> allergies = const [],
    List<String> preferences = const [],
  }) {
    _goal = goal;
    _weight = weight;
    _height = height;
    _age = age;
    _gender = gender;
    _activityLevel = activityLevel;
    _waterGoal = waterGoal;
    _allergies = List.of(allergies);
    _preferences = List.of(preferences);
    _hasPlan = true;
    _calculateGoals();
    notifyListeners();
  }

  // Chamado ao CARREGAR plano do banco (login ou reload)
  void setPlanFromDb({
    required double caloriesGoal,
    required double proteinGoal,
    required double carbsGoal,
    required double fatGoal,
    required double waterGoal,
    String goal = '',
    double weight = 0,
    double height = 0,
    int age = 0,
    String gender = '',
    String activityLevel = '',
  }) {
    _caloriesGoal = caloriesGoal;
    _proteinGoal = proteinGoal;
    _carbsGoal = carbsGoal;
    _fatGoal = fatGoal;
    _waterGoal = waterGoal;
    if (goal.isNotEmpty) _goal = goal;
    if (weight > 0) _weight = weight;
    if (height > 0) _height = height;
    if (age > 0) _age = age;
    if (gender.isNotEmpty) _gender = gender;
    if (activityLevel.isNotEmpty) _activityLevel = activityLevel;
    _hasPlan = true;
    notifyListeners();
  }

  void _calculateGoals() {
    double tmb;
    if (_gender == 'Masculino') {
      tmb = 88.36 + (13.4 * _weight) + (4.8 * _height) - (5.7 * _age);
    } else {
      tmb = 447.6 + (9.2 * _weight) + (3.1 * _height) - (4.3 * _age);
    }
    final factors = {
      'Sedentário': 1.2,
      'Levemente Ativo': 1.375,
      'Moderadamente Ativo': 1.55,
      'Muito Ativo': 1.725,
      'Atleta': 1.9,
    };
    double tdee = tmb * (factors[_activityLevel] ?? 1.2);
    switch (_goal) {
      case 'Emagrecimento':
        tdee *= 0.85;
        break;
      case 'Ganho de Massa':
        tdee *= 1.10;
        break;
      case 'Melhora da Performance':
        tdee *= 1.05;
        break;
    }
    _caloriesGoal = tdee.roundToDouble();
    switch (_goal) {
      case 'Emagrecimento':
        _proteinGoal = (_weight * 2.0).roundToDouble();
        _fatGoal = (_caloriesGoal * 0.25 / 9).roundToDouble();
        break;
      case 'Ganho de Massa':
        _proteinGoal = (_weight * 2.2).roundToDouble();
        _fatGoal = (_caloriesGoal * 0.25 / 9).roundToDouble();
        break;
      default:
        _proteinGoal = (_weight * 1.8).roundToDouble();
        _fatGoal = (_caloriesGoal * 0.30 / 9).roundToDouble();
    }
    _carbsGoal =
        ((_caloriesGoal - (_proteinGoal * 4) - (_fatGoal * 9)) / 4)
            .roundToDouble();
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
  List<Map<String, dynamic>> get meals => List.unmodifiable(_meals);

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
    if (index < 0 || index >= _meals.length) return;
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
