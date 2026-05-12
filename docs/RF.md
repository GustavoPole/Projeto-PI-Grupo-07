| ID | Requisito Funcional | Descrição |
| --- | --- | --- |
| **RF01** | **Gestão de Perfil do Usuário** | O sistema deve permitir que o usuário insira e atualize dados biométricos como idade, peso, altura, sexo e nível de atividade física. |
| **RF02** | **Configuração de Filtros Alimentares** | O usuário deve ser capaz de selecionar e aplicar restrições alimentares (ex: Vegano, Low Carb, Intolerante a Lactose) que serão consideradas nos cálculos locais e enviadas para a IA em funcionalidades implementadas. |
| **RF03** | **Cadastro de Usuário** | O sistema deve permitir que novos usuários se cadastrem fornecendo nome, CPF, email e senha. |
| **RF04** | **Autenticação de Usuário** | O sistema deve permitir que usuários existentes façam login utilizando seu email e senha. |
| **RF05** | **Exibição de Mensagens de Feedback** | O sistema deve exibir mensagens de sucesso ou erro para as operações de cadastro e login. |
| **RF06** | **Navegação entre Telas** | O sistema deve permitir a navegação entre as telas de login, cadastro e a tela principal (home) após a autenticação. |
| **RF07** | **Proteção de Rotas** | O sistema backend deve proteger rotas sensíveis, exigindo um token JWT válido para acesso (ex: rota de perfil, rotas de IA). |
| **RF08** | **Digitalização de Plano Alimentar** | O sistema deve permitir que o usuário digitalize um plano alimentar a partir de uma imagem (JPG, PNG) ou PDF, utilizando inteligência artificial para extrair as informações. |
| **RF09** | **Sugestão de Substituição de Alimentos** | O sistema deve sugerir substituições nutricionais para um alimento específico, utilizando inteligência artificial, considerando as preferências e alergias do usuário. |
| **RF10** | **Aceitação de Substituição de Alimentos** | O sistema deve permitir que o usuário aceite uma sugestão de substituição de alimento, atualizando o plano alimentar ativo no banco de dados. |
