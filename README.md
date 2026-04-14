#  DietHub: Seu Guia Nutricional Personalizado com IA

##  Visão Geral do Projeto

O **DietHub** é um aplicativo móvel inovador, desenvolvido para democratizar o acesso a planos alimentares personalizados. Utilizando o poder da Inteligência Artificial Generativa (LLMs como Gemini/OpenAI), o DietHub oferece dietas semanais sob medida, adaptadas às necessidades biométricas, objetivos e restrições alimentares de cada usuário. Nosso objetivo é fornecer um guia de bem-estar acessível para aqueles que buscam uma alimentação mais saudável, mas não possuem condições ou acesso a acompanhamentos nutricionais tradicionais.

##  Funcionalidades Principais

O DietHub oferece um conjunto robusto de funcionalidades para auxiliar o usuário em sua jornada nutricional:

*   **Autenticação Segura:** Cadastro e login de usuários com proteção de dados e autenticação via JWT.
*   **Perfil Biométrico Detalhado:** Registro de peso, altura, idade, gênero, nível de atividade física e objetivos (emagrecimento, ganho de massa, etc.).
*   **Restrições e Preferências Alimentares:** Configuração de filtros como vegano, low carb, intolerância à lactose, alergias, que são considerados pela IA.
*   **Geração de Dieta por IA:** Planos alimentares semanais personalizados, gerados por IA, com base nos dados do perfil e preferências do usuário.
*   **Acompanhamento de Refeições:** Ferramenta para marcar refeições como concluídas, auxiliando no controle da adesão à dieta.
*   **Controle de Hidratação:** Registro da ingestão de água e cálculo da meta diária para manter o usuário hidratado.
*   **Gráfico de Evolução de Peso:** Visualização do histórico de peso para acompanhar o progresso ao longo do tempo.
*   **Regionalização de Cardápio:** Sugestões de alimentos de fácil acesso na região do usuário.
*   **Substituição Inteligente de Alimentos:** Opção de trocar alimentos específicos por equivalentes nutricionais sugeridos pela IA.

##  Tecnologias Utilizadas

Este projeto foi construído com as seguintes tecnologias:

| Categoria | Tecnologia | Descrição |
|:---|:---|:---|
| **Frontend (Mobile)** | Flutter (Dart) | Framework para desenvolvimento de aplicativos móveis multiplataforma, garantindo uma interface rica e performática. |
| **Backend (API)** | Node.js (Express.js) | Ambiente de execução JavaScript para o servidor, responsável pela lógica de negócio, autenticação e comunicação com o banco de dados. |
| **Banco de Dados** | MySQL | Sistema de gerenciamento de banco de dados relacional para armazenamento de informações de usuários e perfis. |
| **Autenticação** | JWT (JSON Web Tokens) | Padrão aberto para criação de tokens de acesso que permitem a autenticação segura entre cliente e servidor. |
| **Segurança** | bcrypt.js | Biblioteca para hash de senhas, garantindo que as credenciais dos usuários sejam armazenadas de forma segura. |
| **Inteligência Artificial** | Gemini/OpenAI (LLMs) | Modelos de Linguagem Grande (Large Language Models) utilizados para a geração inteligente e personalizada de planos alimentares. |

## ⚙️ Configuração do Ambiente de Desenvolvimento

Para configurar e executar o projeto DietHub em sua máquina local, siga os passos abaixo:

### Pré-requisitos

Certifique-se de ter as seguintes ferramentas instaladas:

*   **Flutter SDK:** [Instalação do Flutter](https://flutter.dev/docs/get-started/install )
*   **Node.js e npm:** [Instalação do Node.js](https://nodejs.org/en/download/ )
*   **MySQL Server:** [Instalação do MySQL](https://dev.mysql.com/doc/refman/8.0/en/installing.html )
*   **Git:** [Instalação do Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git )

### 1. Clonar o Repositório

```bash
git clone https://github.com/seu-usuario/Projeto-PI-Grupo-07.git # Substitua pelo link do seu repositório
cd Projeto-PI-Grupo-07
