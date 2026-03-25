| ID | Categoria | Regra de Negócio |
| --- | --- | --- |
| **RN01** | **Cálculo Nutricional** | O cálculo de calorias basais deve seguir obrigatoriamente a fórmula de Mifflin-St Jeor, cruzando dados de peso, altura, idade e sexo biológico. |
| **RN02** | **Segurança Alimentar** | A IA é impedida de gerar planos alimentares com valor calórico inferior a 1.200 kcal/dia para mulheres e 1.500 kcal/dia para homens, visando evitar dietas de restrição severa sem supervisão médica. |
| **RN03** | **Distribuição de Macronutrientes** | Todo plano gerado deve manter um equilíbrio entre Carboidratos (45-65%), Proteínas (10-35%) e Lipídios (20-35%), conforme as recomendações gerais de saúde, salvo indicação contrária por objetivo específico (ex: Low Carb). |
| **RN04** | **Restrições Alimentares** | Caso o usuário cadastre alergias ou intolerâncias (Glúten, Lactose, Amendoim, etc.), esta restrição torna-se um filtro mandatório no prompt enviado à IA, sobrepondo qualquer outra preferência. |
| **RN05** | **Isenção de Responsabilidade** | O aplicativo deve exibir um termo de consentimento no primeiro acesso informando que as sugestões da IA são de caráter informativo e não substituem o acompanhamento de um nutricionista ou médico. |
| **RN06** | **Limitação de Idade** | O sistema deve bloquear o cadastro de usuários menores de 18 anos, recomendando que o acompanhamento nutricional para menores seja feito presencialmente por especialistas pediátricos. |
| **RN07** | **Estrutura de Resposta da IA** | A IA deve retornar os dados da dieta em formato JSON estruturado, contendo: Nome da Refeição, Horário Sugerido, Ingredientes, Quantidades e Macronutrientes. |
| **RN08** | **Regionalização de Cardápio** | O motor de IA deve priorizar alimentos de fácil acesso no país/região detectado pelo GPS ou idioma do dispositivo, evitando ingredientes importados de alto custo. |
| **RN09** | **Substituição de Alimentos** | Se o usuário solicitar a troca de um alimento específico, a IA deve sugerir um substituto com densidade calórica e macronutrientes equivalentes (ex: trocar Arroz por Batata Doce). |
| **RN10** | **Autenticação de Usuário** | O sistema deve permitir o registro de novos usuários com nome, CPF, email e senha, e o login de usuários existentes com email e senha. As senhas devem ser armazenadas de forma segura (hash). |
| **RN11** | **Validação de Cadastro** | Todos os campos de cadastro (nome, CPF, email, password) são obrigatórios. As senhas devem ser confirmadas no momento do cadastro. |
| **RN12** | **Segurança de Senha** | As senhas dos usuários devem ser criptografadas utilizando bcrypt antes de serem armazenadas no banco de dados. |
| **RN13** | **Geração de Token JWT** | Após o login bem-sucedido, o sistema deve gerar um JSON Web Token (JWT) para autenticação de sessões futuras, com validade de 1 hora. |
