# 📋 Casos de Uso - DietHub

Este documento detalha as interações principais entre o usuário e o aplicativo DietHub, focando na geração de dietas personalizadas via IA e gestão de perfil.

---

## 1. Diagrama de Casos de Uso (Simplificado)


* **Ator Principal:** Usuário Final.
* **Ator Secundário:** API de Inteligência Artificial (Gemini/OpenAI).

---

## 2. Detalhamento dos Casos de Uso

### UC01: Cadastrar Perfil Biométrico
**Descrição:** Permite que o usuário forneça os dados necessários para o cálculo nutricional.
* **Pré-condição:** Usuário estar logado no app.
* **Fluxo Principal:**
    1. O usuário acessa a tela de perfil.
    2. Insere: Peso, Altura, Idade, Gênero e Nível de Atividade Física.
    3. Seleciona o objetivo (Ex: Emagrecimento, Ganho de Massa).
    4. O sistema valida os dados e salva localmente/nuvem.
* **Pós-condição:** Perfil atualizado para uso da IA.

### UC02: Gerar Dieta por IA (Caso Crítico)
**Descrição:** O sistema utiliza os dados do perfil para solicitar uma dieta personalizada à IA.
* **Fluxo Principal:**
    1. O usuário clica em "Gerar Nova Dieta".
    2. O sistema compila os dados do UC01 e as preferências alimentares.
    3. O sistema envia um prompt estruturado para a API de IA.
    4. A IA retorna o plano alimentar.
    5. O sistema formata e exibe a dieta na tela.
* **Fluxo Alternativo (Erro de Conexão):** Se a API não responder, o sistema exibe: "Não foi possível conectar à IA. Ver
