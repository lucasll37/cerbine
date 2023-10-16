%% INPUTs BUFFER e PRIL

% MANUALMENTE - 'A' o buffer de pulsos
%disp('Digite os valores do BUFFER (pressione Enter após cada valor):');
%for i = 1:32
%    A(i) = input(['Digite o valor do elemento ' num2str(i) ': ']);
%end
%disp('BUFFER preenchido');
%disp(A);
% Seja 'PRIL' uma matriz onde cada linha representa (min, max, janela)
%disp('Digite os valores da PRIL (pressione Enter após cada valor):');
%for i = 1:6
%    for j = 1:3
%        PRIL(i, j) = input(['Digite o valor da posição (' num2str(i) ',' num2str(j) '): ']);
%    end
%end
%disp('PRIL preenchido');
%disp(PRIL);

% READ do diretório MATLAB DRIVE
%PRIL = readmatrix("T_PRIL.xlsx");
%BUFFER = readmatrix("TBUFFER.xlsx");

%Se necessário manipular o formato do arquivo txt
%A = round(BUFFER);
%A = A(5:15,1:14);
%A = A(:);
%A = A';
%A = sort(A);

%% RODANDO O PRIL

PRIL = readmatrix("T_PRIL.xlsx");

% Estabelecendo as variáveis para busca
indice_buffer = 1; % Índice do pulso atual para busca no buffer
linha_PRIL = 1; % Índice da linha atual na tabela PRIL

% Inicializando variáveis vazias para trabalhar com elas no script
primeiros_PPI_possiveis = [];
proximos_PPI_condizentes = [];
ameacas_encontradas = [];
   
qtd_pulsos_buffer = numel(A); % Número de pulsos no buffer

while linha_PRIL <= size(PRIL, 1) % Enquanto houver linhas na tabela PRIL
    
    %Buffer menor que tamanho mínimo de busca
    if qtd_pulsos_buffer < 5 
        break
    end
    
    % Intervalo e janela da n-ésima linha do PRIL
    limite_inferior_intervalo_linha_PRIL = PRIL(linha_PRIL, 1);
    limite_superior_intervalo_linha_PRIL = PRIL(linha_PRIL, 2);
    janela_linha_PRIL = PRIL(linha_PRIL, 3);
    
    % Buscas dentro de A com índice i como parâmetro
    while indice_buffer <= (qtd_pulsos_buffer-4)
        % Varrendo A comparando ao PRIL
        for j = (indice_buffer+1):(qtd_pulsos_buffer-3)
            % Seja esta a diferença PPI1 ...
            Dif = A(j) - A(indice_buffer);
            % PPI1 está no intervalo do PRIL?
            if Dif >= limite_inferior_intervalo_linha_PRIL - janela_linha_PRIL && Dif <= limite_superior_intervalo_linha_PRIL + janela_linha_PRIL
                % Se sim, salve-a em um vetor com os TOAs
                primeiros_PPI_possiveis = [primeiros_PPI_possiveis, Dif];
            end
            if Dif > limite_superior_intervalo_linha_PRIL + janela_linha_PRIL
                break
            end
        end
        % Se for não vazio, foi achado ao menos um termo
        if isempty(primeiros_PPI_possiveis) ~= 1
            % Tem-se em PPIS1 todos os TOAs possíveis desse intervalo
            for p=1:length(primeiros_PPI_possiveis)
                % Para cada TOA em PPIS1, buscar-se-á o subsequente em A
                for j = (indice_buffer+2):(qtd_pulsos_buffer-2)
                    % Seja esta a diferença PPI2 ...
                    Dif = A(j) - A(indice_buffer);
                    % PPI2 está no mesmo intervalo de PPI1 novamente?
                    if Dif >= 2*primeiros_PPI_possiveis(p) - janela_linha_PRIL && Dif <= 2*primeiros_PPI_possiveis(p) + janela_linha_PRIL
                        % Se sim, salve-a em um vetor com os TOAs
                        proximos_PPI_condizentes = [proximos_PPI_condizentes, (Dif-primeiros_PPI_possiveis(p))];
                    end
                    if Dif > 2*primeiros_PPI_possiveis(p) + janela_linha_PRIL
                        break
                    end
                end
                % Se for não vazio, foi achado ao menos um novo termo
                if isempty(proximos_PPI_condizentes) ~= 1
                    % Tem-se em PPIS2 todos os TOAs possíveis novamente
                    for q=1:length(proximos_PPI_condizentes)
                        % Inicializando variáveis contadoras
                        contador = [0 0 0];
                        PPI345 = [0 0 0];
                        dev345 = [0 0 0];
                        % Varrendo A para confirmação de PRI
                        for r=3:5
                            % Serão necessários 3 rounds de confirmação
                            % Busca por todo o buffer em cada uma delas
                            for j = (indice_buffer+3):qtd_pulsos_buffer
                                Dif = A(j) - A(indice_buffer);
                                % Se dentro do intervalo e janela
                                % Utilizei Wdw*0.67 por conta da média
                                if (Dif >= (r)*mean(primeiros_PPI_possiveis(p),proximos_PPI_condizentes(q)) - janela_linha_PRIL) && (Dif <= (r)*mean(primeiros_PPI_possiveis(p),proximos_PPI_condizentes(q)) + janela_linha_PRIL)
                                    % Vai salvar o k correspondente
                                    contador(r-2) = contador(r-2) + 1;
                                    % Salva a PPI da posição
                                    PPI345(r-2) =  Dif / (r);
                                    % Salva o deviation
                                    dev345(r-2) = abs( PPI345(r-2) - mean(primeiros_PPI_possiveis(p),proximos_PPI_condizentes(q)) );
                                else
                                    % Quando maior que o intervalo + janela
                                    if (Dif > (r)*mean(primeiros_PPI_possiveis(p),proximos_PPI_condizentes(q)) + janela_linha_PRIL)
                                        % Interrompe o for do buffer
                                        break
                                    end
                                end
                            end
                            % Se a primeira confirmação não der resultado
                            if contador(1)==0
                                % Interrompe a busca
                                break
                            end
                        end
                        % Caso tenho ao menos 2 elementos de k ~=0
                        if sum(contador~=0)>=2
                            PRI = horzcat(primeiros_PPI_possiveis(p),proximos_PPI_condizentes(q),PPI345);
                            DEV = horzcat((proximos_PPI_condizentes(q)-primeiros_PPI_possiveis(p)),dev345);
                            TREM = [A(indice_buffer), mean(PRI(PRI~=0)), mean(DEV(DEV~=0))];
                            ameacas_encontradas = vertcat(ameacas_encontradas,TREM);
                            if size(ameacas_encontradas, 1) > 1
                                % Encontrar índices de PRIs múltiplos
                                maxMultiplo_PRI = TREM(2) / min(ameacas_encontradas(:, 2));
                                indice_PRI_Multiplos = [];
                                for i = 1:(floor(maxMultiplo_PRI)+1)
                                    multiploAtual = TREM(2) / i;
                                    indice_PRI_Multiplos = [indice_PRI_Multiplos; find(abs(ameacas_encontradas(:, 2) - multiploAtual) <= janela_linha_PRIL)];
                                end
                                indice_PRI_Multiplos = indice_PRI_Multiplos(indice_PRI_Multiplos ~= size(ameacas_encontradas, 1));
                                if ~isempty(indice_PRI_Multiplos)
                                    % Remover as linhas correspondentes das ameaças
                                    ameacas_encontradas = ameacas_encontradas(1:end-1, :);
                                end
                            end
                            % Apagar TOAs congruentes
                            % Poderia-se definir uma tolerância de X%
                            % Zerando os valores em A que são próximos o suficiente de TREM
                            indexador=0;
                            while ( TREM(1) + indexador * mean ( PRI ( PRI ~= 0 ) ) ) <= max(A)
                                % Calculando a Diferença entre os termos e os elementos de A
                                Dif = abs( A - ( TREM(1) + (indexador) * mean( PRI ( PRI ~= 0 ) ) ) );
                                % Encontrando os índices dos elementos de dentro de (janela_linha_PRIL*0.34)
                                Ind = find(Dif <= janela_linha_PRIL*0.34 );
                                % Remove os elementos encontrados de A
                                A(Ind) = [];                                
                                indexador = indexador + 1;
                            end
                            % PRI ok, Salvo e Apagado!
                            qtd_pulsos_buffer=numel(A);
                            % Novo tamanho de buffer
                            indice_buffer=1;
                            % Voltando ao i=1 porque apaguei o mesmo
                        end
                        % Caso confirmação falhar
                    end
                    % Acabada a busca dos PPIs condizentes
                end
                % Caso PPIs condizentes vazio
            end
            % Acabada a busca dos PPIs possiveis
            primeiros_PPI_possiveis = [];
            proximos_PPI_condizentes = [];
            PPI345 = [0 0 0];
            dev345 = [0 0 0];
        end
        % Caso PPIs possiveis vazio
            indice_buffer = indice_buffer + 1;
    end
    % Caso em que terminaram as buscas para essa linha do PRIL
    linha_PRIL = linha_PRIL + 1;
    indice_buffer = 1;
end
% Caso em que não há mais n para buscar no PRIL
disp(ameacas_encontradas)