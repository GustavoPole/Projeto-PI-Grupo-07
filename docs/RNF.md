Título: [RNF-001] Persistência Local e Sincronização em Background

Descrição:

Como o controle da dieta é diário, o usuário deve conseguir visualizar seu plano e marcar refeições como "concluídas" mesmo sem internet (Offline First).

Critérios de Aceite:

[ ] Utilizar SQLite (sqflite) ou Isar para armazenar o plano alimentar localmente no dispositivo.

[ ] Implementar sincronização em background: quando a conexão voltar, o progresso do usuário deve ser enviado ao servidor/Firebase.

[ ] Garantir que o consumo de bateria seja otimizado, evitando chamadas repetitivas de IA para dados que já foram gerados.
