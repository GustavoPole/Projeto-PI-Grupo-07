# Backlog do Projeto - DietHub

Este backlog organiza as funcionalidades do projeto DietHub em épicos, que representam grandes blocos de trabalho ou áreas de valor para o usuário. Cada épico agrupa requisitos e casos de uso relacionados, facilitando o planejamento e a gestão do desenvolvimento.

## 1. Épicos do Projeto

| Épico | Descrição |
|:---|:---|
| **E01: Autenticação e Gestão de Usuários** | Gerenciar o ciclo de vida do usuário no sistema, incluindo cadastro, login seguro e autenticação para acesso às funcionalidades protegidas. |
| **E02: Gestão de Perfil e Preferências Alimentares** | Permitir que o usuário crie e mantenha seu perfil biométrico e defina suas restrições e preferências alimentares, que serão utilizadas para personalizar a dieta. |
| **E03: Geração e Exibição de Dietas Personalizadas** | Implementar o motor principal do aplicativo, que utiliza inteligência artificial para gerar planos alimentares semanais personalizados com base nos dados do usuário e exibi-los de forma clara. |
| **E04: Acompanhamento de Progresso e Hábitos** | Fornecer ferramentas para que o usuário possa registrar e monitorar seu progresso em relação à dieta, ingestão de água e evolução de peso. |
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

Este épico foca na coleta e manutenção das informações pessoais e dietéticas do usuário, que são a base para a personalização das dietas geradas pela IA.

*   **Funcionalidades Chave:**
    *   Coleta de dados biométricos (Peso, Altura, Idade, Gênero, Nível de Atividade Física).
    *   Seleção de objetivo (Emagrecimento, Ganho de Massa, etc.).
    *   Definição de restrições e preferências alimentares (Vegano, Low Carb, Alergias, etc.).
    *   Armazenamento e atualização segura dos dados do perfil.
*   **Requisitos Relacionados:**
    *   **RF01:** Gestão de Perfil do Usuário
    *   **RF03:** Configuração de Filtros Alimentares
    *   **RN04:** Prioridade de Alérgenos
    *   **RN06:** Limitação de Idade (para cadastro)
*   **Casos de Uso Relacionados:**
    *   **UC01:** Cadastrar Perfil Biométrico
    *   **UC03:** Cadastrar Restrições Alimentares

### E03: Geração e Exibição de Dietas Personalizadas

Este é o épico central do DietHub, responsável por integrar a inteligência artificial para criar e apresentar planos alimentares adaptados a cada usuário.

*   **Funcionalidades Chave:**
    *   Compilação de dados do usuário para envio à IA.
    *   Comunicação com a API de Inteligência Artificial (Gemini/OpenAI).
    *   Processamento da resposta da IA (JSON estruturado).
    *   Formatação e exibição da dieta semanal na interface do usuário.
    *   Consideração de diretrizes nutricionais e restrições de segurança na geração da dieta.
    *   Regionalização de cardápios e sugestão de substituições de alimentos.
*   **Requisitos Relacionados:**
    *   **RF02:** Geração de Dieta Personalizada
    *   **RN01:** Algoritmo de Taxa Metabólica (TMB)
    *   **RN02:** Segurança de Ingestão Mínima
    *   **RN03:** Distribuição de Macros
    *   **RN07:** Estrutura de Resposta (Parsing)
    *   **RN08:** Regionalização de Cardápio
    *   **RN09:** Substituição Unitária
*   **Casos de Uso Relacionados:**
    *   **UC02:** Gerar Dieta por IA

### E04: Acompanhamento de Progresso e Hábitos

Este épico visa empoderar o usuário com ferramentas para monitorar sua adesão à dieta e seus resultados de saúde ao longo do tempo.

*   **Funcionalidades Chave:**
    *   Registro de refeições concluídas (check-in).
    *   Registro da ingestão diária de água.
    *   Cálculo e exibição da meta diária de hidratação.
    *   Registro e histórico de peso.
    *   Geração de gráficos de evolução de peso.
*   **Requisitos Relacionados:**
    *   **RF04:** Log de Refeições
    *   **RF05:** Controle de Água
    *   **RF06:** Evolução de Peso
*   **Casos de Uso Relacionados:**
    *   **UC04:** Registrar Refeição Concluída
    *   **UC05:** Registrar Ingestão de Água
    *   **UC06:** Visualizar Gráfico de Evolução de Peso

### E05: Infraestrutura e Qualidade do Sistema

Este épico engloba os aspectos técnicos e de qualidade que garantem o bom funcionamento, a segurança e a sustentabilidade do aplicativo DietHub.

*   **Funcionalidades Chave:**
    *   Garantia de performance da IA (tempo de resposta).
    *   Adesão à arquitetura Flutter (Clean Architecture).
    *   Conformidade com a LGPD para dados sensíveis.
    *   Funcionalidade offline para cardápios (cache local).
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

