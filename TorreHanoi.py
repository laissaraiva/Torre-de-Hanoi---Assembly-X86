def torre_de_hanoi(n, torre_inicial, torre_final, torre_auxiliar):
    """
    Função recursiva para resolver o problema da Torre de Hanói.

    Args:
        n: O número de discos.
        torre_inicial: O nome da torre de origem.
        torre_final: O nome da torre de destino.
        torre_auxiliar: O nome da torre auxiliar.
    """
    if n == 1:
        print(f"Mova disco 1 da Torre {torre_inicial} para a Torre {torre_final}")
        return
    torre_de_hanoi(n-1, torre_inicial, torre_auxiliar, torre_final)
    print(f"Mova disco {n} da Torre {torre_inicial} para a Torre {torre_final}")
    torre_de_hanoi(n-1, torre_auxiliar, torre_final, torre_inicial)

# Início do programa
if __name__ == "__main__":
    num_discos = -1  # Inicializa com um valor inválido
    entrada_valida = False  # Flag para controlar o laço

    while not entrada_valida:
        num_discos_str = input("Digite a quantidade de discos (entre 0 e 9): ")

        # Verifica se a entrada é um dígito
        if num_discos_str.isdigit():
            num_discos_int = int(num_discos_str)
            # Verifica se o número está no intervalo correto
            if 0 <= num_discos_int <= 9:
                num_discos = num_discos_int
                entrada_valida = True  # Entrada é válida, o laço vai parar
            else:
                print("Por favor, digite um número entre 0 e 9.")
        else:
            print("Entrada inválida. Por favor, digite um número inteiro.")

    # O código continua aqui após o laço terminar
    if num_discos > 0:
        print(f"\nAlgoritmo da Torre de Hanoi com {num_discos} discos")
        torre_de_hanoi(num_discos, 'A', 'C', 'B')  # A é a torre inicial, C a final, B a auxiliar
        print("Concluído!")
    else:
        print("Nenhum disco para mover. Concluído!")
