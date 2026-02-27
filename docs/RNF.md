Título: [RNF-001]

Descrição:

A interface do aplicativo deve manter uma taxa de atualização estável para garantir fluidez, e as chamadas de API não devem bloquear a thread principal.

Critérios de Aceite:

[ ] O aplicativo deve rodar a 60 FPS (ou 120 FPS em telas compatíveis) sem quedas bruscas de frames (jank).

[ ] O estado da aplicação deve ser gerenciado de forma reativa (Bloc, Riverpod ou Provider).

[ ] O tamanho do APK final em modo release não deve ultrapassar 25MB (considerando compressão de assets).
