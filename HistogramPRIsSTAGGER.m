% Calculando as diferenças entre cada par de TOAs
%diferencas = [];
%for i = 1:length(A)
%    for j = i+1:length(A)
%        diferencas = [diferencas, A(j) - A(i)];
%    end
%end
diferencas = pdist(A.');

% Existe um PRI máximo limitado na geração de ameaças
% Logo vamos limitar também aqui para diminuir o esforço computacional
diferencas=diferencas(diferencas<1000);

% Binning das diferenças
binWidth = 0.005 * max(diferencas); % largura do bin é 1% do valor máximo da diferença
edges = 0:binWidth:max(diferencas)+binWidth; % define os limites dos bins
histCounts = histcounts(diferencas, edges);

% Procurando os picos no histograma
[picos, locs] = findpeaks(histCounts, 'MinPeakProminence', 5, 'MinPeakHeight', 10, 'SortStr', 'ascend', 'MinPeakDistance', 5); % ajuste conforme necessário
PRIs = edges(locs) + binWidth / 2; % adicionar metade da largura do bin para obter o centro do bin

% Após detectar os PRIs
%tolerancia = 0.01; % Define uma tolerância para o múltiplo
PRIsSORT=sort(PRIs);
manter_ordem = true(size(PRIs));
if length(PRIsSORT)>1
for i=1:(length(PRIsSORT)-1)
    isMultiple = false;
    for j=(i+1):length(PRIsSORT)
        quociente = PRIsSORT(j) / PRIsSORT(i);
        quocienteProximo = round(quociente);
        if (abs(quociente - quocienteProximo)*quocienteProximo < (PRIsSORT(i)*0.1)) && quocienteProximo~=1 %tolerancia
            isMultiple = true;
            break;
        end
    end
    if isMultiple
        manter_ordem(PRIs == PRIsSORT(j)) = false;
    end
end
end
picos = picos(manter_ordem);
PRIs = PRIs(manter_ordem);

% Mostrando os PRIs encontrados
disp('PRIs encontrados:');
disp(PRIs);

% Visualização
figure;
bar(edges(1:end-1), histCounts, 'histc'); % Plota o histograma
hold on;
plot(PRIs, picos, 'ro'); % Plota os picos encontrados
xlabel('Diferença TOA');
ylabel('Contagem');
title('Histograma das Diferenças de TOA com PRIs Detectados');
