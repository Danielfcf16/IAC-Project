; *********************************************************************
; Participantes
; 
; Diogo Fonseca - 99065
; Daniel Fernandes - 99063
; Francisco Sanchez - 99071
;
; **********************************************************************
; * Constantes
; **********************************************************************

DISPLAYS   EQU 0A000H  ; endereço dos displays de 7 segmentos (periférico POUT-1)
TEC_LIN    EQU 0C000H  ; endereço das linhas do teclado (periférico POUT-2)
TEC_COL    EQU 0E000H  ; endereço das colunas do teclado (periférico PIN)
LINHA      EQU 1       ; linha a testar 

FALSE EQU 0
TRUE  EQU 0FFFFH

DEFINE_LINHA           EQU 600AH      ; endereço do comando para definir a linha
DEFINE_COLUNA          EQU 600CH      ; endereço do comando para definir a coluna
DEFINE_PIXEL           EQU 6012H      

LIMITE_OVNI			   		 EQU  27						;	Limite inferior do ovni (nave inimiga ou meteoro) ao descer o ecrã 
LINHA_TRANFORMACAO    		 EQU  7							;	linha de transformacao do ovni em nave inimiga ou  meteoro						
LINHA_ANTES_TRANSFORMACAO 	 EQU  6							;	linha antes da linha de transformacao do ovni em nave inimiga ou  meteoro	
LIMITE_NAVE_DIREITA    		 EQU  59						;	limite horizontal da nave do lado direito
LIMITE_NAVE_ESQUERDA  		 EQU  0							;	limite horizontal da nave do lado esquerdo
LIMITE_MISSIL		   		 EQU  16						;	distancia ate qual o missil viaja
COR_NAVE               		 EQU  0FFF0H					
COR_TRANSPARENTE 	   		 EQU  0H
COR_MISSIL			   		 EQU  0F2EFH
LINHA_MISSIL           		 EQU  24						;	linha onde o missil nasce
LINHA_OVNI 			   		 EQU  1							;	linha onde nasce o ovni (nave inimiga ou meteoro)
COLUNA_OVNI    	  	   		 EQU  31						;	coluna onde nasce o ovni (nave inimiga ou meteoro)
COR_COISA			   		 EQU  7000H						;	cor referente ao ovni ainda distante 
COR_NAVE_INIMIGA			 EQU  0FF00H
COR_METEORO			   		 EQU  0F851H
COR_EXPLOSAO          		 EQU  0FFA0H

ENERGIA_INICIAL 			 EQU  100
ENERGIA_ATUAL				 EQU  100

OVNI_BOM  			   EQU  1
OVNI_MAU  			   EQU  0

DIRECAO_ESQUERDA 	   EQU  0FFFFH
DIRECAO_CENTRO 	       EQU  0
DIRECAO_DIREITA 	   EQU  1

OFFSET_OVNI_EXISTE	   			EQU  0
OFFSET_OVNI_LINHA	   			EQU  2
OFFSET_OVNI_COLUNA	   			EQU  4
OFFSET_OVNI_TIPO	   			EQU  6
OFFSET_OVNI_DIRECAO	   			EQU  8
OFFSET_OVNI_ENDERECO_IMAGEM     EQU  10

SELECIONA_ECRA					EQU 6004H
ECRA_MISSIL_NAVE				EQU 1
ECRA_OVNI_1						EQU 2
ECRA_OVNI_2						EQU 3
ECRA_OVNI_3						EQU 4
ECRA_OVNI_4						EQU 5
ECRA_EXPLOSAO					EQU 6


PLAY				   EQU  605CH
PARA_VIDEO			   EQU  605EH
ENDERECO_IMAGEM  	   EQU  6046H

; **********************************************************************
; * Código
; **********************************************************************
; **********************************************************************
; * VARIAVEIS, IMAGENS E PILHA (SP)
; **********************************************************************
PLACE      2500H

TABLE      400H        ; reserva espaco para a pilha
sp_start:

CONTADOR_OVNI: WORD 0

linha_referencia_nave:
	WORD 27

coluna_referencia_nave:
	WORD 29

linha_referencia_missil:
	WORD LINHA_MISSIL

coluna_referencia_missil:
	WORD 0

flag_clock_missil:
	WORD 0

flag_clock_ovni:
	WORD 0
	
flag_clock_energia:
	WORD 0
	
tab_int:		WORD clock_ovni			; tabela das várias interrupções
				WORD clock_missil
				WORD clock_energia

missil_existe:
	WORD 0

tab_ovni1:	
	WORD 0 					; existencia do ovni
	WORD LINHA_OVNI 		; linha atual ovni
	WORD COLUNA_OVNI 		; coluna atual ovni
	WORD OVNI_BOM 			; tipo de ovni
	WORD DIRECAO_CENTRO 	; direcao ovni
	WORD 0					; endereco de imagem

tab_ovni2:	
	WORD 0 					; existencia do ovni
	WORD LINHA_OVNI 		; linha atual ovni
	WORD COLUNA_OVNI 		; coluna atual ovni
	WORD OVNI_BOM 			; tipo de ovni
	WORD DIRECAO_CENTRO 	; direcao ovni
	WORD 0					; endereco de imagem
	
tab_ovni3:	
	WORD 0 					; existencia do ovni
	WORD LINHA_OVNI 		; linha atual ovni
	WORD COLUNA_OVNI 		; coluna atual ovni
	WORD OVNI_BOM 			; tipo de ovni
	WORD DIRECAO_CENTRO 	; direcao ovni
	WORD 0					; endereco de imagem
	
tab_ovni4:	
	WORD 0 					; existencia do ovni
	WORD LINHA_OVNI 		; linha atual ovni
	WORD COLUNA_OVNI 		; coluna atual ovni
	WORD OVNI_BOM 			; tipo de ovni
	WORD DIRECAO_CENTRO 	; direcao ovni
	WORD 0					; endereco de imagem

tab_quatro_ovnis:
	WORD tab_ovni1
	WORD tab_ovni2
	WORD tab_ovni3
	WORD tab_ovni4

JOGO_EM_PAUSA: WORD FALSE
GAME_OVER: WORD FALSE
TECLA_PREMIDA: WORD 0FFFFH
TECLA_ANTERIOR: WORD 0FFFFH
MOVE_NAVE: WORD FALSE	


PLACE      3500H

imagem_nave:
	STRING 5, 5
    STRING 0,0,1,0,0
    STRING 0,1,1,1,0
    STRING 1,1,1,1,1
    STRING 0,0,1,0,0
    STRING 0,1,0,1,0,0

imagem_missil:
	STRING 1, 2
	STRING 1
	STRING 1

imagem_coisa_mt_distante:
	STRING 1, 1
	STRING 1, 0

imagem_coisa_distante:
	STRING 2, 2
	STRING 1, 1
	STRING 1, 1

imagem_nave_inimiga_1:
	STRING 3, 3
	STRING 1, 0, 1
	STRING 0, 1, 0
	STRING 0, 0, 0, 0

imagem_nave_inimiga_2:
	STRING 5, 5
	STRING 1, 0, 1, 0, 1
	STRING 0, 1, 0, 1, 0
	STRING 0, 0, 1, 0, 0
	STRING 0, 0, 0, 0, 0
	STRING 0, 0, 0, 0, 0, 0

imagem_nave_inimiga_3:
	STRING 5, 5
	STRING 1, 0, 0, 0, 1
	STRING 0, 1, 0, 1, 0
	STRING 1, 0, 1, 0, 1
	STRING 0, 1, 0, 1, 0
	STRING 0, 0, 1, 0, 0, 0

imagem_meteoro_1:
	STRING 3, 3
	STRING 0, 1, 0
	STRING 0, 1, 0
	STRING 0, 1, 0, 0

imagem_meteoro_2:
	STRING 4, 4
	STRING 0, 1, 1, 0
	STRING 1, 0, 0, 1
	STRING 1, 1, 1, 1
	STRING 1, 0, 0, 1

imagem_meteoro_3:
	STRING 5, 5
	STRING 0, 1, 1, 1, 1
	STRING 1, 0, 0, 0, 0
	STRING 1, 0, 0, 0, 0
	STRING 1, 0, 0, 0, 0
	STRING 0, 1, 1, 1, 1, 0		

imagem_explosao:
    STRING 5, 5
    STRING 1, 0, 1, 0, 1
    STRING 0, 1, 0, 1, 0
    STRING 1, 0, 1, 0, 1
    STRING 0, 1, 0, 1, 0
    STRING 1, 0, 1, 0, 1, 0


PLACE      0


inicio:	

;**********************************************************************
; Inicializações
;**********************************************************************

	MOV BTE, tab_int		; inicia o BTE
	MOV SP, sp_start  		; inicia o SP

	MOV  R2, TEC_LIN   ; endereço do periférico das linhas
    MOV  R3, TEC_COL   ; endereço do periférico das colunas
    MOV  R4, DISPLAYS  ; endereço do periférico dos displays

	MOV R7, ENERGIA_INICIAL
	MOV R6, R7
	MOV R8, ENERGIA_ATUAL
	MOV [R8], R6
	
	CALL conversao

	MOV R9, ENDERECO_IMAGEM
    MOV R1, 1
    MOV [R9], R1

ciclo_inicial:

    CALL teclado

    MOV R10, TECLA_PREMIDA
	MOV R9, [R10]
    MOV R11, 0CH
    CMP R9, R11
    JNZ ciclo_inicial
	
	MOV R9, 0FFFFH
    MOV [R10], R9
	
	MOV R0, PLAY
	MOV R1, 0
	MOV [R0], R1
	
	MOV R0, 6002H
	MOV [R0], R1
	
    EI0
    EI1
	;EI2 																
	EI
;**********************************************************************
; Corpo principal do programa
;**********************************************************************

main:
	MOV  R1, LINHA	   ; faz um copia do numero da linha a testar
	
	MOV R8, COR_NAVE
	CALL desenha_nave
	
	CALL andar_cima
	
	CALL ciclo_ovnis
	
	CALL teclado
	CALL teclas
	
	JMP main

;**************************************************************************************************************
; Ciclos onde se verifica qual tecla esta a ser permida.
;************************************************************************************************************** 
;
;Descricao: Iniciamos dois contadores a 0, R6 e R7 que vao correponder no final ao numero da linha e da coluna, respetivamente.
;			Ao saber a linha e coluna da tecla, sabemos o seu valor.
;           Com "valor" da tecla entende-se o seu valor no teclado hexadecimal.
;           Cada vez que a linha ou a coluna a testar nao correspodem a posicao da tecla, testa-se as restantes linhas e colunas.

teclado:
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R3

	reset:
		MOV R0, TEC_LIN	    ; insere o endereço das linhas em R0
		MOV R1, TEC_COL	    ; insere o endereço das colunas em R1
		MOV R2, LINHA       ; insere a primeira linha do teclado
	inicio_teclado:
		MOVB [R0], R2     ; ativa a linha no teclado
		MOVB  R3, [R1]    ; le das colunas o input do utilizador
		CMP   R3, 0 	  ; verifica se houve alguma tecla premida
		JNZ key_press 	  ; se sim, salta a frente
		SHL   R2, 1 	  ; se nao, passa a proxima linha
		MOV   R0, 10H 	  ; colocacao do valor a seguir a linha maxima em R0 temporariamente para fazer a comparacao
		CMP   R2, R0      ; verifica se a rotina ja fez um loop (se ja verificou todas as linhas)
		JZ pops_teclado	  ; se sim, jump para fim da rotina
		MOV R0, TEC_LIN   ; se nao, repor o endereco das linhas do teclado
		JMP inicio_teclado	  ; jump para inicio

	key_press:
		MOV R0, 0	  ; inicializacao do contador das linhas
		MOV R1, 0	  ; inicializacao do contador das colunas

		linha:		   ; ciclo que faz a contagem dos bits da linha (o numero possivel de SHR possiveis ate chegar a 0)
			SHR R2, 1
			ADD R0, 1  ; por cada shift right executado, incrementacao do contador por 1
			CMP R2, 0  ; verificacao de que ainda ha bits para contar
			JNZ linha  ; se houver, jump para inicio do ciclo para se repetir
			SUB R0, 1  ; se nao houver, decrementa 1 ao contador para passar de um valor entre 1 a 4 para 0 a 3
		;repeticao do mesmo ciclo mas para as colunas
		coluna:		   ; ciclo que faz a contagem dos bits da coluna (o numero possivel de SHR possiveis ate chegar a 0)
			SHR R3, 1
			ADD R1, 1
			CMP R3, 0
			JNZ coluna
			SUB R1, 1

		MOV R2, 4
		MUL R0, R2		; execucao da formula 4*linha + coluna para determinar a tecla (de 0 a F)
		ADD R0, R1		; execucao da formula 4*linha + coluna para determinar a tecla (de 0 a F)

   MOV R3, TECLA_PREMIDA
	MOV [R3], R0	; R3 tem o valor final da tecla premida

	pops_teclado:
		POP R3
		POP R2
		POP R1
		POP R0
		RET
		
;**************************************************************************************************************
; tecla0, tecla1, tecla2 e tecla3 - Ciclos onde se verifica se a tecla que esta a ser permida e a tecla 0, 1, 2 ou 3
;**************************************************************************************************************
;
;Descricao: Ao carregar numa tecla cada ciclo "tecla" vai verificar qual tecla e permida
;			e efetuar a operacao correpondente, diminuindo ou aumentando o valor no display.
;			
;			tecla0 - subtrai uma unidade a cada clique
;			tecla1 - aumenta uma unidade a cada clique
;			tecla2 - subtrai enquanto a tecla estiver a ser permida (unidade a unidade)
;			tecla3 - aumenta enquanto a tecla estiver a ser permida (unidade a unidade)
teclas:
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R6
	PUSH R7
	PUSH R8
	PUSH R9
	PUSH R10
	PUSH R11
	
	MOV  R1, TECLA_PREMIDA
	MOV  R3, [R1]
	
	MOV R5, TECLA_ANTERIOR
	MOV R2, [R5]
	
	CMP R3, 0
	JEQ tecla0
	
	CMP R3, 2
	JEQ tecla2

	CMP R3, R2
	JEQ teclas_ret

tecla0:
	CMP  R3, 0                ; verifica se a tecla 2 esta a ser permida
	JNE  tecla1               ; se a tecla 2 nao estiver a ser permida, passamos para o proximo ciclo "tecla"
	
	MOV R4, JOGO_EM_PAUSA
	MOV R7, [R4]
	CMP R7, FALSE
	JNZ teclas_ret
	
	MOV R4, GAME_OVER
	MOV R7, [R4]
	CMP R7, FALSE
	JNZ teclas_ret
	
	CALL andar_esquerda        
	JMP  teclas_ret		; enquanto a tecla estiver a ser permida, o valor do display fica igual

tecla1:				
	CMP  R3, 1                ; verifica se a tecla 2 esta a ser permida
	JNE  tecla2               ; se a tecla 2 nao estiver a ser permida, passamos para o proximo ciclo "tecla"
	
	MOV R4, JOGO_EM_PAUSA
	MOV R7, [R4]
	CMP R7, FALSE
	JNZ teclas_ret
	
	MOV R4, GAME_OVER
	MOV R7, [R4]
	CMP R7, FALSE
	JNZ teclas_ret
	
	CALL inicia_missil
	JMP  teclas_ret

tecla2:
	CMP  R3, 2                ; verifica se a tecla 2 esta a ser permida
    JNE  teclac               ; se a tecla 2 nao estiver a ser permida, passamos para o proximo ciclo "tecla"
	
	MOV R4, JOGO_EM_PAUSA
	MOV R7, [R4]
	CMP R7, FALSE
	JNZ teclas_ret
	
	MOV R4, GAME_OVER
	MOV R7, [R4]
	CMP R7, FALSE
	JNZ teclas_ret
	
	CALL andar_direita        
    JMP  teclas_ret  

teclac:
	MOV R4, 0CH					
	CMP R3, R4				   ; verifica se a tecla d esta a ser permida
	JNE teclad			       ; se a tecla D nao estiver a ser permida, acaba o cilo "tecla"
	JMP inicio

teclad:							
	MOV R4, 0DH					
	CMP R3, R4				   ; verifica se a tecla d esta a ser permida
	JNE teclae			       ; se a tecla D nao estiver a ser permida, acaba o cilo "tecla"
	
	MOV R4, GAME_OVER
	MOV R7, [R4]
	CMP R7, FALSE
	JNZ teclas_ret
	
	CALL pausa
	JMP teclas_ret

teclae:
	MOV R4, 0EH
	CMP R3, R4
	JNE teclas_ret

	CALL game_over

	MOV R9, PARA_VIDEO
	MOV R7, 0
	MOV [R9], R7
	
	MOV R9, ENDERECO_IMAGEM
	MOV R1, 0
	MOV [R9], R1
	
	MOV R1, 6002H
	MOV [R0], R1 

	DI

	JMP teclas_ret
	
teclas_ret:
   
	MOV [R5], R3

    MOV R0, -1
    MOV [R1], R0

	POP R11
	POP R10
	POP R9
    POP R8
	POP R7
	POP R6
	POP R5
	POP R4
	POP R3
    POP R2
	POP R1
    POP R0
    RET
	
	
;**************************************************************************************************************
; converter_pontuacao - Rotina para converter um valor hexadecimal para decimal 
;**************************************************************************************************************
;
;Descricao: Converte o valor hexadecimal para decimal 
;
;Parametros: R6 com o valor a converter
;
;Destroi: R6
;
;Retorna: R8 com o valor decimal

conversao:			   
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R6
	
	MOV  R8, R6			; faz uma copia do valor a converter
	MOV  R2, 10			; iniciacao do divisor
	MOD  R8, R2			; resto da divisao inteira do valor a converter por 10, com resultado o algarismo das unidades
	MOV  R3, R6			; segunda copia do valor a converter
	DIV  R3, R2			; divisao inteira do valor a converter por 10 - valor1
	MOV  R4, R3			; copia do resultado da instrucao anterior
	MOD  R3, R2			; resto da divisao inteira do valor1 por 10, com resultado o algarismo das unidades - valor2
	DIV  R4, R2			; divisao inteira do valor2 - valor3
	SHL  R4, 8			; valor3, transformado em centenas
	SHL  R3, 4			; valor2, transformado em dezenas
	ADD  R8, R3         ; soma do algarismo das unidades com o das dezenas
	ADD  R8, R4         ; soma das dezenas e das unidades com as centenas 
	
	MOV R4, DISPLAYS
	MOV [R4], R8
	
	POP  R6
	POP  R4
	POP  R3
	POP  R2
	RET


;**************************************************************************************************************
; ha_tecla1 e ha_tecla2 - Ciclos onde se espera até NENHUMA tecla estar premida
;**************************************************************************************************************
;
;Descricao: Enquanto alguma tecla estiver a ser premida, espera-se até não estar.
; 			A diferenca entre os dois ciclos vai ter por base se a tecla em questao vai ter 
;			uma alteracao ,do valor no display, continua ou nao.

ha_tecla1:              
    MOVB [R2], R1      ; escrever no periférico de saída (linhas)
    MOVB R0, [R3]      ; ler do periférico de entrada (colunas)
    CMP  R0, 0         ; há tecla premida?
    JNZ  ha_tecla1     ; se ainda houver uma tecla premida, espera até não haver
    JMP  main         ; repete ciclo
	
ha_tecla2:			   ; neste ciclo espera-se até NENHUMA tecla estar premida
	MOVB [R2], R1      ; escrever no periférico de saída (linhas)
    MOVB R0, [R3]      ; ler do periférico de entrada (colunas)
    CMP  R0, 0         ; há tecla premida?
    JNZ  ha_tecla2     ; se ainda houver uma tecla premida, espera até não haver
    JMP  main         ; repete ciclo



;*****************************************************************************************************************************
; andar_direita, andar_esquerda, andar_cima e andar_baixo - Ciclos de movimento tanto da nave, do missil como dos ovnis.
;*****************************************************************************************************************************
;
; MOVIMENTOS DA NAVE
;
;Descricao: Os ciclos, andar_direita e andar_esquerda, dizem respeito ao movimento horizontal da nave, em que a nave que estava
; ate entao no ecra e apagada (pintada com a cor transparente) e substituida por uma outra nave pintada a direita ou a esquerda,
; consoante a rotina, com a cor da nave, neste caso o amarelo.
;
;Parametros:
;
; R3 - Endereco da coluna de referencia da nave
; R4 - Valor da coluna inicial da nave a qual ira ser somada ou subtraida 1, consoante a rotina
; R8 - Limite ate ao qual a nave pode andar e cor com a qual a nave vai ser sucessivamente pintada

andar_direita:
	PUSH R8
	PUSH R3
	PUSH R4

	MOV  R3, coluna_referencia_nave
    MOV  R4, [R3]                               ;coluna atual da nave
    MOV  R8, LIMITE_NAVE_DIREITA
    CMP  R4, R8									;verifica se a nave ja chegou ao fim do ecra
    JGE andar_direita_ret	

	MOV  R8, COR_TRANSPARENTE				
    CALL desenha_nave							;apaga a nave
    
    ADD  R4, 1									
    MOV  [R3], R4
	MOV  R8, COR_NAVE
	CALL desenha_nave							;nave anda para a direita

andar_direita_ret:
	POP R4
	POP R3
	POP R8
	RET

andar_esquerda:
	PUSH R8
	PUSH R3
	PUSH R4

	MOV  R3, coluna_referencia_nave				;coluna atual da nave
	MOV  R4, [R3]
	MOV  R8, LIMITE_NAVE_ESQUERDA				;verifica se a nave ja chegou ao fim do ecra
	CMP  R4, R8
	JLE andar_esquerda_ret

	MOV  R8, COR_TRANSPARENTE				
	CALL desenha_nave							;apaga a nave

	SUB  R4, 1
	MOV  [R3], R4
	MOV  R8, COR_NAVE
	CALL desenha_nave							;nave anda para a esquerda

andar_esquerda_ret:
	POP R4
	POP R3
	POP R8
	RET

; MOVIMENTOS DO MISSIL
;
;Descricao: O ciclo andar_cima, diz respeito ao movimento ascendente do missil, que e monotorizado pela flag_clock_missil com
; qual vai ser verificada a existencia do missil. Este missil e "destruido" caso passe do seu limite superior ou caso colida
; com uma nave inimiga.
;
;Parametros:
;
; R3 - Endereco da flag_clock_missil, do missil_existe e da linha_referencia_missil
; R4 - Valor da flag do missil e do limite superior apartir do qual este e "destruido"
; R8 - Cor do missil, transparente ou azul.

andar_cima:
	
	PUSH R3
	PUSH R4
	PUSH R8
	PUSH R9
	
	MOV R9, LIMITE_MISSIL

	MOV  R3, flag_clock_missil
	MOV  R4, [R3]								
	CMP  R4, 1
	JNE  andar_cima_ret							;se o missil exsite, entao continua a subir
	MOV  R4, 0
	MOV  [R3], R4

	MOV R3, missil_existe
	MOV R4, [R3]
	CMP R4, 0
	JEQ andar_cima_ret							;se o missil ja nao existe, para de subir 
	
	MOV  R8, COR_TRANSPARENTE	
	CALL desenha_missil							;apaga se o missil

	MOV  R3, linha_referencia_missil
	MOV  R4, [R3]
	CMP  R4, R9
	JEQ  missil_destroy							;verifica se o missil ja chegou a linha limite

	SUB  R4, 1
	MOV  [R3], R4
	MOV  R3, R4
	MOV  R8, COR_MISSIL
	CALL desenha_missil							;missil anda para cima um pixel
	JMP andar_cima_ret

	missil_destroy:
		
		MOV R4, 0
		MOV R3, missil_existe
		MOV [R3], R4							;caso o missil seja destruido, ja nao existe

andar_cima_ret:
	POP R9
	POP R8
	POP R4
	POP R3
	RET

; MOVIMENTOS DOS OVNIS
;
;Descricao: O ciclo andar_baixo diz respeito ao movimento descendente dos ovnis, sendo que estes poderao ser destruidos, caso sejam naves inimigas,
; ou minerados caso sejam asteroides. Apartir desse momento os ovnis consideram-se "destruidos" e irao dar respawn no cimo do ecra.
;
;Parametros:
;
; R3 - Endereco da flag_clock_ovni, do ovni_existe e da linha_referencia_ovni
; R4 - Valor da flag do missil e do limite superior apartir do qual este e "destruido"

ciclo_ovnis:
	
	PUSH R0
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R6
	PUSH R8
	PUSH R9
	PUSH R10

	; avalia o estado da flag do ovni 


	MOV  R3, flag_clock_ovni
	MOV  R4, [R3]
	CMP  R4, 1
	JNE  ciclo_ovnis_ret

	MOV R0, 0
	
	MOV R8, SELECIONA_ECRA
	MOV R6, ECRA_OVNI_1
	MOV [R8], R6
	
	CALL inicia_ovni
	CALL update_ovni
	
	MOV R0, 2
	
	MOV R8, SELECIONA_ECRA
	MOV R6, ECRA_OVNI_2
	MOV [R8], R6
	
	CALL inicia_ovni
	CALL update_ovni
	
	MOV R0, 4
	
	MOV R8, SELECIONA_ECRA
	MOV R6, ECRA_OVNI_3
	MOV [R8], R6
	
	CALL inicia_ovni
	CALL update_ovni
	
	MOV R0, 6
	
	MOV R8, SELECIONA_ECRA
	MOV R6, ECRA_OVNI_4
	MOV [R8], R6
	
	CALL inicia_ovni
	CALL update_ovni

	MOV R4, 0
	MOV [R3], R4
	
ciclo_ovnis_ret:
	
	POP R10
	POP R9
	POP R8
	POP R6
	POP R5
	POP R4
	POP R3
	POP R0
	RET


; UPDATE_ OVNI
;
; Descricao: Esta rotina vai dar update as informacoes dos quatro ovnis, de acordo com as informacoes utilizadas em inicia_ovni.
; Esta rotina vai ter um loop sendo que vai ser feita 4 vezes, as vezes necessarias para atualizar os quatro ovnis.
;
; Parametros: 
;
; R0 - ID do ovni
; R1 - Endereco da tabela dos ovnis
; R2 - Contador do LOOP
; R3 - Diferentes informacoes acerca de cada ovni
; R4 - Linha atual do ovni
; R5 - Linha limite do ovni
; R8 - Cor do ovni
; R9 - Flag que determina a existencia do ovni
; R10 - Linha apartir da qual o ovni passa a ser ou um ovni com (meteoro) ou um ovni mau (nave inimiga)

update_ovni:

; R0 com o id dos ovnis

	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R6
	PUSH R7
	PUSH R8
	PUSH R9
	PUSH R10
	PUSH R11
	
	
	; linha apartir da qual ocorre a transformacao do ovni e a linha limite
	
	MOV  R10, LINHA_TRANFORMACAO
	MOV  R5, LIMITE_OVNI
	
	MOV R1, tab_quatro_ovnis
	ADD R1, R0
	
	MOV R1, [R1]

	; verifica se ovni ainda "existe"
	
	MOV R3, [R1 + OFFSET_OVNI_EXISTE]
	CMP R3, 0
	JEQ update_ovni_ret
	
	; apaga o ovni
	
	MOV  R8, COR_TRANSPARENTE
	CALL desenha_ovni

	; avalia se houve ou nao colisoes

	CALL colisoes

	; verifica se o ovni ja chegou ao fim do ecra

	MOV  R3, [R1 + OFFSET_OVNI_LINHA]
	CMP  R3, R5
	JEQ  ovni_destroy_limite
	
	; avalia se houve destruicao por colisao
	
	CMP  R9, 1
	JEQ  ovni_destroy_colisao_missil
	
	CMP  R9, 2
	JEQ  ovni_destroy_colisao_nave
	; movimento descendente do ovni

	ADD  R3, 1
	MOV  [R1 + OFFSET_OVNI_LINHA], R3
	
	; movimento do ovni lateral
	
	MOV R7, [R1 + OFFSET_OVNI_DIRECAO]
	MOV R11, [R1 + OFFSET_OVNI_COLUNA]
	ADD R7, R11
	MOV [R1 + OFFSET_OVNI_COLUNA], R7
	
	
muda_cor_ovni:
	
	MOV R6, [R1 + OFFSET_OVNI_TIPO]
	CMP R6, OVNI_BOM
	JEQ desenha_ovni_bom
	
	CMP R3, LINHA_ANTES_TRANSFORMACAO
	JLE update_ovni_coisa
	
	MOV R8, COR_NAVE_INIMIGA
	CALL desenha_ovni
	JMP update_ovni_ret

update_ovni_coisa:

	MOV R8, COR_COISA
	CALL desenha_ovni
	JMP update_ovni_ret

desenha_ovni_bom:

	CMP R3, LINHA_ANTES_TRANSFORMACAO
	JLE update_ovni_coisa

	MOV R8, COR_METEORO
	CALL desenha_ovni
	JMP update_ovni_ret


ovni_destroy_colisao_missil:
	
	; como houve colisao o missil e apagado
	
	MOV  R8, COR_TRANSPARENTE
	CALL desenha_missil
	
	; missil passa a estar agora inexistente
	
	MOV R4, 0
	MOV R3, missil_existe
	MOV [R3], R4
	
	; localizacao do proximo respawn do missil
	
	MOV R5, linha_referencia_missil
	MOV R10, LINHA_MISSIL
	MOV [R5], R10
	MOV R5, coluna_referencia_missil
	MOV R10, 0
	MOV [R5], R10
	
	MOV R6, [R1 + OFFSET_OVNI_TIPO] 
	CMP R6, OVNI_BOM
	JEQ ovni_destroy_limite
	
	MOV R6, ENERGIA_ATUAL
	MOV R7, [R6]
	
	MOV R4, 5
	
	ADD R7, R4
	
	MOV [R6], R7
	
	MOV R6, R7
	
	CALL conversao

	ovni_destroy_limite:
		MOV R9, 0					; o ovni deixa de existir
		MOV R4, 0
		MOV [R1 + OFFSET_OVNI_EXISTE], R4
		
		JMP update_ovni_ret

ovni_destroy_colisao_nave:

	MOV R6, [R1 + OFFSET_OVNI_TIPO] 
	CMP R6, OVNI_BOM
	JEQ ovni_bom_destroy_colisao_nave

	CALL game_over

	MOV R9, PARA_VIDEO
	MOV R7, 0
	MOV [R9], R7
	
	MOV R9, ENDERECO_IMAGEM
	MOV R1, 2
	MOV [R9], R1
	
	MOV R1, 6002H
	MOV [R0], R1 

	DI
	
	JMP ovni_destroy_limite_colisao_nave
	
	
ovni_bom_destroy_colisao_nave:
	
	MOV R11, COR_TRANSPARENTE
	CALL desenha_ovni

	MOV R6, ENERGIA_ATUAL
	MOV R7, [R6]
	
	MOV R4, 10
	
	ADD R7, R4
	
	MOV [R6], R7
	
	MOV R6, R7
	
	CALL conversao


	ovni_destroy_limite_colisao_nave:
		MOV R9, 0					; o ovni deixa de existir
		MOV R4, 0
		MOV [R1 + OFFSET_OVNI_EXISTE], R4


update_ovni_ret:
	POP R11
	POP R10
	POP R9
	POP R8
	POP R7
	POP R6
	POP R5
	POP R4
	POP R3
	POP R2
	POP R1
	POP R0
	RET

nave_destroy_colisao:
	PUSH R8
	PUSH R9
	
	MOV  R8, COR_TRANSPARENTE
	CALL desenha_nave						;apaga a nave
	
	MOV R9, 0								;nave e destruida
	
	POP R9
	POP R8
	RET


;**************************************************************************************************************
; Ciclos pausa, endgame, vitoria e main menu, cilos onde se verifica o estdado em que esta o programa
;************************************************************************************************************** 

; Ciclo pausa
; 
; Descricao: Neste ciclo o programa para e espera se ate ser clicada a teclad para o programa sair da pausa
;
; Parametros:
;
; R3 - Ultima telca premida
; R4 - Constanate 0DH

pausa:
	
	PUSH R3
	PUSH R4
	PUSH R5
	
	MOV R4, JOGO_EM_PAUSA
	MOV R5, [R4]
	
	CMP R5, FALSE
	JEQ mete_pausa
	
	EI
	MOV R3, FALSE
	MOV [R4], R3
	
	JMP pausa_ret

mete_pausa:	
	
	DI
	MOV R3, TRUE
	MOV [R4], R3

	JMP pausa_ret

pausa_ret:
	
	POP R5
	POP R4
	POP R3
	RET



game_over:

	PUSH R3
	PUSH R4
	PUSH R5
	
	MOV R4, GAME_OVER
	MOV R5, [R4]
	
	CMP R5, FALSE
	JEQ da_game_over
	
	MOV R3, FALSE
	MOV [R4], R3
	
	JMP game_over_ret

da_game_over:	
	
	MOV R3, TRUE
	MOV [R4], R3

	JMP game_over_ret

game_over_ret:
	
	POP R5
	POP R4
	POP R3
	RET

;**************************************************************************************************************
; Ciclos desenha imagem, nave, missil, ovni e explosao
;************************************************************************************************************** 
; 
; Descricao : Nestes ciclos desenha se os "interveniente" no jogo


; Ciclo desenha imgaem
;
; Descricao: Este ciclo e um ciclo auxiliar com o qual vao ser desenhados no ecra todos os pixeis que se pretende
;
; Parametors: 
;
; R0 - Endereco da imagem 
; R1 - Imagem dos diferentes "intervenientes"
; R2 - 
; R3 - 
; R4 - Linha
; R5 - Coluna
; R7 - Variavel aleatoria responsavel pelas diferentes probabilidades
; R9 - Copia da coluna
; R10 - Copia de R1

desenha_imagem: 		 
	 PUSH R11
	 PUSH R10 			
	 PUSH R9  			
	 PUSH R8
	 PUSH R7
	 PUSH R6
	 PUSH R5
	 PUSH R4
	 PUSH R3
	 PUSH R2
	 PUSH R1
	 PUSH R0

	MOV R7, CONTADOR_OVNI						;aumenta o registo que tem a variavel aletoria
	MOV R11, [R7]
	ADD R11, 1
	MOV [R7], R11

	 MOVB R1, [R0]								;faz se copias das variaveis para podermos voltar ao valor inicial delas
     MOV R10, R1
     MOV R9, R5
     ADD R0, 1
     MOVB R2, [R0]
     ADD R0, 1
     JMP desenha_linha
	 
	desenha_imagem_loop:						;desenha se a imagem ate acabar a sua matriz
		MOV R1, R10
		ADD R4, 1
		MOV R5, R9
		SUB R2, 1
		CMP R2, 0
		JZ desenha_imagem_ret
		
desenha_linha:
        MOVB R3, [R0]
        CMP R3, 0
        MOV R7, R4
        JNZ pixel_imagem
   desenha_linha_aux:
        ADD R0, 1
        SUB R1, 1
        JZ desenha_imagem_loop
        ADD R5, 1
        JMP desenha_linha

pixel_imagem:
       CALL escreve_pixel
       JMP desenha_linha_aux	

desenha_imagem_ret:
		POP R0
		POP R1
		POP R2
		POP R3
		POP R4
		POP R5
		POP R6
		POP R7
		POP R8
		POP R9
		POP R10
		pop R11
		RET

 escreve_pixel:
         PUSH R4
         MOV R4, DEFINE_LINHA
         MOV [R4], R7
         MOV R4, DEFINE_COLUNA
         MOV [R4], R5
         MOV R4, DEFINE_PIXEL
         MOV [R4], R8
         POP R4
         RET


; Ciclo desenha nave
;
; Descricao: Este ciclo e responsavel por desenhar a nave
;
; Parametors: 
;
; R0 - Imagem da nave
; R4 - Linha atual da nave
; R5 - Coluna atual da nave
; R6 - Endereco da linha atual da nave
; R7 - Endereco da coluna atual da nave

desenha_nave:
	PUSH R6
	PUSH R5
	PUSH R4
	PUSH R7
	PUSH R0
	PUSH R8
	
	MOV R5, SELECIONA_ECRA
	MOV R6, ECRA_MISSIL_NAVE
	MOV [R5], R6
	
	MOV  R6, linha_referencia_nave
	MOV  R7, coluna_referencia_nave
	MOV  R5, [R7]
	MOV  R4, [R6]
	MOV  R0, imagem_nave
	CALL desenha_imagem								;desenha a nave de acordo com a sua ultima "localizacao"
	
	POP R8
	POP R0
	POP R7
	POP R4
	POP R5
	POP R6
	RET


; Ciclo desenha missil
;
; Descricao: Este ciclo e responsavel por desenhar o missil
;
; Parametors: 
;
; R0 - Imagem do missil
; R4 - Linha atual do missil
; R5 - Coluna atual do missil
; R6 - Endereco da linha atual do missil
; R7 - Endereco da coluna atual do missil


desenha_missil:
	PUSH R6
	PUSH R5
	PUSH R7
	PUSH R0
	PUSH R8
	
	MOV R5, SELECIONA_ECRA
	MOV R6, ECRA_MISSIL_NAVE
	MOV [R5], R6

	MOV R6, linha_referencia_missil
	MOV R4, [R6]
	MOV R6, coluna_referencia_missil
	MOV R5, [R6]
	MOV  R0, imagem_missil
	CALL desenha_imagem								;desenha o missil de acordo com a sua ultima "localizacao"
	
	POP R8
	POP R0
	POP R7
	POP R5
	POP R6
	RET
	
	
; Ciclo desenha ovni
;
; Descricao: Este ciclo e responsavel por desenhar o ovni
;
; Parametors: 
;
; R0 - ID ovni
; R4 - Linha atual do ovni
; R5 - Coluna atual do ovni
; R6 - Endereco da linha e da coluna atual do ovni
; 
; R10 - Diferentes linhas de transformacao do ovni

desenha_ovni:
	PUSH R6
	PUSH R5
	PUSH R7
	PUSH R0
	PUSH R8
	PUSH R9
	PUSH R10
	
	MOV R7, tab_quatro_ovnis
	ADD R7, R0
	
	MOV R7, [R7]
	
	MOV R4, [R7 + OFFSET_OVNI_LINHA]
	
	MOV R5, [R7 + OFFSET_OVNI_COLUNA]					;verifica se a posicao atual do ovni
	
	MOV R6, [R7 + OFFSET_OVNI_TIPO]
	
	CMP R4, 3								
	JLE desenha_coisa_mt_distante						;se o ovni tiver na linha 3 ou abaixo, dezenha-se coisa_mt_distante (o mesmo raciocinii para as outras imagens)
	
	CMP R4, 6
	JLE desenha_coisa_distante
	MOV R10, 10

	CMP R6, OVNI_BOM
	JEQ desenha_meteoro
	
	CMP R4, R10
	JLE desenha_imagem_ovni
	MOV R10, 15
	
	CMP R4, R10
	JLE desenha_imagem_ovni_2
	MOV R10, 100
	
	CMP R4, R10
	JLE desenha_imagem_ovni_3


desenha_meteoro:
	
	CMP R4, R10
	JLE desenha_imagem_meteoro
	MOV R10, 15
	
	CMP R4, R10
	JLE desenha_imagem_meteoro_2
	MOV R10, 100
	
	CMP R4, R10
	JLE desenha_imagem_meteoro_3
	
desenha_coisa_mt_distante:
	MOV  R0, imagem_coisa_mt_distante
	CALL desenha_imagem
	JMP desenha_ovni_ret

desenha_coisa_distante:
	MOV  R0, imagem_coisa_distante
	CALL desenha_imagem
	JMP desenha_ovni_ret

desenha_imagem_ovni:
	MOV  R0, imagem_nave_inimiga_1
	CALL desenha_imagem
	JMP desenha_ovni_ret	

desenha_imagem_ovni_2:
	MOV  R0, imagem_nave_inimiga_2
	CALL desenha_imagem
	JMP desenha_ovni_ret

desenha_imagem_ovni_3:
	MOV  R0, imagem_nave_inimiga_3
	CALL desenha_imagem
	JMP desenha_ovni_ret

desenha_imagem_meteoro:
	MOV  R0, imagem_meteoro_1
	CALL desenha_imagem
	JMP desenha_ovni_ret	

desenha_imagem_meteoro_2:
	MOV  R0, imagem_meteoro_2
	CALL desenha_imagem
	JMP desenha_ovni_ret

desenha_imagem_meteoro_3:
	MOV  R0, imagem_meteoro_3
	CALL desenha_imagem
	JMP desenha_ovni_ret

desenha_ovni_ret:
	POP R10
	POP R9
	POP R8
	POP R0
	POP R7
	POP R5
	POP R6
	RET


; Ciclo desenha explosao
;
; Descricao: Este ciclo e responsavel por desenhar a explosao
;
; Parametors: 
;
; R0 - ID ovni e imagem da explosao
; R4 - Linha atual do ovni
; R5 - Coluna atual do ovni
; R6 - Endereco da linha e da coluna atual do ovni
; R8 - Diferentes cores da explosao (transparente ou laranja)


desenha_explosao:
    PUSH R0
	PUSH R6
    PUSH R5
    PUSH R7
    PUSH R0
    PUSH R8
	PUSH R9
	
	MOV R8, SELECIONA_ECRA
	MOV R6, ECRA_EXPLOSAO
	MOV [R8], R6
	
	MOV R8, tab_quatro_ovnis
	ADD R8, R0
	
	MOV R8, [R8]
	
	MOV R4, [R8 + OFFSET_OVNI_LINHA]
	
	MOV R5, [R8 + OFFSET_OVNI_COLUNA]					;verifica se a posicao atual o ovni
														

	MOV R0, imagem_explosao
    MOV R8, COR_EXPLOSAO
    CALL desenha_imagem												;desenha se a explosao com delay para dar tempo para a "animacao da excplosao" correr
	CALL ciclo_delay
	
	MOV R8, imagem_explosao
    MOV R8, COR_TRANSPARENTE
    CALL desenha_imagem												;apaga se a explosao

	POP R9
	POP R8
    POP R0
    POP R7
    POP R5
    POP R6
	POP R0
    RET


;**************************************************************************************************************
; Ciclos inicia missil e ovni
;************************************************************************************************************** 
; 
; Descricao : Estes ciclos sao responsaveis por iniciar o missil e o ovni


; Ciclo inica missil
;
; Descricao: Este ciclo e responsavel por iniciar o missil
;
; Parametors: 
;
; R0 - Endereco da flag de existencia do ovni, da linha atual do missil, da coluna do missil e da coluna atual da nave.
; R1 - Valor da flag de existencia do ovni, da linha atual do missil e da coluna atual da nave.


inicia_missil:
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R4
	PUSH R6
	PUSH R7

	
	MOV R0, missil_existe								
	MOV R1, [R0]	
	CMP R1, 1
	JEQ inicia_missil_ret											;caso o missil ja exista nao se ira iniciar um outro
	MOV R1, 1														;caso nao exista passa se a considerar que existe
	MOV [R0], R1

	MOV R0, linha_referencia_missil
	MOV R1, LINHA_MISSIL
	MOV [R0], R1													

	MOV R0, coluna_referencia_nave
	MOV R1, [R0]
	ADD R1, 2
	MOV R0, coluna_referencia_missil
	MOV [R0], R1												   ;o missil e iniciado

	MOV R6, ENERGIA_ATUAL
	MOV R7, [R6]
	
	CMP R7, 5
	JEQ sem_energia
	MOV R4, 5

	SUB R7, R4
	
	MOV [R6], R7
	
	MOV R6, R7
	
	CALL conversao

	JMP inicia_missil_ret
	
sem_energia:

	MOV R9, PARA_VIDEO
	MOV R7, 0
	MOV [R9], R7
	
	MOV R9, ENDERECO_IMAGEM
	MOV R1, 0
	MOV [R9], R1
	
	MOV R1, 6002H
	MOV [R0], R1 

	DI

inicia_missil_ret:
	
	POP R7
	POP R6
	POP R4
	POP R2
	POP R1
	POP R0
	RET


; Ciclo inica ovni
;
; Descricao: Este ciclo e responsavel por iniciar o ovni
;
; Parametors: 
;
; R0 - Recebe o ID do ovni
; R1 - Endereco da tabela do ovni
; R2 - Contador que ira gerar um valor pseudo aleatorio
; R3 - Cnstante utilizada para calcular as probabilidades
; R4 - Copia do valor do contador e direcao do ovni


; recebe o id do ovni em R0

inicia_ovni: 	
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4

	;obter endereco do ovni
	
	MOV R1, tab_quatro_ovnis
	ADD R1, R0
	MOV R1, [R1]

	;dizer que o ovni existe, a linha inicial e a coluna inicial
	
	MOV R2, [R1 + OFFSET_OVNI_EXISTE]
	CMP R2, 1
	JEQ inicia_ovni_ret
	
	MOV R2, 1
	MOV [R1 + OFFSET_OVNI_EXISTE], R2
	
	MOV R2, LINHA_OVNI
	
	MOV [R1 + OFFSET_OVNI_LINHA], R2
	
	MOV R2, COLUNA_OVNI
	MOV [R1 + OFFSET_OVNI_COLUNA], R2
	
	;dizer o tipo do ovni
	
	MOV R2, CONTADOR_OVNI
	MOV R3, [R2]
	MOV R4, R3				;guarda o valor do contador 
	MOV R2, 3
	AND R3, R2           ; retira os dois ultimos bits do contador
	CMP R3, 0
	JEQ inicia_ovni_bom
	
	MOV R2, OVNI_MAU
	
	MOV [R1 + OFFSET_OVNI_TIPO], R2
	JMP inicia_direcao
	
inicia_ovni_bom:
	
	MOV R2, OVNI_BOM
	
	MOV [R1 + OFFSET_OVNI_TIPO], R2

	;dizer a direcao do ovni

inicia_direcao:

	MOV R2, 3
	
	MOD R4, R2
	
	CMP R4, 0
	JNE inicia_direcao_nao_centro	
	
	MOV R4, DIRECAO_CENTRO
	
	JMP inicia_direcao_guardar
	
inicia_direcao_nao_centro:

	CMP R4, 1
	JNE inicia_direcao_esquerda
	
	MOV R4, DIRECAO_DIREITA
	
	JMP inicia_direcao_guardar
	
inicia_direcao_esquerda:

	MOV R4, DIRECAO_ESQUERDA


inicia_direcao_guardar:

	MOV [R1 + OFFSET_OVNI_DIRECAO], R4

	;dizer a imagem do ovni
	
	MOV R4, imagem_coisa_mt_distante
	
	MOV [R1 + OFFSET_OVNI_ENDERECO_IMAGEM], R4

inicia_ovni_ret:
	POP R4
	POP R3
	POP R2
	POP R1
	POP R0
	RET


; Colisoes
;
; Descricao esta rotina e responsavel por determinar se houve ou nao uma colisao entre um ovni e o missil ou entre um ovni e a nave.


colisoes:
	PUSH R0 ; ID ovni
	PUSH R1 ;linha ovni
	PUSH R2 ;coluna ovni
	PUSH R3 ;linha missil
	PUSH R4 ;coluna missil
	PUSH R5 ;ultima linha ovni
	PUSH R6 ;ultima coluna ovni
	PUSH R7 ;ultima linha missil
	PUSH R8 ;ultima coluna missil
	PUSH R10
	PUSH R11

	MOV R8, tab_quatro_ovnis
	ADD R8, R0
	
	MOV R8, [R8]
	
	MOV R1, [R8 + OFFSET_OVNI_LINHA]
	
	MOV R2, [R8 + OFFSET_OVNI_COLUNA]

	MOV R5, R1
	MOV R5, linha_referencia_missil
	MOV R3, [R5]
	MOV R5, coluna_referencia_missil
	MOV R4, [R5]												;verifica se a posicao tanto do ovni como do missil
	
	MOV R5, R1
	ADD R5, 5
	MOV R6, R2
	ADD R6, 5
	MOV R7, R3
	ADD R7, 3
	MOV R8, R4
	ADD R4, 1
	
	CMP R7, R1
	JLT colisoes_nave
	
	CMP R3, R5
	JGT colisoes_nave
	
	CMP R4, R6
	JGT colisoes_nave
	
	CMP R8, R2
	JLT colisoes_nave										;verifica se se e possivel que o ovni e o missil estejam a ocupar pixeis comuns

	MOV R9, 1 ;houve colisao
	CALL desenha_explosao									;em caso afirmativo ha colisao, o ovni e apagado e a explosao e desenhada
	JMP colisoes_ret
	
colisoes_nave:
	;R1 linha ovni
	;R2 coluna ovni
	;R3 linha nave
	;R4 coluna nave
	;R5 ultima linha ovni
	;R6 ultima coluna ovni
	;R7 ultima linha nave
	;R8 ultima coluna nave
	
	MOV R5, linha_referencia_nave
	MOV R3, [R5]
	MOV R5, coluna_referencia_nave
	MOV R4, [R5]
	
	MOV R5, R1
	ADD R5, 5
	
	MOV R6, R4      ;xnave - 4
	SUB R6, 4
	
	MOV R8, R4      ;xnave + 4
	ADD R8, 4
	
	CMP R3, R5
	JGT colisoes_ret
	
	CMP R2, R6   
	JLT colisoes_ret
	
	CMP R2, R8
	JGT colisoes_ret
	
	MOV R9, 2
	
colisoes_ret:
	POP R11
	POP R10
	POP R8
	POP R7
	POP R6
	POP R5
	POP R4
	POP R3
	POP R2
	POP R1
	POP R0
	RET

;**************************************************************************************************************
; Clocks
;************************************************************************************************************** 
; Rotinas de interrupcao dos varios clocks

clock_ovni:
	
	PUSH R0
	PUSH R1
	
	MOV  R0, flag_clock_ovni
	MOV  R1, 1
	MOV  [R0], R1
	
	POP  R1
	POP  R0
	RFE

clock_energia:
	
	PUSH R0
	PUSH R1
	PUSH R4
	PUSH R6
	PUSH R7
		
	MOV  R0, flag_clock_energia
	MOV  R1, 1
	MOV  [R0], R1
	
	MOV R6, ENERGIA_ATUAL
	MOV R7, [R6]
	
	MOV R4, 5
	
	SUB R7, R4
	
	MOV [R6], R7
	
	MOV R6, R7
	
	CALL conversao
	
	POP R7
	POP R6
	POP R4
	POP R1
	POP R0
	RFE

clock_missil:
	PUSH R0
	PUSH R1
	
	MOV  R0, flag_clock_missil
	MOV  R1, 1
	MOV  [R0], R1
	
	POP  R1
	POP  R0
	RFE


;**************************************************************************************************************
; Ciclos auxiliares
;************************************************************************************************************** 

ciclo_delay:										; este ciclo cria um delay para as rotinas que o chamarem
	PUSH R1
	PUSH R2
	
	MOV R1, 50000
	MOV R2, 50000
	
ciclo1:												
	SUB R1, 1
	JNZ ciclo1

ciclo2:
	SUB R2, 1 
	JNZ ciclo2
	
	POP R2 
	POP R1
	RET