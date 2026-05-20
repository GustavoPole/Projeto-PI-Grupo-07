import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:projeto_pi/main.dart';
import 'package:projeto_pi/providers/app_state.dart';
import 'package:projeto_pi/screens/home/home_screen.dart';
import 'package:projeto_pi/screens/plan/create_plan_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-end Plan Generation Flow Tests', () {
    testWidgets('CT07 - Validar geração de plano alimentar', (WidgetTester tester) async {
      // Inicia o aplicativo e faz login (assumindo um usuário já registrado para simplificar o fluxo de teste)
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => AppState(),
          child: const MyApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Simular login (assumindo que o login é bem-sucedido e navega para HomeScreen)
      // Normalmente, você faria o login real aqui, mas para focar no plano, vamos simular o estado.
      final appState = tester.element(find.byType(MyApp)).read<AppState>();
      appState.setUser('Usuario Teste', 'teste@email.com');
      appState.setToken('mock_token_logged_in');
      await tester.pumpAndSettle();

      // Navegar para a tela de criação de plano
      expect(find.byType(HomeScreen), findsOneWidget);
      await tester.tap(find.byKey(const Key('create_plan_button'))); // Assumindo um botão na HomeScreen para criar plano
      await tester.pumpAndSettle();

      expect(find.byType(CreatePlanScreen), findsOneWidget);
      expect(find.text('Criar Plano Alimentar'), findsOneWidget);

      // Preencher a Página 1 - Dados Antropométricos
      await tester.enterText(find.byKey(const Key('age_field')), '30');
      await tester.enterText(find.byKey(const Key('weight_field')), '75');
      await tester.enterText(find.byKey(const Key('height_field')), '175');
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();

      // Preencher a Página 2 - Nível de Atividade
      await tester.tap(find.text('Moderadamente Ativo'));
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();

      // Preencher a Página 3 - Objetivo
      await tester.tap(find.text('Emagrecimento'));
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();

      // Preencher a Página 4 - Perfil (Alergias e Preferências)
      await tester.tap(find.text('Glúten')); // Selecionar alergia
      await tester.tap(find.text('Vegetariano')); // Selecionar preferência
      await tester.tap(find.text('Gerar Plano'));
      await tester.pumpAndSettle(const Duration(seconds: 5)); // Esperar a geração do plano

      // Verificar se o plano foi gerado e exibido na HomeScreen
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.textContaining('Plano personalizado gerado para seu objetivo de Emagrecimento'), findsOneWidget);
      expect(find.textContaining('Café da manhã'), findsOneWidget);
      expect(find.textContaining('Almoço'), findsOneWidget);
      expect(find.textContaining('Jantar'), findsOneWidget);

      // Verificar se as restrições foram consideradas (ex: ausência de carne para vegetariano)
      // Isso pode ser mais complexo de verificar diretamente na UI sem um mock mais elaborado da IA
      // Para este teste, vamos assumir que a mensagem de sucesso da geração do plano é suficiente.
    });
  });
}
