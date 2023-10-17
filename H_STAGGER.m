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
diferencas=diferencas(diferencas<4000);

% Binning das diferenças
binWidth = 0.001 * 10000; % max(diferencas) % largura do bin é 0.5% do valor máximo da diferença
edges = 0:binWidth:10000+binWidth; % define os limites dos bins
histCounts = histcounts(diferencas, edges);

% Procurando os picos no histograma
[picos, locs] = findpeaks(histCounts, 'MinPeakProminence', 3, 'MinPeakHeight', 3); % 'MinPeakDistance', 10 % ajuste conforme necessário
PRIs = edges(locs) + binWidth / 2; % adicionar metade da largura do bin para obter o centro do bin

% Após detectar os PRIs
%tolerancia = 0.001; % Define uma tolerância para o múltiplo
%if length(PRIs)>(find(max(PRIs)))
%for i=(find(max(PRIs))):(length(PRIs)-1)
%    isMultiple = false;
%    for j=((find(max(PRIs)))+1):length(PRIs)
%        quociente = PRIs(j) / PRIs(i);
%        quocienteProximo = round(quociente);
%        %if (abs(quociente - quocienteProximo) < (PRIsSORT(i)*0.0005)) && quocienteProximo~=1 %tolerancia
%        if (abs((PRIs(j) - (quocienteProximo*PRIs(i)))) < (PRIs(i)*0.05)) && quocienteProximo~=1 %tolerancia
%            isMultiple = true;
%        end
%        if isMultiple
%            isMultiple = false;
%            SomaTs=PRIs(i);
%        end
%    end
%end
%end

% Achando os picos até o máximo
STAGGER_PRIs= PRIs(1,1:(find(picos==max(picos))));

%% Verificando se há combinação de soma ts
% Matriz de respostas
P_STAGGER = [];

% Teste para 2 elementos
if length(STAGGER_PRIs)>=3
for i = 1:length(STAGGER_PRIs) - 2
    for j = i+1:length(STAGGER_PRIs) - 1
        soma = STAGGER_PRIs(i) + STAGGER_PRIs(j);
        if abs(soma - STAGGER_PRIs(end)) <= 5
            P_STAGGER = [P_STAGGER; STAGGER_PRIs(i), STAGGER_PRIs(j)];
        end
    end
end
end
% Teste para 3 elementos
if length(STAGGER_PRIs)>=4
for i = 1:length(STAGGER_PRIs) - 3
    for j = i+1:length(STAGGER_PRIs) - 2
        for k = j+1:length(STAGGER_PRIs) - 1
            soma = STAGGER_PRIs(i) + STAGGER_PRIs(j) + STAGGER_PRIs(k);
            if abs(soma - STAGGER_PRIs(end)) <= 5
                P_STAGGER = [P_STAGGER; STAGGER_PRIs(i), STAGGER_PRIs(j), STAGGER_PRIs(k)];
            end
        end
    end
end
end
% Teste para 4 elementos
if length(STAGGER_PRIs)>=5
for i = 1:length(STAGGER_PRIs) - 4
    for j = i+1:length(STAGGER_PRIs) - 3
        for k = j+1:length(STAGGER_PRIs) - 2
            for l = k+1:length(STAGGER_PRIs) - 1
                soma = STAGGER_PRIs(i) + STAGGER_PRIs(j) + STAGGER_PRIs(k) + STAGGER_PRIs(l);
                if abs(soma - STAGGER_PRIs(end)) <= 5
                    P_STAGGER = [P_STAGGER; STAGGER_PRIs(i), STAGGER_PRIs(j), STAGGER_PRIs(k), STAGGER_PRIs(l)];
                end
            end
        end
    end
end
end
% Exibir a matriz de respostas
disp('Emissor STAGGER encontrado de PRIs:');
disp(P_STAGGER);

% Mostrando os PRIs encontrados
%disp('Emissor STAGGER encontrado de PRIs:');
%disp(PRIs);

% Visualização
figure;
bar(edges(1:end-1), histCounts, 'histc'); % Plota o histograma
hold on;
plot(PRIs, picos, 'ro'); % Plota os picos encontrados
xlabel('Diferença TOA');
ylabel('Contagem');
xlim([0 4000]);
title('Histograma das Diferenças de TOA com PRIs Detectados');
