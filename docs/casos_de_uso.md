## Casos de Uso

Os Casos de Uso (UC) descrevem as interações entre os atores (usuários ou outros sistemas) e o sistema para alcançar um objetivo específico. Eles são fundamentais para entender as funcionalidades do sistema sob a perspectiva do usuário.

### UC01: Cadastrar Perfil Biométrico
*   **Descrição:** Permite que o usuário forneça os dados necessários para o cálculo nutricional e personalização da dieta.
*   **Ator Principal:** Usuário Final.
*   **Pré-condição:** Usuário estar logado no aplicativo.
*   **Fluxo Principal:**
    1.  O usuário acessa a tela de perfil.
    2.  O usuário insere os seguintes dados: Peso, Altura, Idade, Gênero e Nível de Atividade Física.
    3.  O usuário seleciona o objetivo (Ex: Emagrecimento, Ganho de Massa).
    4.  O sistema valida os dados inseridos.
    5.  O sistema salva os dados do perfil localmente e/ou na nuvem.
*   **Pós-condição:** Perfil do usuário atualizado e pronto para ser utilizado pela IA na geração de dietas.

### UC02: Gerar Dieta por IA
*   **Descrição:** O sistema utiliza os dados do perfil do usuário e preferências para solicitar uma dieta personalizada à inteligência artificial.
*   **Ator Principal:** Usuário Final.
*   **Ator Secundário:** API de Inteligência Artificial (Gemini/OpenAI).
*   **Pré-condição:** Usuário estar logado e ter um perfil biométrico cadastrado.
*   **Fluxo Principal:**
    1.  O usuário clica em "Gerar Nova Dieta".
    2.  O sistema compila os dados do perfil do usuário (UC01) e as preferências alimentares (UC03).
    3.  O sistema envia um prompt estruturado para a API de IA com todas as informações relevantes.
    4.  A API de IA processa o prompt e retorna um plano alimentar em formato JSON.
    5.  O sistema formata o plano alimentar recebido e o exibe na tela para o usuário.
*   **Fluxo Alternativo (Erro de Conexão com IA):**
    *   Se a API de IA não responder ou retornar um erro, o sistema exibe uma mensagem: "Não foi possível conectar à IA. Verifique sua conexão ou tente novamente mais tarde."
*   **Pós-condição:** Uma dieta semanal personalizada é exibida para o usuário.

### UC03: Cadastrar Restrições Alimentares
*   **Descrição:** Permite que o usuário informe suas restrições ou preferências alimentares para que a IA as considere na geração da dieta.
*   **Ator Principal:** Usuário Final.
*   **Pré-condição:** Usuário estar logado no aplicativo.
*   **Fluxo Principal:**
    1.  O usuário acessa a seção de "Filtros Alimentares" ou "Preferências".
    2.  O usuário seleciona as restrições aplicáveis (ex: Vegano, Low Carb, Intolerante a Lactose, Alergia a Glúten, etc.).
    3.  O sistema salva as restrições selecionadas no perfil do usuário.
*   **Pós-condição:** As restrições alimentares são armazenadas e serão utilizadas como filtros mandatórios na próxima geração de dieta pela IA.

### UC04: Registrar Refeição Concluída
*   **Descrição:** Permite que o usuário marque uma refeição sugerida pela dieta como concluída.
*   **Ator Principal:** Usuário Final.
*   **Pré-condição:** Usuário estar logado e ter uma dieta gerada e exibida.
*   **Fluxo Principal:**
    1.  O usuário visualiza a dieta do dia.
    2.  O usuário clica em um botão ou checkbox ao lado de uma refeição para marcá-la como "concluída" ou "check".
    3.  O sistema registra a conclusão da refeição.
*   **Pós-condição:** A refeição é marcada como concluída no log diário do usuário.

### UC05: Registrar Ingestão de Água
*   **Descrição:** Permite que o usuário registre a quantidade de água consumida e visualize sua meta diária.
*   **Ator Principal:** Usuário Final.
*   **Pré-condição:** Usuário estar logado no aplicativo.
*   **Fluxo Principal:**
    1.  O usuário acessa a seção de "Controle de Água".
    2.  O sistema exibe a meta diária de hidratação do usuário (calculada com base nos dados do perfil).
    3.  O usuário clica em um botão para registrar um copo de água (ou uma quantidade predefinida).
    4.  O sistema atualiza o total de água consumida no dia.
*   **Pós-condição:** O registro de água é atualizado e o progresso em relação à meta diária é exibido.

### UC06: Visualizar Gráfico de Evolução de Peso
*   **Descrição:** Permite que o usuário visualize seu histórico de peso em um formato gráfico para acompanhar sua evolução.
*   **Ator Principal:** Usuário Final.
*   **Pré-condição:** Usuário estar logado e ter inserido dados de peso em diferentes datas.
*   **Fluxo Principal:**
    1.  O usuário acessa a seção de "Evolução de Peso" ou "Progresso".
    2.  O sistema recupera o histórico de peso do usuário.
    3.  O sistema gera e exibe um gráfico mostrando a variação do peso ao longo do tempo.
*   **Pós-condição:** O usuário visualiza seu progresso de peso através de um gráfico.

### UC07: Realizar Cadastro de Novo Usuário
*   **Descrição:** Permite que um novo usuário crie uma conta no sistema DietHub.
*   **Ator Principal:** Usuário Não Registrado.
*   **Pré-condição:** O usuário está na tela de cadastro.
*   **Fluxo Principal:**
    1.  O usuário acessa a tela de cadastro.
    2.  O usuário preenche os campos: Nome, CPF, Email, Senha e Confirmação de Senha.
    3.  O sistema valida se todos os campos obrigatórios foram preenchidos e se a senha e a confirmação de senha coincidem.
    4.  O sistema envia os dados para o backend para registro.
    5.  O backend criptografa a senha e armazena os dados do usuário no banco de dados.
    6.  O sistema exibe uma mensagem de sucesso e redireciona o usuário para a tela de login ou home.
*   **Fluxo Alternativo (Dados Inválidos/Faltando):**
    *   Se algum campo obrigatório não for preenchido ou as senhas não coincidirem, o sistema exibe uma mensagem de erro apropriada.
*   **Fluxo Alternativo (Erro no Backend):**
    *   Se ocorrer um erro durante o registro no backend (ex: email já cadastrado, erro de banco de dados), o sistema exibe uma mensagem de erro.
*   **Pós-condição:** Uma nova conta de usuário é criada no sistema.

### UC08: Realizar Login de Usuário
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
