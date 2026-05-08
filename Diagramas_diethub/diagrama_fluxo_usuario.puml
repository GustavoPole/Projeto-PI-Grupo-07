@startuml
title Fluxo Principal do Usuário - DietHub

start

:Abrir Aplicativo;

if (Usuário tem conta?) then (Não)
    :Realizar Cadastro;
    :Validar Dados;
else (Sim)
endif

:Realizar Login;

if (Perfil Biométrico preenchido?) then (Não)
    :Cadastrar Dados Biométricos\n(Peso, Altura, Idade, Objetivo);
    :Salvar Perfil;
else (Sim)
endif

:Acessar Tela Inicial;

if (Deseja nova dieta?) then (Sim)
    :Solicitar Geração de Dieta por IA;
    :IA processa perfil e preferências;
    :Exibir Plano Alimentar;
else (Não)
    :Visualizar Dieta Atual;
endif

repeat
    :Registrar Atividade Diária;
    split
        :Marcar Refeição Concluída;
    split again
        :Registrar Ingestão de Água;
    split again
        :Visualizar Gráfico de Evolução;
    end split
repeat while (Dia continua?) is (Sim)

stop
@enduml
