% BHAVIN MAHENDRA GULAB

:- set_prolog_flag(answer_write_options,[max_depth(0)]). % LISTAS COMPLETAS
:- ['dados.pl'], ['keywords.pl']. % FICHEIROS A IMPORTAR

/**************************** QUALIDADE DOS DADOS ****************************/

/*
eventosSemSala(EventosSemSala) eh verdade se EventosSemSala eh uma lista,
ordenada e sem IDs repetidos de eventos que nao teem sala.
*/
eventosSemSalas(EventosSemSala) :-
    findall(A, evento(A,_,_,_,semSala), EventosSemSala).

/*
eventosSemSalasDiaSemana(DiaSemana, EventosSemSala) eh verdade se 
EventosSemSala eh uma lista, ordenada e sem IDs repetidos de eventos 
que nao teem sala, num dado dia de semana especifico, DiaSemana.
*/
eventosSemSalasDiaSemana(DiaSemana, EventosSemSala) :-
    findall(A, (horario(A,DiaSemana,_,_,_,_), 
        evento(A,_,_,_,semSala)), EventosSemSala).

/*
Funcao Auxiliar.
obtemSemestre(P,S) eh verdade se S eh o semestre correspondente ao periodo P.
*/
obtemSemestre(P,S) :-
    P == p1, S = p1_2;
    P == p2, S = p1_2;
    P == p3, S = p3_4;
    P == p4, S = p3_4;
    P == p1_2, S = p1_2;
    P == p3_4, S = p3_4.

/*
eventosSemSalasPeriodo(ListaPeriodos, EventosSemSala) eh verdade se 
EventosSemSala for uma lista, ordenada e sem IDs repetidos de eventos 
que nao teem sala em certos periodos dados pela listA ListaPeriodos.
*/
eventosSemSalasPeriodo([],[]). % CASO TERMINAL
eventosSemSalasPeriodo([P|Q], EventosSemSala) :-
    obtemSemestre(P,S), 
    findall(A, (horario(A,_,_,_,_,S), evento(A,_,_,_,semSala)), SemSalaS),
    findall(A, (horario(A,_,_,_,_,P), evento(A,_,_,_,semSala)), SemSalaP),
    append(SemSalaS,SemSalaP,SemSala), 
    append(SemSala,EventosSemSalaAux,EventosSemSalaInicial), 
    eventosSemSalasPeriodo(Q, EventosSemSalaAux), 
    sort(EventosSemSalaInicial, EventosSemSala).

/************************* FIM - QUALIDADE DOS DADOS *************************/

/****************************** PESQUISA SIMPLES *****************************/

/*
organizaEventos(ListaEventos, Periodo, EventosNoPeriodo) eh verdade se 
EventosNoPeriodo for uma lista, ordenada e sem IDs repetidos dos eventos
da lista ListaEventos que decorrem durante o periodo Periodo.
*/
organizaEventos([],_,[]). % CASO TERMINAL
organizaEventos([P|Q], Periodo, EventosNoPeriodo) :-
    obtemSemestre(Periodo, Semestre), horario(P,_,_,_,_, Semestre), 
    EventosNoPeriodo = [P|EventosNoPeriodoAux], 
    organizaEventos(Q, Periodo, EventosNoPeriodoAux);
    horario(P,_,_,_,_, Periodo), EventosNoPeriodo = [P|EventosNoPeriodoAux], 
    organizaEventos(Q, Periodo, EventosNoPeriodoAux);
    organizaEventos(Q, Periodo, Temp), sort(Temp, EventosNoPeriodo).

/*
eventosMenoresQue(Duracao, ListaEventosMenoresQue) eh verdade se 
ListaEventosMenoresQue for uma lista, ordenada e sem IDs repetidos
de eventos cuja a duracao seja inferior ou igual a Duracao.
*/
eventosMenoresQue(Duracao, ListaEventosMenoresQue) :-
    findall(A, (horario(A,_,_,_,B,_), B =< Duracao), ListaEventosMenoresQue).

/*
eventosMenoresQueBool(ID, Duracao) eh verdade se o evento ID tiver duracao
Duracao.
*/
eventosMenoresQueBool(A, Duracao) :-
    horario(A,_,_,_,B,_), B =< Duracao.

/*
procuraDisciplinas(Curso, ListaDisciplinas) eh verdade se ListaDisciplinas
for uma lista, ordenadas e sem elementos repetidos de disciplinas do curso
Curso.
*/
procuraDisciplinas(Curso, ListaDisciplinas) :-
    findall(A, (evento(B,A,_,_,_), turno(B,Curso,_,_)), ListaDisciplinasAux),
    sort(ListaDisciplinasAux, ListaDisciplinas).

% Funcao Auxiliar. semestre1(S1) eh verdade se S1 for o primeiro semestre.
semestre1(S1) :- S1 = p1_2. 
% Funcao Auxiliar. semestre2(S2) eh verdade se S2 for o segundo semestre.
semestre2(S2) :- S2 = p3_4.

/*
Funcao Auxiliar.
organizaX(ListaDisciplinas, Curso, X) eh verdade se X for uma lista,
ordenada e sem elementos repetidos de disciplinas que decorrem durante
o primeiro semestre da lista ListaDisciplinas e do curso Curso.
*/
organizaX([],_,[]). % CASO TERMINAL
organizaX([P|Q], Curso, X) :-
    semestre1(S1),
    turno(A,Curso,_,_), evento(A,P,_,_,_), horario(A,_,_,_,_,B), 
    obtemSemestre(B,S), 
    (S == S1, X = [P|XAux], organizaX(Q,Curso,XAux); organizaX(Q,Curso,X)).

/*
Funcao Auxiliar.
organizaY(ListaDisciplinas, Curso, Y) eh verdade se Y for uma lista,
ordenada e sem elementos repetidos de disciplinas que decorrem durante
o segundo semestre da lista ListaDisciplinas e do curso Curso.
*/
organizaY([],_,[]). % CASO TERMINAL
organizaY([P|Q], Curso, Y) :-
    semestre2(S2),
    turno(A,Curso,_,_), evento(A,P,_,_,_), horario(A,_,_,_,_,B), 
    obtemSemestre(B,S), 
    (S == S2, Y = [P|YAux], organizaY(Q,Curso,YAux); organizaY(Q,Curso,Y)).

/*
organizaDisciplinas(ListaDisciplinas, Curso, Semestres) eh verdade se 
Semestres eh uma lista de dois elementos, onde o primeiro elemento 
contem as disciplinas que decorrem durante o primeiro semestre e o 
segundo elemento contem as disciplinas que decorrem durante o 
primeiro semestre.
Ambos os elementos encontram-se ordenados alfabetimente, sem elementos
repetidos.
*/
organizaDisciplinas(ListaDisciplinas, Curso, [SemestresAux1, SemestresAux2]) :-
    organizaX(ListaDisciplinas, Curso, SemestresAux1),
    organizaY(ListaDisciplinas, Curso, SemestresAux2).

/*
Funcao Auxiliar.
obtemSoma1(TotalHoras, Soma) eh verdade se Soma for a soma de todos os D, tal que
Lista = [[_,D]|R], onde R eh o resto da lista Lista.
*/
obtemSoma1([], 0). % CASO TERMINAL
obtemSoma1([P|Q], Soma) :-
    P = [_,S],
    obtemSoma1(Q, SomaAux), Soma is (S + SomaAux).

/*
horasCurso(Periodo, Curso, Ano, TotalHoras) eh verdade  se TotalHoras for o numero
total de horas dos eventos do ano Ano, periodo Periodo e curso Curso.
*/
horasCurso(Periodo, Curso, Ano, TotalHoras) :-
    obtemSemestre(Periodo, Semestre), 
    findall([A,B], (horario(A,_,_,_,B,Semestre), 
        turno(A,Curso,Ano,_)), TotalHorasAux1),
    findall([C,D], (horario(C,_,_,_,D,Periodo), 
        turno(C,Curso,Ano,_)), TotalHorasAux2),
    append(TotalHorasAux1, TotalHorasAux2, TotalHorasAuxAll),
    sort(TotalHorasAuxAll, TotalHorasAux),
    obtemSoma1(TotalHorasAux, TotalHoras).

/*
Funcao Auxiliar.
obtemAnoPeriodoX(AnoPeriodo) eh verdade se AnoPeriodo for uma lista cujos elementos
sao listas com um ano e um periodo.
*/
obtemAnoPeriodoX(AnoPeriodo) :-
    AnoPeriodo = [[1,p1],[1,p2],[1,p3],[1,p4],
        [2,p1],[2,p2],[2,p3],[2,p4],
        [3,p1],[3,p2],[3,p3],[3,p4]].

/*
Funcao Auxiliar.
obtemAnoPeriodoY(Curso, AnoPeriodo, Evolucao) eh verdade Evolucao for uma lista de
tuplos na forma (Ano, Periodo, NumHoras), ordenadas por ano e por Periodo, tal que 
AnoPeriodo = [Ano, Periodo] e NumHoras eh o numero total de horas associadas ao 
curso Curso, no ano Ano e no periodo Periodo.
*/
obtemAnoPeriodoY(_,[],[]). % CASO TERMINAL
obtemAnoPeriodoY(Curso, [P|Q], Evolucao) :-
    P = [A,B],
    horasCurso(B,Curso,A,TotalHoras),
    Evolucao = [(A, B, TotalHoras)|EvolucaoAux], 
    obtemAnoPeriodoY(Curso, Q, EvolucaoAux).

/*
evolucaoHorasCurso(Curso, Evolucao) eh verdade Evolucao for uma lista de tuplos 
obtidos por obtemAnoPeriodoY(Curso, AnoPeriodo, Evolucao), onde AnoPeriodo eh
obtido por obtemAnoPeriodoX(AnoPeriodo).
*/
evolucaoHorasCurso(Curso, Evolucao) :-
    obtemAnoPeriodoX(EvolucaoAux),
    obtemAnoPeriodoY(Curso, EvolucaoAux, Evolucao).

/*************************** FIM - PESQUISA SIMPLES **************************/



/************************ OCUPACOES CRITICAS DE SALAS ************************/

/*
ocupaSlot(HID, HFD, HIE, HFE, Horas) eh verdade se Horas for o numero de horas
sobrepostas entre o evento que tem inicio em HIE e fim em HFE e o slot que tem
inicio em HID e fim em HFD. Caso nao haja sobreposicao, o predicado falha.
*/
ocupaSlot(HID, HFD, HIE, HFE, Horas) :-
    HIE >= HID, HFE =< HFD, Horas is (HFE-HIE);
    HIE =< HID, HFE >= HFD, Horas is (HFD-HID);
    HIE < HID, HFE < HFD, HIE < HFD, HFE > HID, Horas is (HFE-HID);
    HIE > HID, HFE > HFD, HIE < HFD, HFE > HID, Horas is (HFD-HIE).

/*
Funcao Auxliar.
obtemSoma2(HI, HF, Lista, Soma) eh verdade se Soma corresponde ah soma das
horas sobrepostas entre o evento que decorre entre X e Y, e HI e Hf, tal que
Lista = [[X,Y]|R], onde R eh o resto da lista.
*/
obtemSoma2(_,_,[],0) :- !. % CASO TERMINAL
obtemSoma2(HI, HF, [P|Q], Soma) :-
    P = [I,F], I >= HI, F =< HF, !, 
    obtemSoma2(HI, HF, Q, SomaAux), Soma is ((F-I) + SomaAux).
obtemSoma2(HI, HF, [P|Q], Soma) :-
    P = [I,F], I =< HI, F >= HF, !, 
    obtemSoma2(HI, HF, Q, SomaAux), Soma is ((HF-HI) + SomaAux).
obtemSoma2(HI, HF, [P|Q], Soma) :-
    P = [I,F], I < HI, F < HF, I < HF, F > HI, !, 
    obtemSoma2(HI, HF, Q, SomaAux), Soma is ((F-HI) + SomaAux).
obtemSoma2(HI, HF, [P|Q], Soma) :-
    P = [I,F], I > HI, F > HF, I < HF, F > HI, !, 
    obtemSoma2(HI, HF, Q, SomaAux), Soma is ((HF-I) + SomaAux).
obtemSoma2(HI, HF, [_|Q], Soma) :- obtemSoma2(HI, HF, Q, Soma).

/*
numHorasOcupadas(Periodo, TipoSala, DiaSemana, HI, HF, SomaHoras) eh verdade
se SomaHoras for o numero total de horas ocupadas nas salas do tipo TipoSala,
no periodo Periodo, no dia de semana DiaSemana e entre as horas HI e HF.
*/
numHorasOcupadas(Periodo, TipoSala, DiaSemana, HI, HF, SomaHoras) :-
    obtemSemestre(Periodo, Semestre), 
    findall([B,C], (salas(TipoSala,SalaLista), evento(A,_,_,_,Sala), 
        horario(A,DiaSemana,B,C,H,Semestre), member(Sala, SalaLista)), SomaHorasAux1),
    findall([B,C], (salas(TipoSala,SalaLista), evento(A,_,_,_,Sala), 
        horario(A,DiaSemana,B,C,H,Periodo), member(Sala, SalaLista)), SomaHorasAux2),
    append(SomaHorasAux1, SomaHorasAux2, SomaHorasAux),
    obtemSoma2(HI, HF, SomaHorasAux, SomaHoras).

/*
ocupacaoMax(TipoSala, HI, HF, Max) eh verdade se Max for o numero maximo de
horas que podem ser ocupadas por salas do tipo TipoSala e entre HI e HF.
*/
ocupacaoMax(TipoSala, HI, HF, Max) :-
    findall(Sala, (salas(TipoSala,SalaLista), evento(A,_,_,_,Sala), 
        horario(A,_,_,_,_,_), member(Sala, SalaLista)), MaxAux),
    sort(MaxAux, MaxAuxReduzida),
    length(MaxAuxReduzida, A),
    Max is (A*(HF-HI)).

/*
percentagem(SomaHoras, Max, Percentagem) se percentagem for o quociente entre
SomaHoras e Max, multiplicado por 100.
*/
percentagem(SomaHoras, Max, Percentagem) :-
    (SomaHoras/Max) =< 1, Percentagem is ((SomaHoras/Max)*100);
    (SomaHoras/Max) > 1, Percentagem is 100.

/*
ocupacaoCritica(HI, HF, Threshold, Resultados) eh verdade se Resultados for uma 
lista, ordenada e sem elementos repetidos de tuplos do tipo 
casosCriticos(DiaSemana, TipoSala, Percentagem), onde DiaSemana corresponde ao
dia da semana, TipoSala ao tipo da sala e Percentagem ah percentagem de ocupacao
arredondada ao proximo valor inteiro, entre as horas HI e HF, sendo Percentagem 
superior a Threshold.
*/
ocupacaoCritica(HI, HF, Threshold, Resultados) :-
    findall(casosCriticos(DiaSemana, TipoSala, PercentagemReduzida), 
        (evento(A,_,_,_,Sala), horario(A,DiaSemana,_,_,_,Periodo), 
        salas(TipoSala, SalaLista), member(Sala,SalaLista), 
        numHorasOcupadas(Periodo, TipoSala, DiaSemana, HI, HF, SomaHoras), 
        ocupacaoMax(TipoSala, HI, HF, Max),
        percentagem(SomaHoras, Max, Percentagem), Percentagem > Threshold, 
        ceiling(Percentagem, PercentagemReduzida)), ResultadosAll),
    sort(ResultadosAll, Resultados).

/********************* FIM - OCUPACOES CRITICAS DE SALAS *********************/



/**************************** OCUPACAO DE UMA MESA ***************************/

/*
Predicados possiveis de restricao,
 - cab1(Mesa, X) eh verdade se X for a pessoa que se encontra na cabeceira 1 
   da mesa Mesa.
 - cab2(Mesa, X) eh verdade se X for a pessoa que se encontra na cabeceira 2 
   da mesa Mesa.
 - honra(Mesa, X, Y) eh verdade se X estiver numa das cabeceiras da mesa Mesa 
   e Y estiver ah sua direita.
 - lado(Mesa, X, Y) eh verdade se X e Y estiverem lado a lado na mesa Mesa.
 - naoLado(Mesa, X, Y) eh verdade se X e Y nao estiverem lado a lado na mesa Mesa.
 - frente(Mesa, X, Y) eh verdade se X e Y estiverem frente a frente na mesa Mesa.
 - naoFrente(Mesa, X, Y) eh verdade se X e Y nao estiverem frente a frente na 
   mesa Mesa.
*/

cab1([_,_,_,A,_,_,_,_],A). cab2([_,_,_,_,B,_,_,_],B). 
honra([_,_,B,A,_,_,_,_],A,B). honra([_,_,_,_,A,B,_,_],A,B).
lado([A,B,_,_,_,_,_,_],A,B). lado([_,_,_,_,_,A,B,_],A,B). 
lado([_,A,B,_,_,_,_,_],A,B). lado([_,_,_,_,_,_,A,B],A,B).
lado([A,B,_,_,_,_,_,_],B,A). lado([_,_,_,_,_,A,B,_],B,A). 
lado([_,A,B,_,_,_,_,_],B,A). lado([_,_,_,_,_,_,A,B],B,A).
naoLado([A,_,B,_,_,_,_,_],A,B). naoLado([A,_,_,B,_,_,_,_],A,B). 
naoLado([A,_,_,_,B,_,_,_],A,B). naoLado([A,_,_,_,_,B,_,_],A,B). 
naoLado([A,_,_,_,_,_,B,_],A,B). naoLado([A,_,_,_,_,_,_,B],A,B). 
naoLado([_,A,_,B,_,_,_,_],A,B). naoLado([_,A,_,_,B,_,_,_],A,B). 
naoLado([_,A,_,_,_,B,_,_],A,B). naoLado([_,A,_,_,_,_,B,_],A,B). 
naoLado([_,A,_,_,_,_,_,B],A,B). naoLado([_,_,A,_,B,_,_,_],A,B). 
naoLado([_,_,A,_,_,B,_,_],A,B). naoLado([_,_,A,_,_,_,B,_],A,B). 
naoLado([_,_,A,_,_,_,_,B],A,B). naoLado([_,_,_,A,_,B,_,_],A,B). 
naoLado([_,_,_,A,_,_,B,_],A,B). naoLado([_,_,_,A,_,_,_,B],A,B). 
naoLado([_,_,_,_,A,_,B,_],A,B). naoLado([_,_,_,_,A,_,_,B],A,B). 
naoLado([_,_,_,_,_,A,_,B],A,B). naoLado([_,_,_,A,B,_,_,_],A,B).
naoLado([A,_,B,_,_,_,_,_],B,A). naoLado([A,_,_,B,_,_,_,_],B,A). 
naoLado([A,_,_,_,B,_,_,_],B,A). naoLado([A,_,_,_,_,B,_,_],B,A). 
naoLado([A,_,_,_,_,_,B,_],B,A). naoLado([A,_,_,_,_,_,_,B],B,A). 
naoLado([_,A,_,B,_,_,_,_],B,A). naoLado([_,A,_,_,B,_,_,_],B,A). 
naoLado([_,A,_,_,_,B,_,_],B,A). naoLado([_,A,_,_,_,_,B,_],B,A). 
naoLado([_,A,_,_,_,_,_,B],B,A). naoLado([_,_,A,_,B,_,_,_],B,A). 
naoLado([_,_,A,_,_,B,_,_],B,A). naoLado([_,_,A,_,_,_,B,_],B,A). 
naoLado([_,_,A,_,_,_,_,B],B,A). naoLado([_,_,_,A,_,B,_,_],B,A). 
naoLado([_,_,_,A,_,_,B,_],B,A). naoLado([_,_,_,A,_,_,_,B],B,A). 
naoLado([_,_,_,_,A,_,B,_],B,A). naoLado([_,_,_,_,A,_,_,B],B,A). 
naoLado([_,_,_,_,_,A,_,B],B,A). naoLado([_,_,_,A,B,_,_,_],B,A).
frente([_,_,_,A,B,_,_,_],A,B). frente([A,_,_,_,_,B,_,_],A,B). 
frente([_,A,_,_,_,_,B,_],A,B). frente([_,_,A,_,_,_,_,B],A,B).
frente([_,_,_,A,B,_,_,_],B,A). frente([A,_,_,_,_,B,_,_],B,A). 
frente([_,A,_,_,_,_,B,_],B,A). frente([_,_,A,_,_,_,_,B],B,A).
naoFrente([A,B,_,_,_,_,_,_],A,B). naoFrente([A,_,B,_,_,_,_,_],A,B). 
naoFrente([A,_,_,B,_,_,_,_],A,B). naoFrente([A,_,_,_,B,_,_,_],A,B). 
naoFrente([A,_,_,_,_,_,B,_],A,B). naoFrente([A,_,_,_,_,_,_,B],A,B). 
naoFrente([_,A,B,_,_,_,_,_],A,B). naoFrente([_,A,_,B,_,_,_,_],A,B). 
naoFrente([_,A,_,_,B,_,_,_],A,B). naoFrente([_,A,_,_,_,B,_,_],A,B). 
naoFrente([_,A,_,_,_,_,_,B],A,B). naoFrente([_,_,A,B,_,_,_,_],A,B). 
naoFrente([_,_,A,_,B,_,_,_],A,B). naoFrente([_,_,A,_,_,B,_,_],A,B). 
naoFrente([_,_,A,_,_,_,B,_],A,B). naoFrente([_,_,_,A,_,B,_,_],A,B). 
naoFrente([_,_,_,A,_,_,B,_],A,B). naoFrente([_,_,_,A,_,_,_,B],A,B). 
naoFrente([_,_,_,_,A,B,_,_],A,B). naoFrente([_,_,_,_,A,_,B,_],A,B). 
naoFrente([_,_,_,_,A,_,_,B],A,B). naoFrente([_,_,_,_,_,A,B,_],A,B). 
naoFrente([_,_,_,_,_,A,_,B],A,B). naoFrente([_,_,_,_,_,_,A,B],A,B). 
naoFrente([A,B,_,_,_,_,_,_],B,A). naoFrente([A,_,B,_,_,_,_,_],B,A). 
naoFrente([A,_,_,B,_,_,_,_],B,A). naoFrente([A,_,_,_,B,_,_,_],B,A). 
naoFrente([A,_,_,_,_,_,B,_],B,A). naoFrente([A,_,_,_,_,_,_,B],B,A). 
naoFrente([_,A,B,_,_,_,_,_],B,A). naoFrente([_,A,_,B,_,_,_,_],B,A). 
naoFrente([_,A,_,_,B,_,_,_],B,A). naoFrente([_,A,_,_,_,B,_,_],B,A). 
naoFrente([_,A,_,_,_,_,_,B],B,A). naoFrente([_,_,A,B,_,_,_,_],B,A). 
naoFrente([_,_,A,_,B,_,_,_],B,A). naoFrente([_,_,A,_,_,B,_,_],B,A). 
naoFrente([_,_,A,_,_,_,B,_],B,A). naoFrente([_,_,_,A,_,B,_,_],B,A). 
naoFrente([_,_,_,A,_,_,B,_],B,A). naoFrente([_,_,_,A,_,_,_,B],B,A). 
naoFrente([_,_,_,_,A,B,_,_],B,A). naoFrente([_,_,_,_,A,_,B,_],B,A). 
naoFrente([_,_,_,_,A,_,_,B],B,A). naoFrente([_,_,_,_,_,A,B,_],B,A). 
naoFrente([_,_,_,_,_,A,_,B],B,A). naoFrente([_,_,_,_,_,_,A,B],B,A).

/*
ocupacaoMesaAux(ListaRestricoes, MesaReduzida) eh verdade se MesaReduzida for
uma lista com os lugares correspondentes ahs restricoes da lista 
ListaRestricoes.
*/
ocupacaoMesaAux([],_). % CASO TERMINAL
ocupacaoMesaAux([P|Q], [S,T,U,V,W,X,Y,Z]) :-
    P =.. [F|Arg], 
    append([[S,T,U,V,W,X,Y,Z]], Arg, NovoArg),
    NovoP =.. [F|NovoArg], NovoP, 
    ocupacaoMesaAux(Q, [S,T,U,V,W,X,Y,Z]).

/*
falta(ListaPessoas, ListaReduzida, PessoaFalta) eh verdade se Falta for
o elemento que pertence a ListaCompleta e nao a ListaReduzida.
*/
falta([],_,[]). % CASO TERMINAL
falta([P|Q], ListaReduzida, Falta) :-
    member(P, ListaReduzida), falta(Q, ListaReduzida, Falta);
    Falta = [P|FaltaAux], falta(Q, ListaReduzida, FaltaAux).

/*
adicionaFalta(Lista, Elemento, ListaFinal) eh verdade se ListaFinal for
a lista Lista com o elemento Elemento.
*/
adicionaFalta([A,B,C,D,E,F,G,H], [P], [A,B,C,D,E,F,G,H]) :-
    A = P; B = P; C = P; D = P; E = P; F = P; G = P; H = P.

/*
ocupacaoMesa(ListaPessoas, ListaRestricoes, OcupacaoMesa) eh verdade se
OcupacaoMesa for uma lista de 3 listas, de acordo com as restricoes 
contidas em ListaRestricoes, onde a primeira e a terceira conteem as 3 
pessoas sentadas lado a lado e a segunda as pessoas que se encontram 
em cada uma das cabeceiras. Para alem disso, ListaPessoas eh a lista 
de pessoas a sentar na mesa.
*/
ocupacaoMesa(ListaPessoas, ListaRestricoes, OcupacaoMesa) :-
    ocupacaoMesaAux(ListaRestricoes, ListaReduzida),
    falta(ListaPessoas, ListaReduzida, Pessoa),
    adicionaFalta(ListaReduzida, Pessoa, [A,B,C,D,E,F,G,H]),
    OcupacaoMesa = [[H,G,F],[D,E],[C,B,A]].

/************************* FIM - OCUPACAO DE UMA MESA ************************/