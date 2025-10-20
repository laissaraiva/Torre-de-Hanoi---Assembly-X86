; 	Solução para a Torre de Hanói
; 	Alunas : Ana Raquel e Laís saraiva


; A seção .data é onde declaramos todas as variáveis e constantes pré-definidas
; que serão usadas pelo programa.
section .data
    ; Mensagem que pede ao usuário para digitar o número de discos.
    ; 'db' significa 'define byte', armazenando a string como uma sequência de caracteres.
    msg_input         db  "Digite a quantidade de discos com que voce deseja jogar (1-9): "
    ; 'equ' (equate) cria uma constante simbólica. '$ - msg_input' calcula
    ; o tamanho da mensagem automaticamente.
    len_input         equ $ - msg_input

    ; Mensagem que será exibida no início, informando com quantos discos o jogo será executado.
    msg_inicial       db  "Algoritmo da Torre de Hanoi com "
    msg_discos        db  " "      ; Espaço reservado para o número de discos (um caractere ASCII).
                      db  " discos", 0x0A ; 0x0A é o código para nova linha (\n).
    len_inicial       equ $ - msg_inicial

    ; Mensagem padrão para cada movimento de disco.
    msg_mova          db  "Mova disco "
    msg_disco_atual   db  " "      ; Espaço para o número do disco que está sendo movido.
                      db  " da Torre "
    msg_torre_origem  db  " "      ; Espaço para a torre de origem (A, B ou C).
                      db  " para a Torre "
    msg_torre_destino db  " "      ; Espaço para a torre de destino (A, B ou C).
                      db  0x0A     ; Nova linha.
    len_movimento     equ $ - msg_mova

    ; Mensagem final exibida quando o algoritmo termina.
    msg_concluido     db  "Concluido!", 0x0A
    len_concluido     equ $ - msg_concluido

; Seção .bss: Define variáveis não inicializadas (espaço reservado na memória).
section .bss
    entrada_numero    resb 2     ; Reserva 2 bytes para a entrada do usuário (um dígito + Enter).
    num_discos        resb 1     ; Reserva 1 byte para armazenar o número de discos.

; A seção .text contém o código executável, ou seja, as instruções que
; o processador irá executar.
section .text
    global _start      ; Define o ponto de entrada do programa, tornando-o visível para o linker.


; Função  para ler os dados  da entrada padrão (teclado).
; Usa a chamada de sistema (syscall) sys_read.
; Parâmetros  configurados antes de chamar :
;   rsi: Endereço do buffer para armazenar os dados lidos.
;   rdx: Número máximo de bytes a serem lidos.

input:
    push    rax        ; Salva os registradores para não interferir em outras partes do código.
    push    rdi
    push    rsi
    push    rdx

    mov     rax, 0     ; syscall número 0 (sys_read) 
    mov     rdi, 0     ; file descriptor 0 (stdin - entrada padrão/teclado).
    syscall            ; Chama o kernel do Linux para executar a syscall.

    pop     rdx        ; Restaura os registradores.
    pop     rsi
    pop     rdi
    pop     rax
    ret                ; Retorna da função.

; Função 'output': Escreve dados na saída padrão .
; Usa a chamada de sistema (syscall) sys_write do Linux.
; Parâmetros 
;   rsi: Endereço da mensagem a ser escrita.
;   rdx: Tamanho da mensagem em bytes.

output:
    push    rax
    push    rdi
    push    rsi
    push    rdx

    mov     rax, 1     ; syscall número 1 (sys_write) 
    mov     rdi, 1     ; file descriptor 1 (stdout - saída padrão/tela).
    syscall            ; Chama o kernel.

    pop     rdx
    pop     rsi
    pop     rdi
    pop     rax
    ret


; Função que  monta e exibe a mensagem inicial.
 
exibir_mensagem_inicial:
    push    rax
    push    rsi
    push    rdx

    ; Prepara o número de discos para exibição.
    mov     al, [num_discos]    ; Carrega o número de discos (ex: 5).
    add     al, '0'             ; Converte o número para seu caractere ASCII (ex: '5').
    mov     [msg_discos], al    ; Coloca o caractere no espaço reservado da mensagem.

    ; Configura os parâmetros para a função 'output'.
    mov     rsi, msg_inicial
    mov     rdx, len_inicial
    call    output

    pop     rdx
    pop     rsi
    pop     rax
    ret

; Função que monta e exibe a mensagem de um movimento.
; Parâmetros esperados nos registradores:
;   dl: Número do disco a ser movido.
;   al: Caractere da torre de origem ('A', 'B' ou 'C').
;   cl: Caractere da torre de destino ('A', 'B' ou 'C').
output_movimento:
    push    rax
    push    rbx
    push    rcx
    push    rdx
    push    rsi

    ; Prepara os valores para exibição, colocando-os nos espaços reservados da mensagem.
    mov     bl, dl              ; Copia o número do disco para bl.
    add     bl, '0'             ; Converte para ASCII.
    mov     [msg_disco_atual], bl ; Salva na mensagem.

    mov     [msg_torre_origem], al  ; Salva a torre de origem.
    mov     [msg_torre_destino], cl ; Salva a torre de destino.

    ; Configura os parâmetros e chama 'output'.
    mov     rsi, msg_mova
    mov     rdx, len_movimento
    call    output

    pop     rsi
    pop     rdx
    pop     rcx
    pop     rbx
    pop     rax
    ret


; Função para  Implementação recursiva do algoritmo da Torre de Hanói.
; Parâmetros esperados nos registradores:
;   dl: (parte de rdx) Número de discos a mover.
;   al: (parte de rax) Torre de origem.
;   bl: (parte de rbx) Torre auxiliar.
;   cl: (parte de rcx) Torre de destino.
hanoi:
    ; Verifica se estamos no caso base (n == 1).
    cmp     dl, 1
    je      .caso_base          ; Se for igual a 1, pula para o caso base.

    ; Passo 1: Mover n-1 discos da origem para a torre auxiliar.
    push    rax                 ; Salva o estado atual (origem, aux, dest, n) na pilha.
    push    rbx
    push    rcx
    push    rdx

    dec     rdx                 ; n = n - 1
    xchg    rbx, rcx            ; Troca destino com auxiliar. Agora: hanoi(n-1, origem, destino, aux)
    call    hanoi               ; Chamada recursiva.

    pop     rdx                 ; Restaura o estado original da pilha.
    pop     rcx
    pop     rbx
    pop     rax

    ; Passo 2: Mover o disco n da origem para o destino.
    call    output_movimento

    ; Passo 3: Mover n-1 discos da torre auxiliar para o destino.
    push    rax
    push    rbx
    push    rcx
    push    rdx

    dec     rdx                 ; n = n - 1
    xchg    rax, rbx            ; Troca origem com auxiliar. Agora: hanoi(n-1, aux, origem, destino)
    call    hanoi               ; Segunda chamada recursiva.

    pop     rdx
    pop     rcx
    pop     rbx
    pop     rax

    ret

.caso_base:
    ; Se n=1, simplesmente move o disco da origem para o destino.
    call    output_movimento
    ret


; Ponto de entrada principal do programa.

_start:
    ; Exibe a mensagem pedindo o número de discos.
    mov     rsi, msg_input
    mov     rdx, len_input
    call    output

    ; Lê a entrada do usuário.
    mov     rsi, entrada_numero ; Buffer onde a entrada será armazenada.
    mov     rdx, 2              ; Lê no máximo 2 bytes (o dígito e a tecla Enter).
    call    input

    ; Converte o caractere ASCII digitado para um valor numérico.
    mov     dl, [entrada_numero] ; Pega o primeiro caractere digitado.
    sub     dl, '0'              ; Subtrai o valor ASCII de '0' para obter o número (ex: '5' - '0' = 5).

    ; Armazena o número de discos na variável.
    mov     [num_discos], dl

    ; Exibe a mensagem inicial com o número de discos.
    call    exibir_mensagem_inicial

    ; Configura os parâmetros iniciais para a Torre de Hanói.
    ; O número de discos (dl) já foi configurado.
    mov     al, 'A'             ; rax = torre origem.
    mov     bl, 'B'             ; rbx = torre auxiliar.
    mov     cl, 'C'             ; rcx = torre destino.

    ; Chama a função recursiva principal.
    call    hanoi

    ; Exibe a mensagem de conclusão.
    mov     rsi, msg_concluido
    mov     rdx, len_concluido
    call    output

    ; Finaliza o programa.
    mov     rax, 60             ; syscall número 60 (sys_exit) 
    xor     rdi, rdi            ; Código de saída 0 (sucesso).
    syscall                     ; Chama o kernel.
