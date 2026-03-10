As Regras de Negócio definem as diretrizes lógicas, restrições de saúde e normas operacionais que o sistema DietHub deve seguir para garantir a segurança e a eficácia do serviço.
---

🥗 1. Diretrizes Nutricionais e Cálculos
RN01 - Algoritmo de Taxa Metabólica (TMB): O cálculo de calorias basais deve seguir obrigatoriamente a fórmula de Mifflin-St Jeor, cruzando dados de peso, altura, idade e sexo biológico.

RN02 - Segurança de Ingestão Mínima: A IA é impedida de gerar planos alimentares com valor calórico inferior a 1.200 kcal/dia para mulheres e 1.500 kcal/dia para homens, visando evitar dietas de restrição severa sem supervisão médica.

RN03 - Distribuição de Macros: Todo plano gerado deve manter um equilíbrio entre Carboidratos (45-65%), Proteínas (10-35%) e Lipídios (20-35%), conforme as recomendações gerais de saúde, salvo indicação contrária por objetivo específico (ex: Low Carb).

---

⚠️ 2. Segurança e Restrições Alimentares
RN04 - Prioridade de Alérgenos: Caso o usuário cadastre alergias ou intolerâncias (Glúten, Lactose, Amendoim, etc.), esta restrição torna-se um filtro mandatório no prompt enviado à IA, sobrepondo qualquer outra preferência.

RN05 - Aviso de Isenção de Responsabilidade: O app deve exibir um termo de consentimento no primeiro acesso informando que as sugestões da IA são de caráter informativo e não substituem o acompanhamento de um nutricionista ou médico.

RN06 - Limitação de Idade: O sistema deve bloquear o cadastro de usuários menores de 18 anos, recomendando que o acompanhamento nutricional para menores seja feito presencialmente por especialistas pediátricos.

---

🤖 3. Inteligência Artificial e Resposta
RN07 - Estrutura de Resposta (Parsing): A IA deve retornar os dados da dieta em formato JSON estruturado, contendo: Nome da Refeição, Horário Sugerido, Ingredientes, Quantidades e Macronutrientes.

RN08 - Regionalização de Cardápio: O motor de IA deve priorizar alimentos de fácil acesso no país/região detectado pelo GPS ou idioma do dispositivo, evitando ingredientes importados de alto custo.

RN09 - Substituição Unitária: Se o usuário solicitar a troca de um alimento específico, a IA deve sugerir um substituto com densidade calórica e macronutrientes equivalentes (ex: trocar Arroz por Batata Doce).

💧 4. Hidratação e Evolução
RN10 - Meta Hídrica: A meta diária de água deve ser calculada com base na fórmula de 35ml por quilograma de peso atual do usuário.

RN11 - Janela de Atualização de Peso: O sistema só deve permitir a alteração do peso oficial para fins de gráfico e recalculo de dieta a cada 7 dias, desencorajando a pesagem diária obsessiva.
