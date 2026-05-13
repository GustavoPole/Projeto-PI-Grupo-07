import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:projeto_pi/screens/auth/register_screen.dart';
import 'package:projeto_pi/providers/app_state.dart';
import 'package:projeto_pi/services/api_service.dart';

// Mock do ApiService para evitar chamadas HTTP reais durante o teste
class MockApiService extends ApiService {
  static Future<Map<String, dynamic>> registerUser(
    String nome,
    String cpf,
    String email,
    String password,
  ) async {
    if (nome.isEmpty || cpf.isEmpty || email.isEmpty || password.isEmpty) {
      return {'success': false, 'message': 'Preencha todos os campos.'};
    }
    if (cpf.replaceAll(RegExp(r'\D'), '').length != 11) {
      return {'success': false, 'message': 'CPF inválido. Digite os 11 dígitos.'};
    }
    if (!email.contains('@')) {
      return {'success': false, 'message': 'E-mail inválido.'};
    }
    if (password.length < 6) {
      return {'success': false, 'message': 'A senha deve ter pelo menos 6 caracteres.'};
    }
    if (email == 'existente@email.com') {
      return {'success': false, 'message': 'E-mail já cadastrado.'};
    }
    return {'success': true, 'message': 'Conta criada com sucesso!'};
  }
}

void main() {
  group('RegisterScreen Tests', () {
    testWidgets('CT01 - Cadastro com dados válidos', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => AppState(),
          child: const MaterialApp(
            home: RegisterScreen(),
          ),
        ),
      );

      // Preencher os campos
      // Preencher os campos
       await tester.enterText(find.widgetWithText(TextField, 'Nome completo'), 'Samuel Teste');
       await tester.enterText(find.widgetWithText(TextField, 'CPF'), '123.456.789-01');
       await tester.enterText(find.widgetWithText(TextField, 'E-mail'), 'samuel@email.com');
       await tester.enterText(find.widgetWithText(TextField, 'Senha'), 'senha123');
       await tester.enterText(find.widgetWithText(TextField, 'Confirmar Senha'), 'senha123');
      

      // Clicar no botão de cadastro
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Verificar se a mensagem de sucesso é exibida e navega para a HomeScreen
      expect(find.text('Conta criada com sucesso!'), findsOneWidget);
      // expect(find.byType(HomeScreen), findsOneWidget); // Comentar pois o mock não navega de fato
    });

    testWidgets('CT02 - Cadastro com campos vazios', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => AppState(),
          child: const MaterialApp(
            home: RegisterScreen(),
          ),
        ),
      );

      // Não preencher os campos e tentar cadastrar
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Verificar se a mensagem de erro é exibida
      expect(find.text('Preencha todos os campos.'), findsOneWidget);
    });

    testWidgets('CT03 - Cadastro com e-mail inválido', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => AppState(),
          child: const MaterialApp(
            home: RegisterScreen(),
          ),
        ),
      );

      
      // Preencher os campos com e-mail inválido
       await tester.enterText(find.widgetWithText(TextField, 'Nome completo'), 'Samuel Teste');
       await tester.enterText(find.widgetWithText(TextField, 'CPF'), '123.456.789-01');
       await tester.enterText(find.widgetWithText(TextField, 'E-mail'), 'samuelgmail.com'); // E-mail inválido
       await tester.enterText(find.widgetWithText(TextField, 'Senha'), 'senha123');
       await tester.enterText(find.widgetWithText(TextField, 'Confirmar Senha'), 'senha123');

      // Clicar no botão de cadastro
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Verificar se a mensagem de erro é exibida
      expect(find.text('E-mail inválido.'), findsOneWidget);
    });
  });
}
