## Casos de Uso

Os Casos de Uso (UC) descrevem as interações entre os atores (usuários ou outros sistemas) e o sistema para alcançar um objetivo específico. Eles são fundamentais para entender as funcionalidades do sistema sob a perspectiva do usuário.

### UC01: Cadastrar Perfil Biométrico
*   **Descrição:** Permite que o usuário forneça os dados necessários para o cálculo nutricional local e personalização de preferências.
*   **Ator Principal:** Usuário Final.
*   **Pré-condição:** Usuário estar logado no aplicativo.
*   **Fluxo Principal:**
    1.  O usuário acessa a tela de perfil.
    2.  O usuário insere os seguintes dados: Peso, Altura, Idade, Gênero e Nível de Atividade Física.
    3.  O usuário seleciona o objetivo (Ex: Emagrecimento, Ganho de Massa).
    4.  O sistema valida os dados inseridos.
    5.  O sistema salva os dados do perfil localmente no aplicativo.
*   **Pós-condição:** Perfil do usuário atualizado e pronto para ser utilizado nos cálculos locais e envio de dados para a IA (em funcionalidades implementadas).

### UC02: Cadastrar Restrições Alimentares
*   **Descrição:** Permite que o usuário informe suas restrições ou preferências alimentares para que o sistema as considere nos cálculos locais e as envie para a IA em funcionalidades implementadas.
*   **Ator Principal:** Usuário Final.
*   **Pré-condição:** Usuário estar logado no aplicativo.
*   **Fluxo Principal:**
    1.  O usuário acessa a seção de "Filtros Alimentares" ou "Preferências".
    2.  O usuário seleciona as restrições aplicáveis (ex: Vegano, Low Carb, Intolerante a Lactose, Alergia a Glúten, etc.).
    3.  O sistema salva as restrições selecionadas no perfil do usuário localmente.
*   **Pós-condição:** As restrições alimentares são armazenadas e serão utilizadas como filtros nos cálculos locais e no envio de prompts para a IA (em funcionalidades implementadas).

### UC03: Realizar Cadastro de Novo Usuário
*   **Descrição:** Permite que um novo usuário crie uma conta no sistema DietHub.
*   **Ator Principal:** Usuário Não Registrado.
*   **Pré-condição:** O usuário está na tela de cadastro.
*   **Fluxo Principal:**
    1.  O usuário acessa a tela de cadastro.
    2.  O usuário preenche os campos: Nome, CPF, Email, Senha e Confirmação de Senha.
    3.  O sistema valida se todos os campos obrigatórios foram preenchidos e se a senha e a confirmação de senha coincidem.
    4.  O sistema envia os dados para o backend para registro.
    5.  O backend criptografa a senha e armazena os dados do usuário no banco de dados.
    6.  O sistema exibe uma mensagem de sucesso e redireciona o usuário para a tela principal (Home).
*   **Fluxo Alternativo (Dados Inválidos/Faltando):**
    *   Se algum campo obrigatório não for preenchido ou as senhas não coincidirem, o sistema exibe uma mensagem de erro apropriada.
*   **Fluxo Alternativo (Erro no Backend):**
    *   Se ocorrer um erro durante o registro no backend (ex: email já cadastrado, erro de banco de dados), o sistema exibe uma mensagem de erro.
*   **Pós-condição:** Uma nova conta de usuário é criada no sistema.

### UC04: Realizar Login de Usuário
*   **Descrição:** Permite que um usuário registrado acesse sua conta no sistema DietHub.
*   **Ator Principal:** Usuário Registrado.
*   **Pré-condição:** O usuário está na tela de login.
*   **Fluxo Principal:**
    1.  O usuário acessa a tela de login.
    2.  O usuário preenche os campos: Email e Senha.
    3.  O sistema envia os dados para o backend para autenticação.
    4.  O backend verifica as credenciais e, se válidas, gera um token JWT.
    5.  O sistema recebe o token JWT.
    6.  O sistema exibe uma mensagem de sucesso e redireciona o usuário para a tela principal (Home).
*   **Fluxo Alternativo (Credenciais Inválidas):**
    *   Se o email ou a senha estiverem incorretos, o sistema exibe uma mensagem: "Email ou senha inválidos."
*   **Fluxo Alternativo (Erro no Backend):**
    *   Se ocorrer um erro durante a autenticação no backend, o sistema exibe uma mensagem de erro.
*   **Pós-condição:** O usuário está autenticado no sistema e tem acesso às funcionalidades protegidas.

### UC05: Digitalizar Plano Alimentar
*   **Descrição:** Permite que o usuário envie uma imagem ou PDF de um plano alimentar para que a IA extraia e estruture as informações.
*   **Ator Principal:** Usuário Final.
*   **Ator Secundário:** API de Inteligência Artificial (Gemini).
*   **Pré-condição:** Usuário estar logado no aplicativo.
*   **Fluxo Principal:**
    1.  O usuário acessa a tela de digitalização de plano.
    2.  O usuário seleciona um arquivo de imagem (JPG, PNG) ou PDF contendo o plano alimentar.
    3.  O sistema envia o arquivo para a API de IA para análise.
    4.  A API de IA processa o arquivo e retorna os dados do plano em formato JSON estruturado.
    5.  O sistema exibe um preview do plano extraído para o usuário.
    6.  O usuário confirma o plano, e o sistema o salva no banco de dados, desativando qualquer plano anterior.
*   **Fluxo Alternativo (Erro na Digitalização):**
    *   Se a IA não conseguir extrair o plano ou retornar um erro, o sistema exibe uma mensagem de erro.
*   **Pós-condição:** Um novo plano alimentar é salvo no banco de dados e se torna o plano ativo do usuário.

### UC06: Sugerir Substituição de Alimento
*   **Descrição:** Permite que o usuário solicite sugestões de substituição para um alimento específico em seu plano alimentar.
*   **Ator Principal:** Usuário Final.
*   **Ator Secundário:** API de Inteligência Artificial (Gemini).
*   **Pré-condição:** Usuário estar logado e ter um plano alimentar ativo.
*   **Fluxo Principal:**
    1.  O usuário visualiza seu plano alimentar ativo.
    2.  O usuário seleciona um alimento para o qual deseja uma substituição.
    3.  O sistema envia o nome do alimento, objetivo nutricional e preferências/alergias do usuário para a API de IA.
    4.  A API de IA retorna uma lista de sugestões de substituição com justificativas nutricionais.
    5.  O sistema exibe as sugestões para o usuário.
*   **Fluxo Alternativo (Erro na Sugestão):**
    *   Se a IA não conseguir gerar sugestões ou retornar um erro, o sistema exibe uma mensagem de erro.
*   **Pós-condição:** O usuário recebe sugestões de substituição para o alimento selecionado.

### UC07: Aceitar Substituição de Alimento
*   **Descrição:** Permite que o usuário aceite uma sugestão de substituição de alimento, atualizando seu plano alimentar ativo.
*   **Ator Principal:** Usuário Final.
*   **Pré-condição:** Usuário estar logado, ter um plano alimentar ativo e ter recebido sugestões de substituição (UC10).
*   **Fluxo Principal:**
    1.  O usuário visualiza as sugestões de substituição.
    2.  O usuário seleciona uma das sugestões para aceitar.
    3.  O sistema registra a substituição no banco de dados, associando-a ao plano alimentar ativo do usuário para a data atual.
    4.  O sistema atualiza a exibição do plano para refletir a substituição.
*   **Pós-condição:** O plano alimentar ativo do usuário é atualizado com a substituição aceita para o dia corrente.
