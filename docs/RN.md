| ID | Categoria | Regra de Negócio |
| --- | --- | --- |
| **RN01** | **Cálculo Nutricional** | O cálculo de calorias basais (TMB) e metas de macronutrientes deve seguir a fórmula de Harris-Benedict, cruzando dados de peso, altura, idade, sexo biológico e nível de atividade física. |
| **RN02** | **Segurança Alimentar** | A IA é impedida de gerar planos alimentares com valor calórico inferior a 1.200 kcal/dia para mulheres e 1.500 kcal/dia para homens, visando evitar dietas de restrição severa sem supervisão médica.|
| **RN03** | **Restrições Alimentares** | Caso o usuário cadastre alergias ou intolerâncias (Glúten, Lactose, Amendoim, etc.), esta restrição torna-se um filtro mandatório no prompt enviado à IA para sugestão de substituições, sobrepondo qualquer outra preferência. |
| **RN04** | **Estrutura de Resposta da IA** | A IA deve retornar os dados da dieta (para digitalização) e as sugestões de substituição em formato JSON estruturado, contendo as informações necessárias para o processamento do sistema. |
| **RN05** | **Substituição de Alimentos** | Se o usuário solicitar a troca de um alimento específico, a IA deve sugerir um substituto com densidade calórica e macronutrientes equivalentes (ex: trocar Arroz por Batata Doce). |
| **RN06** | **Autenticação de Usuário** | O sistema deve permitir o registro de novos usuários com nome, CPF, email e senha, e o login de usuários existentes com email e senha. As senhas devem ser armazenadas de forma segura (hash). |
| **RN07** | **Validação de Cadastro** | Todos os campos de cadastro (nome, CPF, email, password) são obrigatórios. As senhas devem ser confirmadas no momento do cadastro. |
| **RN08** | **Segurança de Senha** | As senhas dos usuários devem ser criptografadas utilizando bcrypt antes de serem armazenadas no banco de dados. |
| **RN09** | **Geração de Token JWT** | Após o login bem-sucedido, o sistema deve gerar um JSON Web Token (JWT) para autenticação de sessões futuras, com validade de 1 hora. |
| **RN10** | **Formato de Entrada para Digitalização de Plano** | O sistema deve aceitar arquivos de imagem (JPG, PNG) ou PDF para digitalização de planos alimentares. |
| **RN11** | **Validação de Resposta da IA (Digitalização)** | A IA deve retornar os dados do plano digitalizado em formato JSON estruturado, contendo nome do plano, macronutrientes máximos e uma lista de refeições com seus alimentos. |
| **RN12** | **Desativação de Plano Anterior** | Ao salvar um novo plano digitalizado, o sistema deve desativar qualquer plano alimentar ativo anterior do usuário no banco de dados. |
