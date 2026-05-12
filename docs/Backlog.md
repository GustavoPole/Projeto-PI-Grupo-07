# Backlog do Projeto - DietHub

Este backlog organiza as funcionalidades do projeto DietHub em épicos, que representam grandes blocos de trabalho ou áreas de valor para o usuário. Cada épico agrupa requisitos e casos de uso relacionados, facilitando o planejamento e a gestão do desenvolvimento.

## 1. Épicos do Projeto

| Épico | Descrição |
|:---|:---|
| **E01: Autenticação e Gestão de Usuários** | Gerenciar o ciclo de vida do usuário no sistema, incluindo cadastro, login seguro e autenticação para acesso às funcionalidades protegidas. |
| **E02: Gestão de Perfil e Preferências Alimentares** | Permitir que o usuário crie e mantenha seu perfil biométrico e defina suas restrições e preferências alimentares, que serão utilizadas para personalizar a dieta. |
| **E03: Geração e Exibição de Dietas Personalizadas** | Implementar a funcionalidade de digitalização de planos alimentares existentes e a sugestão de substituições de alimentos, além de exibir planos ativos. A geração de planos por IA e a análise de fugas de dieta estão atualmente mockadas. |
| **E04: Acompanhamento de Progresso e Hábitos** | Fornecer ferramentas para que o usuário possa registrar e monitorar seu progresso em relação à ingestão de água e evolução de peso, além de registrar refeições (localmente). |
| **E05: Infraestrutura e Qualidade do Sistema** | Garantir que o sistema atenda aos padrões de performance, segurança, arquitetura, disponibilidade e manutenibilidade, além de gerenciar a comunicação com APIs externas. |

## 2. Detalhamento dos Épicos

### E01: Autenticação e Gestão de Usuários

Este épico abrange todas as funcionalidades relacionadas ao acesso e gerenciamento da conta do usuário no DietHub. É fundamental para garantir a segurança e a personalização da experiência.

*   **Funcionalidades Chave:**
    *   Cadastro de novos usuários (Nome, CPF, Email, Senha).
    *   Login de usuários existentes (Email, Senha).
    *   Validação de dados de cadastro e login.
    *   Geração e validação de tokens de autenticação (JWT).
    *   Proteção de rotas sensíveis no backend.
*   **Requisitos Relacionados:**
    *   **RF07:** Cadastro de Usuário
    *   **RF08:** Autenticação de Usuário
    *   **RF09:** Exibição de Mensagens de Feedback
    *   **RF10:** Navegação entre Telas (Login/Cadastro/Home)
    *   **RF11:** Proteção de Rotas
    *   **RN10:** Autenticação de Usuário
    *   **RN11:** Validação de Cadastro
    *   **RN12:** Segurança de Senha
    *   **RN13:** Geração de Token JWT
*   **Casos de Uso Relacionados:**
    *   **UC07:** Realizar Cadastro de Novo Usuário
    *   **UC08:** Realizar Login de Usuário

### E02: Gestão de Perfil e Preferências Alimentares

Este épico foca na coleta e manutenção das informações pessoais e dietéticas do usuário, que são a base para a personalização das dietas geradas pela IA. A criação de plano no aplicativo coleta esses dados e calcula metas localmente, mas não gera um plano via IA diretamente.

*   **Funcionalidades Chave:**
    *   Coleta de dados biométricos (Peso, Altura, Idade, Gênero, Nível de Atividade Física).
    *   Seleção de objetivo (Emagrecimento, Ganho de Massa, etc.).
    *   Definição de restrições e preferências alimentares (Vegano, Low Carb, Alergias, etc.).
    *   Armazenamento e atualização segura dos dados do perfil (localmente no app e no banco de dados para planos digitalizados).
    *   Cálculo local de metas calóricas e de macronutrientes com base nos dados do perfil.
*   **Requisitos Relacionados:**
    *   **RF01:** Gestão de Perfil do Usuário
    *   **RF03:** Configuração de Filtros Alimentares
    *   **RN04:** Prioridade de Alérgenos
    *   **RN06:** Limitação de Idade (para cadastro)
    *   **RN01:** Algoritmo de Taxa Metabólica (TMB) - *Aplicado localmente no app*.
    *   **RN03:** Distribuição de Macronutrientes - *Aplicado localmente no app*.
*   **Casos de Uso Relacionados:**
    *   **UC01:** Cadastrar Perfil Biométrico
    *   **UC03:** Cadastrar Restrições Alimentares

### E03: Geração e Exibição de Dietas Personalizadas

Este épico é responsável por integrar a inteligência artificial para digitalizar e sugerir substituições em planos alimentares, além de exibir os planos ativos. A geração de planos por IA e a análise de fugas de dieta estão atualmente com dados simulados (mockadas).

*   **Funcionalidades Chave:**
    *   Digitalização de planos alimentares a partir de imagens/PDFs usando IA (Gemini).
    *   Processamento da resposta da IA (JSON estruturado) para planos digitalizados.
    *   Persistência de planos digitalizados no banco de dados.
    *   Exibição do plano alimentar ativo (seja digitalizado ou mockado) na interface do usuário.
    *   Sugestão de substituições de alimentos via IA (Gemini, se configurado).
    *   Aceitação de substituições de alimentos, atualizando o plano no banco de dados.
    *   *Geração de dieta personalizada via IA (mockada).* 
    *   *Análise de fuga da dieta via IA (mockada).*
*   **Requisitos Relacionados:**
    *   **RF02:** Geração de Dieta Personalizada - *Atualmente implementada via digitalização de planos e sugestão de trocas; geração de plano do zero via IA está mockada.*
    *   **RF12:** Digitalização de Plano Alimentar.
    *   **RF13:** Sugestão de Substituição de Alimentos.
    *   **RF14:** Aceitação de Substituição de Alimentos.
    *   **RN07:** Estrutura de Resposta (Parsing) - *Aplicado para digitalização de planos e sugestão de trocas.*
    *   **RN09:** Substituição Unitária - *Aplicado para sugestão de trocas.*
*   **Casos de Uso Relacionados:**
    *   **UC02:** Gerar Dieta por IA - *Revisado para refletir digitalização e trocas, com geração inicial mockada.*
    *   **UC09:** Digitalizar Plano Alimentar.
    *   **UC10:** Sugerir Substituição de Alimento.
    *   **UC11:** Aceitar Substituição de Alimento.

### E04: Acompanhamento de Progresso e Hábitos

Este épico visa empoderar o usuário com ferramentas para monitorar sua adesão à dieta e seus resultados de saúde ao longo do tempo. O registro de refeições é feito localmente no aplicativo.

*   **Funcionalidades Chave:**
    *   Registro de refeições concluídas (check-in) - *Funcionalidade local no app.*
    *   Registro da ingestão diária de água.
    *   Cálculo e exibição da meta diária de hidratação.
    *   Registro e histórico de peso.
    *   Geração de gráficos de evolução de peso.
*   **Requisitos Relacionados:**
    *   **RF04:** Log de Refeições - *Funcionalidade local no app.*
    *   **RF05:** Controle de Água
    *   **RF06:** Evolução de Peso
*   **Casos de Uso Relacionados:**
    *   **UC04:** Registrar Refeição Concluída - *Funcionalidade local no app.*
    *   **UC05:** Registrar Ingestão de Água
    *   **UC06:** Visualizar Gráfico de Evolução de Peso

### E05: Infraestrutura e Qualidade do Sistema

Este épico engloba os aspectos técnicos e de qualidade que garantem o bom funcionamento, a segurança e a sustentabilidade do aplicativo DietHub.

*   **Funcionalidades Chave:**
    *   Garantia de performance da IA (tempo de resposta) - *Aplicado para digitalização e sugestão de trocas.*
    *   Adesão à arquitetura Flutter (Clean Architecture).
    *   Conformidade com a LGPD para dados sensíveis.
    *   Funcionalidade offline para cardápios (cache local) - *Para planos ativos.*
    *   Capacidade de escalabilidade do backend.
    *   Usabilidade e compatibilidade com sistemas operacionais.
    *   Manutenibilidade do código e confiabilidade dos dados.
    *   Exibição de termo de consentimento e isenção de responsabilidade.
*   **Requisitos Relacionados:**
    *   **RNF01:** Performance da IA
    *   **RNF02:** Arquitetura do Aplicativo
    *   **RNF03:** Segurança de Dados
    *   **RNF04:** Disponibilidade Offline
    *   **RNF05:** Escalabilidade do Backend
    *   **RNF06:** Usabilidade
    *   **RNF07:** Compatibilidade
    *   **RNF08:** Manutenibilidade
    *   **RNF09:** Confiabilidade
    *   **RN05:** Aviso de Isenção de Responsabilidade
