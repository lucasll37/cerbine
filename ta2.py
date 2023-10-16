import numpy as np

# MANUALMENTE - 'A' o buffer de pulsos
# A = []  # Inicialize A como uma lista vazia
# print('Digite os valores do BUFFER (pressione Enter após cada valor):')
# for i in range(32):
#     valor = int(input(f'Digite o valor do elemento {i + 1}: '))
#     A.append(valor)
# print('BUFFER preenchido')
# print(A)

# Leia do diretório MATLAB DRIVE
# PRIL = np.loadtxt("T_PRIL.txt")
# BUFFER = np.loadtxt("TBUFFER.txt")

# Se necessário manipular o formato do arquivo txt
# A = np.round(BUFFER)
# A = A[4:15, 0:14]
# A = A.flatten()
# A = A.tolist()
# A.sort()

# RODANDO O PRIL

PRIL = np.loadtxt("T_PRIL.txt")

# Estabelecendo as variáveis para busca
indice_buffer = 0  # Índice do pulso atual para busca no buffer
linha_PRIL = 0  # Índice da linha atual na tabela PRIL

# Inicializando variáveis vazias para trabalhar com elas no script
primeiros_PPI_possiveis = []
proximos_PPI_condizentes = []
ameacas_encontradas = []

qtd_pulsos_buffer = len(A)  # Número de pulsos no buffer

while linha_PRIL < len(PRIL):  # Enquanto houver linhas na tabela PRIL
    
    # Buffer menor que tamanho mínimo de busca
    if qtd_pulsos_buffer < 5:
        break
    
    # Intervalo e janela da n-ésima linha do PRIL
    limite_inferior_intervalo_linha_PRIL = PRIL[linha_PRIL, 0]
    limite_superior_intervalo_linha_PRIL = PRIL[linha_PRIL, 1]
    janela_linha_PRIL = PRIL[linha_PRIL, 2]
    
    # Buscas dentro de A com índice i como parâmetro
    while indice_buffer <= (qtd_pulsos_buffer - 4):
        # Varrendo A comparando ao PRIL
        for j in range(indice_buffer + 1, qtd_pulsos_buffer - 2):
            # Seja esta a diferença PPI1 ...
            Dif = A[j] - A[indice_buffer]
            # PPI1 está no intervalo do PRIL?
            if (limite_inferior_intervalo_linha_PRIL - janela_linha_PRIL <= Dif <= limite_superior_intervalo_linha_PRIL + janela_linha_PRIL):
                # Se sim, salve-a em um vetor com os TOAs
                primeiros_PPI_possiveis.append(Dif)
            if Dif > limite_superior_intervalo_linha_PRIL + janela_linha_PRIL:
                break
        # Se for não vazio, foi achado ao menos um termo
        if primeiros_PPI_possiveis:
            # Tem-se em PPIS1 todos os TOAs possíveis desse intervalo
            for p in range(len(primeiros_PPI_possiveis)):
                # Para cada TOA em PPIS1, buscar-se-á o subsequente em A
                for j in range(indice_buffer + 2, qtd_pulsos_buffer - 1):
                    # Seja esta a diferença PPI2 ...
                    Dif = A[j] - A[indice_buffer]
                    # PPI2 está no mesmo intervalo de PPI1 novamente?
                    if (2 * primeiros_PPI_possiveis[p] - janela_linha_PRIL <= Dif <= 2 * primeiros_PPI_possiveis[p] + janela_linha_PRIL):
                        # Se sim, salve-a em um vetor com os TOAs
                        proximos_PPI_condizentes.append(Dif - primeiros_PPI_possiveis[p])
                    if Dif > 2 * primeiros_PPI_possiveis[p] + janela_linha_PRIL:
                        break
                # Se for não vazio, foi achado ao menos um novo termo
                if proximos_PPI_condizentes:
                    # Tem-se em PPIS2 todos os TOAs possíveis novamente
                    for q in range(len(proximos_PPI_condizentes)):
                        # Inicializando variáveis contadoras
                        contador = [0, 0, 0]
                        PPI345 = [0, 0, 0]
                        dev345 = [0, 0, 0]
                        # Varrendo A para confirmação de PRI
                        for r in range(3, 6):
                            # Serão necessários 3 rounds de confirmação
                            # Busca por todo o buffer em cada uma delas
                            for j in range(indice_buffer + 3, qtd_pulsos_buffer):
                                Dif = A[j] - A[indice_buffer]
                                # Se dentro do intervalo e janela
                                # Utilizei Wdw*0.67 por conta da média
                                if ((r * np.mean([primeiros_PPI_possiveis[p], proximos_PPI_condizentes[q]]) - janela_linha_PRIL <= Dif)
                                    and (Dif <= (r * np.mean([primeiros_PPI_possiveis[p], proximos_PPI_condizentes[q]]) + janela_linha_PRIL))):
                                    # Vai salvar o k correspondente
                                    contador[r - 3] += 1
                                    # Salva a PPI da posição
                                    PPI345[r - 3] = Dif / r
                                    # Salva o deviation
                                    dev345[r - 3] = abs(PPI345[r - 3] - np.mean([primeiros_PPI_possiveis[p], proximos_PPI_condizentes[q]]))
                                else:
                                    # Quando maior que o intervalo + janela
                                    if Dif > (r * np.mean([primeiros_PPI_possiveis[p], proximos_PPI_condizentes[q]]) + janela_linha_PRIL):
                                        # Interrompe o for do buffer
                                        break
                            # Se a primeira confirmação não der resultado
                            if contador[0] == 0:
                                # Interrompe a busca
                                break
                        # Caso tenha ao menos 2 elementos de k != 0
                        if sum(np.array(contador) != 0) >= 2:
                            PRI = [primeiros_PPI_possiveis[p], proximos_PPI_condizentes[q]] + PPI345
                            DEV = [(proximos_PPI_condizentes[q] - primeiros_PPI_possiveis[p])] + dev345
                            TREM = [A[indice_buffer], np.mean([x for x in PRI if x != 0]), np.mean([x for x in DEV if x != 0])]
                            ameacas_encontradas.append(TREM)
                            if len(ameacas_encontradas) > 1:
                                # Encontrar índices de PRIs múltiplos
                                maxMultiplo_PRI = TREM[1] / min([x for x in ameacas_encontradas if x != 0], key=lambda x: x[1])
                                indice_PRI_Multiplos = []
                                for i in range(1, int(maxMultiplo_PRI) + 1):
                                    multiploAtual = TREM[1] / i
                                    indice_PRI_Multiplos = [x for x in indice_PRI_Multiplos if abs(ameacas_encontradas[x][1] - multiploAtual) <= janela_linha_PRIL]
                                indice_PRI_Multiplos = [x for x in indice_PRI_Multiplos if x != len(ameacas_encontradas)]
                                if indice_PRI_Multiplos:
                                    # Remover as linhas correspondentes das ameaças
                                    ameacas_encontradas.pop()
                            # Apagar TOAs congruentes
                            # Poderia-se definir uma tolerância de X%
                            # Zerando os valores em A que são próximos o suficiente de TREM
                            indexador = 0
                            while (TREM[0] + indexador * np.mean([x for x in PRI if x != 0])) <= max(A):
                                # Calculando a Diferença entre os termos e os elementos de A
                                Dif = np.abs(np.array(A) - (TREM[0] + indexador * np.mean([x for x in PRI if x != 0])))
                                # Encontrando os índices dos elementos de dentro de (janela_linha_PRIL*0.34)
                                Ind = np.where(Dif <= janela_linha_PRIL * 0.34)[0]
                                # Remove os elementos encontrados de A
                                A = [x for i, x in enumerate(A) if i not in Ind]
                                indexador += 1
                            # PRI ok, Salvo e Apagado!
                            qtd_pulsos_buffer = len(A)
                            # Novo tamanho de buffer
                            indice_buffer = 0
                            # Voltando ao i=1 porque apaguei o mesmo
                        # Caso confirmação falhar
                    # Caso confirmação falhar
                # Acabada a busca dos PPIs condizentes
                proximos_PPI_condizentes = []
                PPI345 = [0, 0, 0]
                dev345 = [0, 0, 0]
            # Caso PPIs condizentes vazio
            # Caso PPIs condizentes vazio
            primeiros_PPI_possiveis = []
            proximos_PPI_condizentes = []
            PPI345 = [0, 0, 0]
            dev345 = [0, 0, 0]
        # Caso PPIs possiveis vazio
        indice_buffer += 1
    # Caso em que terminaram as buscas para essa linha do PRIL
    linha_PRIL += 1
    indice_buffer = 0
# Caso em que não há mais n para buscar no PRIL
for ameaca in ameacas_encontradas:
    print(ameaca)
