import numpy as np

# Tipo de Emissores
# 1 - Somente STABLE
# 2 - Somente STAGGER
# 3 - STABLE e STAGGER
# 4 - Somente JITTER
# 5 - STABLE, STAGGER e JITTER
tipoEmissores = 1

# Quantidade Máxima de Emissores STABLE
qtdSTABLE = 0

# Quantidade Máxima de Emissores STAGGER
qtdSTAGGER = 0

# Tipo STAGGER
# 1 - t1, t2
# 2 - t1, t2, t3
# 3 - t1, t2, t3, t4
tipoSTAGGER = 1

# Quantidade Máxima de Emissores JITTER
qtdJITTER = 0

# Tipo JITTER
# 1 - 2%
# 2 - 4%
# 3 - 8%
# 4 - 12%
# 5 - 16%
tipoJITTER = 1

# Gerar Manualmente
tipoEmissores = int(input('Tipo de Emissores: 1 - Somente STABLE, 2 - Somente STAGGER, 3 - STABLE e STAGGER, 4 - Somente JITTER, 5 - STABLE, STAGGER e JITTER\nPor favor, insira um número de 1 a 5: '))
while not (1 <= tipoEmissores <= 5):
    tipoEmissores = int(input('Por favor, insira um número de 1 a 5: '))

if tipoEmissores in [1, 3, 5]:
    qtdSTABLE = int(input('Por favor, insira a quantidade de emissores STABLE: '))
    while qtdSTABLE <= 0:
        qtdSTABLE = int(input('Por favor, insira um número inteiro positivo: '))

if tipoEmissores in [2, 3, 5]:
    qtdSTAGGER = int(input('Insira a quantidade de emissores STAGGER: '))
    while qtdSTAGGER <= 0:
        qtdSTAGGER = int(input('Por favor, insira um número inteiro positivo: '))
    
    tipoSTAGGER = int(input('Insira o tipo do(s) emissor(es) STAGGER: 1 - t1 e t2, 2 - t1, t2 e t3, 3 - t1, t2, t3 e t4: '))
    while not (1 <= tipoSTAGGER <= 3):
        tipoSTAGGER = int(input('Por favor, insira um número de 1 a 3: '))

if tipoEmissores in [4, 5]:
    qtdJITTER = int(input('Por favor, insira a quantidade de emissores JITTER: '))
    while qtdJITTER <= 0:
        qtdJITTER = int(input('Por favor, insira um número inteiro positivo: '))

    tipoJITTER = int(input('Insira o tipo do(s) emissor(es) JITTER: 1 - 2%, 2 - 4%, 3 - 8%, 4 - 12%, 5 - 16%: '))
    while not (1 <= tipoJITTER <= 5):
        tipoJITTER = int(input('Por favor, insira um número de 1 a 5: '))

# Inicializando
ListaSTABLE = np.zeros((qtdSTABLE, 3))
ListaSTAGGER = np.zeros((qtdSTAGGER, tipoSTAGGER + 3))
ListaJITTER = np.zeros((qtdJITTER, 3))
A = []

# Todos PRIs
TodosPRIs = np.arange(50, 1001)  # Variam de 10us a 1000us

# Gerando STABLE
if tipoEmissores in [1, 3, 5]:
    # TOAs e PRIs STABLE
    condicaoSatisfeita = False
    while not condicaoSatisfeita:
        PRIsCONDICAO = np.random.choice(TodosPRIs, qtdSTABLE, replace=False)
        # Verifica se a diferença mínima entre quaisquer dois valores é pelo menos 10us
        if np.all(np.diff(PRIsCONDICAO) >= 10) or qtdSTABLE == 1:
            condicaoSatisfeita = True
    TzerosSTABLE = np.random.randint(0, 5001, size=qtdSTABLE)  # Até 5000
    PRIsSTABLE = PRIsCONDICAO
    for i in range(qtdSTABLE):
        ListaSTABLE[i, :] = [TzerosSTABLE[i], PRIsSTABLE[i], 0]
    
    # Gerar parcial Buffer STABLE
    for j in range(qtdSTABLE):
        deviation = []
        for k in range(101):  # Gerando até 100 pulsos (se couber no buffer)
            if TzerosSTABLE[j] + k * PRIsSTABLE[j] <= 50000:
                A.append(TzerosSTABLE[j] + (k - 1) * PRIsSTABLE[j] + round(np.random.normal(0, 1)))
                # Margem de erro de leitura do TOA apenas para o STABLE
                deviation.append(A[-1] - (TzerosSTABLE[j] + ((k - 1) * PRIsSTABLE[j])))
            else:
                break
        # Inserir o deviation médio (para STABLE, apenas erros gerados randômicos)
        ListaSTABLE[i, 2] = np.mean(deviation)

# Gerando STAGGER
if tipoEmissores in [2, 3, 5]:
    PRIsSTAGGER = np.zeros((qtdSTAGGER, tipoSTAGGER + 1))
    for i in range(qtdSTAGGER):
        TzerosSTAGGER = np.random.randint(0, 5001)  # Até 5000us
        tempos_unicos = np.zeros(tipoSTAGGER + 1)
        for p in range(tipoSTAGGER + 1):
            uniqueNum = False
            while not uniqueNum:
                # Gerando um número aleatório para cada t STAGGER
                num = np.random.randint(10, 1001)
                # Verifica se o número já existe ts diferentes
                if np.all(num != tempos_unicos) and np.all(np.abs(num - tempos_unicos) > 50):
                    uniqueNum = True
                    tempos_unicos[p] = num
        PRIsSTAGGER[i, :] = tempos_unicos  # Até 1000us
        ListaSTAGGER[i, :] = np.concatenate((np.array([TzerosSTAGGER]), PRIsSTAGGER[i, :], np.array([0])))
    
    # Gerar parcial Buffer STAGGER
    for j in range(qtdSTAGGER):
        B = np.zeros(101)
        B[0] = TzerosSTAGGER[j]  # Primeiro elemento de B
        p_idx = 1  # indexador MOD tipo STAGGER
        deviation = []
        for i in range(1, 101):  # Iterar de 2 até 101
            B[i] = (B[i - 1] + PRIsSTAGGER[j, p_idx] + round(np.random.normal(0, 1)))  # Adicionar um novo elemento a B
            # Margem de erro de leitura do TOA apenas para o STAGGER
            deviation.append(B[-1] - (B[i - 1] + PRIsSTAGGER[j, p_idx]))
            # Atualizar os índices
            p_idx = (p_idx % (tipoSTAGGER + 1)) + 1
            if B[i] + PRIsSTAGGER[j, p_idx] > 50000:
                break
        A.extend(B[:i+1])
        # Inserir o deviation médio (para STAGGER, apenas erros gerados randômicos)
        ListaSTAGGER[i, tipoSTAGGER + 2] = np.mean(deviation)

# Gerando JITTER
if tipoEmissores in [4, 5]:
    # TOAs e PRIs JITTER
    condicaoSatisfeita = False
    while not condicaoSatisfeita:
        PRIsCONDICAO = np.random.choice(TodosPRIs, qtdJITTER, replace=False)
        # Verifica se a diferença mínima entre quaisquer dois valores é pelo menos 10us
        if np.all(np.diff(PRIsCONDICAO) >= 10) or qtdJITTER == 1:
            condicaoSatisfeita = True
    TzerosJITTER = np.random.randint(0, 5001, size=qtdJITTER)  # Até 5000
    PRIsJITTER = PRIsCONDICAO
    for i in range(qtdJITTER):
        ListaJITTER[i, :] = [TzerosJITTER[i], PRIsJITTER[i], 0]

    idxJITTER = np.array([[1, 0.02], [2, 0.04], [3, 0.08], [4, 0.12], [5, 0.16]])

    # Gerar parcial Buffer JITTER
    for j in range(qtdJITTER):
        deviation = []
        jit = np.floor(PRIsJITTER[j] * idxJITTER[tipoJITTER - 1, 1])
        for k in range(101):  # Gerando até 100 pulsos (se couber no buffer)
            if TzerosJITTER[j] + k * PRIsJITTER[j] <= 50000:
                intervaloJITTER = [np.ceil(PRIsJITTER[j] - jit), np.floor(PRIsJITTER[j] + jit)]
                A.append(TzerosJITTER[j] + (k - 1) * (intervaloJITTER[0] + round((intervaloJITTER[1] - intervaloJITTER[0]) * np.random.rand())))
                # Margem de erro de leitura do TOA apenas para o STABLE
                deviation.append(A[-1] - (TzerosJITTER[j] + round((k - 1) * PRIsJITTER[j])))
            else:
                break
        # Inserir o deviation médio (para STABLE, apenas erros gerados randômicos)
        ListaJITTER[i, 2] = np.mean(deviation)

# Resposta em tela e dados
A = sorted(A)
print(ListaSTABLE)
print(ListaSTAGGER)
print(ListaJITTER)
