import numpy as np
import matplotlib.pyplot as plt


import numpy as np
import matplotlib.pyplot as plt
from scipy.signal import find_peaks

# Código anterior aqui...

# Tipo de Emissores
# 1 - Somente STABLE
# 2 - Somente STAGGER
# 3 - STABLE e STAGGER
# 4 - Somente JITTER
# 5 - STABLE, STAGGER e JITTER
tipoEmissores = 1

# Código anterior aqui...

# Gere manualmente o tipo de emissores
tipoEmissores = int(input('Tipo de Emissores: 1 - Somente STABLE - 2 - Somente STAGGER - 3 - STABLE e STAGGER - 4 - Somente JITTER - 5 - STABLE, STAGGER e JITTER\nPor favor, insira um número de 1 a 5: '))
while not (1 <= tipoEmissores <= 5):
    tipoEmissores = int(input('Por favor, insira um número de 1 a 5: '))

# Código anterior aqui...

# Gere os emissores com base no tipo selecionado
if tipoEmissores in [1, 3, 5]:
    qtdSTABLE = int(input('Por favor, insira a quantidade de emissores STABLE: '))
    while qtdSTABLE <= 0:
        qtdSTABLE = int(input('Por favor, insira um número inteiro positivo: '))

# Código anterior aqui...

if tipoEmissores in [2, 3, 5]:
    qtdSTAGGER = int(input('Insira a quantidade de emissores STAGGER: '))
    while qtdSTAGGER <= 0:
        qtdSTAGGER = int(input('Por favor, insira um número inteiro positivo: '))
    tipoSTAGGER = int(input('Insira o tipo do(s) emissor(es) STAGGER: 1 - t1 e t2 - 2 - t1, t2 e t3 - 3 - t1, t2, t3 e t4: '))
    while tipoSTAGGER not in [1, 2, 3]:
        tipoSTAGGER = int(input('Por favor, insira um número de 1 a 3: '))

# Código anterior aqui...

if tipoEmissores in [4, 5]:
    qtdJITTER = int(input('Por favor, insira a quantidade de emissores JITTER: '))
    while qtdJITTER <= 0:
        qtdJITTER = int(input('Por favor, insira um número inteiro positivo: '))
    tipoJITTER = int(input('Insira o tipo do(s) emissor(es) JITTER: 1 - 2% - 2 - 4% - 3 - 8% - 4 - 12% - 5 - 16%: '))
    while tipoJITTER not in [1, 2, 3, 4, 5]:
        tipoJITTER = int(input('Por favor, insira um número de 1 a 5: '))


# Calculando as diferenças entre cada par de TOAs
diferencas = []
for i in range(len(A)):
    for j in range(i+1, len(A)):
        diferencas.append(A[j] - A[i])

# Existe um PRI máximo limitado na geração de ameaças
# Logo vamos limitar também aqui para diminuir o esforço computacional
diferencas = np.array(diferencas)
diferencas = diferencas[diferencas < 1000]

# Binning das diferenças
binWidth = 0.005 * np.max(diferencas)  # largura do bin é 1% do valor máximo da diferença
edges = np.arange(0, np.max(diferencas) + binWidth, binWidth)  # define os limites dos bins
histCounts, _ = np.histogram(diferencas, edges)

# Procurando os picos no histograma
from scipy.signal import find_peaks

picos, locs = find_peaks(histCounts, prominence=5, height=10, distance=5)  # ajuste conforme necessário
PRIs = edges[locs] + binWidth / 2  # adicionar metade da largura do bin para obter o centro do bin

# Após detectar os PRIs
# tolerancia = 0.01  # Define uma tolerância para o múltiplo
PRIsSORT = np.sort(PRIs)
manter_ordem = np.ones_like(PRIs, dtype=bool)
if len(PRIsSORT) > 1:
    for i in range(len(PRIsSORT) - 1):
        isMultiple = False
        for j in range(i + 1, len(PRIsSORT)):
            quociente = PRIsSORT[j] / PRIsSORT[i]
            quocienteProximo = round(quociente)
            if (abs(quociente - quocienteProximo) * quocienteProximo < (PRIsSORT[i] * 0.1)) and quocienteProximo != 1:  # tolerancia
                isMultiple = True
                break
        if isMultiple:
            manter_ordem[np.where(PRIs == PRIsSORT[j])] = False

picos = picos[manter_ordem]
PRIs = PRIs[manter_ordem]

# Mostrando os PRIs encontrados
print('PRIs encontrados:')
print(PRIs)

# Visualização
plt.figure()
plt.bar(edges[:-1], histCounts, width=binWidth, align='center', alpha=0.7)  # Plota o histograma
plt.plot(PRIs, picos, 'ro')  # Plota os picos encontrados
plt.xlabel('Diferença TOA')
plt.ylabel('Contagem')
plt.title('Histograma das Diferenças de TOA com PRIs Detectados')
plt.show()
