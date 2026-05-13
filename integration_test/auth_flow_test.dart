import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:projeto_pi/main.dart';
import 'package:projeto_pi/providers/app_state.dart';
import 'package:projeto_pi/screens/home/home_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-end Authentication Flow Tests', () {
    testWidgets('CT13 - Validar fluxo completo de autenticação: Cadastro e Login', (WidgetTester tester) async {
      // Inicia o aplicativo
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => AppState(),
          child: const MyApp(),
        ),
      );
      await tester.pumpAndSettle();

      // --- Fluxo de Cadastro (TC01 - Cadastro com dados válidos) ---
      // Navegar para a tela de registro
      expect(find.text('Entrar'), findsOneWidget); // Verifica se está na tela de Login
      await tester.tap(find.text('Criar conta'));
      await tester.pumpAndSettle();

      expect(find.text('Crie sua conta'), findsOneWidget); // Verifica se está na tela de Registro

      // Preencher os campos de registro
      await tester.enterText(find.widgetWithText(TextField, 'Nome completo'), 'Usuario Integracao');
      await tester.enterText(find.widgetWithText(TextField, 'CPF'), '111.222.333-44');
      await tester.enterText(find.widgetWithText(TextField, 'E-mail'), 'integracao@teste.com');
      await tester.enterText(find.widgetWithText(TextField, 'Senha'), 'senhaIntegracao123');
      await tester.enterText(find.widgetWithText(TextField, 'Confirmar Senha'), 'senhaIntegracao123');

      // Clicar no botão de cadastro
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle(const Duration(seconds: 3)); // Esperar o SnackBar e a navegação

      // Verificar mensagem de sucesso e retorno para a tela de login
      expect(find.text('Conta criada com sucesso!'), findsOneWidget);
      expect(find.text('Bem-vindo de volta!'), findsOneWidget); // Mensagem da tela de Login

      // --- Fluxo de Login (TC04 - Login válido) ---
      // Preencher os campos de login com as credenciais recém-criadas
      await tester.enterText(find.widgetWithText(TextField, 'E-mail'), 'integracao@teste.com');
      await tester.enterText(find.widgetWithText(TextField, 'Senha'), 'senhaIntegracao123');

      // Clicar no botão de login
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle(const Duration(seconds: 3)); // Esperar a navegação para Home

      // Verificar se o usuário está na HomeScreen
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('Olá, Usuario Integracao'), findsOneWidget); // Verifica se o nome do usuário aparece na Home
    });

    testWidgets('CT05 - Validar login inválido', (WidgetTester tester) async {
      // Inicia o aplicativo
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => AppState(),
          child: const MyApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Preencher os campos de login com credenciais inválidas
      await tester.enterText(find.widgetWithText(TextField, 'E-mail'), 'naoexiste@teste.com');
      await tester.enterText(find.widgetWithText(TextField, 'Senha'), 'senhaerrada');

      // Clicar no botão de login
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Verificar se a mensagem de erro é exibida
      expect(find.text('Credenciais inválidas.'), findsOneWidget);
    });
  });
}
