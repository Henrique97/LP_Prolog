/* |-----------------------------------------|
   |	Henrique Almeida 84725				 |
   |	Tomas Oliveira   84773				 |
   |-----------------------------------------|*/
/*---------------------------------------Movs Possiveis-------------------------------*/
/*A funcao chama 3 funcoes auxiliares ate chegar ao movs possiveis de efetuar.
A funcao recebe um labirinto(Lab),uma posicao(Pos_atual) e os movs ja realizados.*/
movs_possiveis(Lab, Pos_atual, Movs, Poss):- calculamuros(Lab,Pos_atual,DirPossiveis),
	mov_todas_posicoes(DirPossiveis,Pos_atual,MovsPossiveis),sub(MovsPossiveis,Movs,Poss),!.
/*A funcao recebe um labirinto e uma posicao e retorna na posicao Res as direcoes possiveis para
uma movimentacao*/
calculamuros(Lab1,(PosatualX,PosatualY),Res):-
    nth1(PosatualX, Lab1, Linha),nth1(PosatualY,Linha, Elem), subtract([c,b,e,d], Elem, Res).
/*A funcao recebe a posicao atual e as possiveis direcoes para os movimentos e retorna as coordenadas dos movimentos possiveis*/
/*Adiciona um parametro auxiliar para armazenar as movimentos ja calculados*/
mov_todas_posicoes([X|Xs],(Pos_atualX,Pos_atualY),Possiveis):-mov_todas_posicoes([X|Xs],(Pos_atualX,Pos_atualY),Possiveis,[]).
/*caso final:todos as direcoes foram analisadas e transfere-se os movimentos calculados da var auxiliar para Possiveis*/
mov_todas_posicoes([],(_,_),Poss_Aux,Poss_Aux).
mov_todas_posicoes([X|Xs],(Pos_atualX,Pos_atualY),Possiveis,Poss_Aux):- 
    move_posicao((Pos_atualX,Pos_atualY),X,Respos),
    append(Poss_Aux,[Respos],Newlist),
    mov_todas_posicoes(Xs,(Pos_atualX,Pos_atualY),Possiveis, Newlist).

move_posicao((Pos_atualX,Pos_atualY),Dir,(Dir,Pos_finalX,Pos_finalY)):- Dir == c, Pos_finalX is Pos_atualX -1, Pos_finalY is Pos_atualY ;
																		Dir == b, Pos_finalX is Pos_atualX +1, Pos_finalY is Pos_atualY ;
																		Dir == d, Pos_finalX is Pos_atualX, Pos_finalY is Pos_atualY + 1;
																		Dir == e, Pos_finalX is Pos_atualX, Pos_finalY is Pos_atualY - 1.
/*A funcao recebe a lista de movs possiveis e elimina as posicoes pelas quais ja passou*/
sub(MovsPossiveis,[],MovsPossiveis).
sub(MovsPossiveis,[(_,X,Y)|Xs],Res):- delete(MovsPossiveis,(_,X,Y),ListaFinal),sub(ListaFinal,Xs,Res).

/*A funcao recebe dois pontos e retorna na posicao dist a distancia entre os dois pontos*/
distancia((L1, C1),(L2, C2),Dist):- Dist is abs(L1-L2)+ abs(C1-C2).

/*--------------------Funcao Resolve--------------------
Resolve1:resolve um labirinto e devolve a solucao tendo em conta a ordem cima,baixo,esquerda,direita 
Esta funcao chama-se recursivamente ate que a posicao dada como inicial seja igual ah final */

/*A funcao analisa o caso final em que se coloca na posicao Movs os movimentos realizados, armazenados na posicao MovsAux*/
resolve1(_,_,_,MovsAux,f,MovsAux).
/*caso se tenha chegado ao final do labirinto, adicionar ultimo movimento ah lista MovsAux*/
resolve1(Lab1,(Pos_inicialX,Pos_inicialY),(Pos_finalX,Pos_finalY),Movs,Dir,MovsAux):- Pos_finalX =:= Pos_inicialX,Pos_finalY =:= Pos_inicialY, 
												append(MovsAux,[(Dir,Pos_inicialX,Pos_inicialY)],MovsAux1), 
												resolve1(Lab1,(Pos_inicialX,Pos_inicialY),
												(Pos_finalX,Pos_finalY),Movs,f,MovsAux1).
/*caso geral: chamada recursiva em que se procura um caminho possivel ate a posicao final atraves da analise dos movs possiveis em cada posicao*/
resolve1(Lab1,Pos_inicial,(Pos_finalX,Pos_finalY),Movs,Dir,MovsAux):- movs_possiveis(Lab1,Pos_inicial,MovsAux,Poss),
												member((Dir1,Pos_seguinteX,Pos_seguinteY),Poss),	
												append(MovsAux,[(Dir,Pos_inicial)],MovsAux1), 
												resolve1(Lab1,(Pos_seguinteX,Pos_seguinteY),(Pos_finalX,Pos_finalY),Movs,Dir1,MovsAux1).
/*funcao inicial que cria um resolve1 com dois argumentos auxiliares (direcao, MovsAux(iniciado a []))*/
resolve1(Lab1,Pos_inicial,Pos_final,Movs):-		resolve1(Lab1,Pos_inicial,Pos_final,Movs,i,[]),!.
/*Resolve2:resolve um labirinto e devolve a solucao tendo em as distancias das casas ah posicao final e inicial.
Esta funcao e semelhante ah resolve1 mas os movs possiveis sao ordenados antes de serem tomados em conta para a escolha de um caminho.*/
resolve2(_,_,_,MovsAux,f,MovsAux).
resolve2(Lab1,(PosX,PosY),(Pos_finalX,Pos_finalY),Movs,Dir,MovsAux,_):- Pos_finalX =:= PosX,Pos_finalY =:= PosY, 
												append(MovsAux,[(Dir,PosX,PosY)],MovsAux1), 
												resolve2(Lab1,(PosX,PosY),
												(Pos_finalX,Pos_finalY),Movs,f,MovsAux1).
/*alteracao: no caso geral os caminhos possiveis sao analisados tendo em conta a distancia das posicoes que o
constituem ah posicao final e posicao inicial, caso isto falhe e seguida a ordem de resolve1.*/
resolve2(Lab1,Pos,(Pos_finalX,Pos_finalY),Movs,Dir,MovsAux,Pos_inicial):- movs_possiveis(Lab1,Pos,MovsAux,Poss),
												ordena_poss(Poss,Poss_ord,Pos_inicial,(Pos_finalX,Pos_finalY)),	
												member((Dir1,Pos_seguinteX,Pos_seguinteY),Poss_ord),
												append(MovsAux,[(Dir,Pos)],MovsAux1), 
												resolve2(Lab1,(Pos_seguinteX,Pos_seguinteY),(Pos_finalX,Pos_finalY),Movs,Dir1,MovsAux1,Pos_inicial).
resolve2(Lab1,Pos_inicial,Pos_final,Movs):-		resolve2(Lab1,Pos_inicial,Pos_final,Movs,i,[],Pos_inicial),!.

/* --------------------------------------------------ordena_poss-------------------------------------
   Recebe a lista de movimentos possiveis previamente calculados e ordena de acordo com a distancia final e inicial.*/
ordena_poss([(X3,X1,X2)|Xs], Poss_ord, (I1,I2),(F1,F2)):- 
	/*cria uma lista de distancias ah posicao inicial e calcula o simetrico de todos os elementos dessa lista pois estes elementos irao ser 
	ordenados do maior para o mais pequeno*/
    map_distancia([(_,X1,X2)|Xs], [Y|Ys], (I1,I2)), sim([Y|Ys],U), 
    map_distancia([(_,X1,X2)|Xs], [H|Hs], (F1,F2)),
    cria_chave([H|Hs],U,Md),
    pairs_keys_values(M, Md, [(X3,X1,X2)|Xs]),
	/*ordena as posicoes segundo a ordem [Pos_final,Pos_inicial]*/
    keysort(M, Poss_ord1), pairs_values(Poss_ord1, Poss_ord).

/*  map_distancia(Lista_original,Lista_distancias,Ponto)
	Aplica a funcao distancia a cada elemento de uma lista de posicoes*/
map_distancia([],[],_).
map_distancia([(_,X1,X2)|Xs],[Y|Ys],(L, C)):-
    distancia((X1,X2),(L, C), Y),
    map_distancia(Xs,Ys,(L, C)).

/*	cria_chave(Lista1,Lista2,ChavesL1L2)
	Cria chaves do tipo [a,b]*/
cria_chave([X|Xs],[Y|Ys],M):-cria_chave([X|Xs],[Y|Ys],M,[]).
cria_chave([],[],Maux,Maux).
cria_chave([X|Xs],[Y|Ys],M,Maux):- append(Maux,[[X,Y]],Maux1), cria_chave(Xs,Ys,M,Maux1).

/*Transforma os inteiros de uma lista de inteiros no seu simetrico.*/
sim([],[]).
sim([X|Xs],[Y|Ys]):- Y is X*(-1), sim(Xs,Ys).