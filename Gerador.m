%% Gerador de Ameaças (Emissores)

% Tipo de Emissores
% 1 - Somente STABLE
% 2 - Somente STAGGER
% 3 - STABLE e STAGGER
% 4 - Somente JITTER
% 5 - STABLE, STAGGER e JITTER
tipoEmissores=1;

%formato numérico apenas
format shortG

% Quantidade Máx de Emissores STABLE
qtdSTABLE=0;
% Quantidade Máx de Emissores STAGGER
qtdSTAGGER=0;
% Tipo STAGGER
% 1 - t1, t2
% 2 - t1, t2, t3
% 3 - t1, t2, t3, t4
tipoSTAGGER=1;
% Quantidade Máx de Emissores JITTER
qtdJITTER=0;
% TipoJITTER
% 1 - 2%
% 2 - 4%
% 3 - 8%
% 4 - 12%
% 5 - 16%
tipoJITTER=1;

%% Gerar Manualmente

tipoEmissores=input('Tipo de Emissores:1 - Somente STABLE - 2 - Somente STAGGER - 3 - STABLE e STAGGER - 4 - Somente JITTER - 5 - STABLE, STAGGER e JITTER\nPor favor, insira um número de 1 a 5: ');
while floor(tipoEmissores) ~= tipoEmissores || tipoEmissores <= 0
    tipoEmissores = input('Por favor, insira um número de 1 a 5:');
    if floor(tipoEmissores) ~= tipoEmissores || tipoEmissores <= 0
        disp('Entrada inválida. O número deve ser um inteiro positivo de 1 a 5.')
    end
end

if tipoEmissores==1 || tipoEmissores==3 || tipoEmissores==5
    qtdSTABLE=input('Por favor, insira a quantidade de emissores STABLE:');
    while floor(qtdSTABLE) ~= qtdSTABLE || qtdSTABLE <= 0
        qtdSTABLE = input('Por favor, insira um número um inteiro positivo:');
        if floor(qtdSTABLE) ~= qtdSTABLE || qtdSTABLE <= 0
            disp('Entrada inválida. O número deve ser um inteiro positivo.')
        end
    end
end

if tipoEmissores==2 || tipoEmissores==3 || tipoEmissores==5
    qtdSTAGGER=input('Insira a quantidade de emissores STAGGER:');
    while floor(qtdSTAGGER) ~= qtdSTAGGER || qtdSTAGGER <= 0
        qtdSTAGGER = input('Por favor, insira um número um inteiro positivo:');
        if floor(qtdSTAGGER) ~= qtdSTAGGER || qtdSTAGGER <= 0
            disp('Entrada inválida. O número deve ser um inteiro positivo.')
        end
    end
    tipoSTAGGER=input('Insira o tipo do(s) emissore(s) STAGGER: 1 - t1 e t2 - 2 - t1 , t2 e t3 - 3 - t1 , t2 , t3 e t4');
    while floor(tipoSTAGGER) ~= tipoSTAGGER || tipoSTAGGER <= 0
        tipoSTAGGER = input('Por favor, insira um número de 1 a 3:');
        if floor(tipoSTAGGER) ~= tipoSTAGGER || tipoSTAGGER <= 0
            disp('Entrada inválida. O número deve ser um inteiro positivo de 1 a 3.')
        end
    end
end

if tipoEmissores==4 || tipoEmissores==5
    qtdJITTER=input('Por favor, insira a quantidade de emissores JITTER:');
    while floor(qtdJITTER) ~= qtdJITTER || qtdJITTER <= 0
        qtdJITTER = input('Por favor, insira um número um inteiro positivo:\n');
        if floor(qtdJITTER) ~= qtdJITTER || qtdJITTER <= 0
            disp('Entrada inválida. O número deve ser um inteiro positivo.')
        end
    end
    tipoJITTER=input('Insira o tipo do(s) emissore(s) JITTER:1 - 2% - 2 - 4% - 3 - 8% - 4 - 12% - 5 - 16%');
    while floor(tipoJITTER) ~= tipoJITTER || tipoJITTER <= 0
        tipoJITTER = input('Por favor, insira um número de 1 a 5:');
        if floor(tipoJITTER) ~= tipoJITTER || tipoJITTER <= 0
            disp('Entrada inválida. O número deve ser um inteiro positivo de 1 a 5.')
        end
    end
end

%% Inicializando

% Listagem salva para posterior comparação
ListaSTABLE=zeros(qtdSTABLE,3);
ListaSTAGGER=zeros(qtdSTAGGER,(tipoSTAGGER+3));
ListaJITTER=zeros(qtdJITTER,3);

% Inicializar Variável A Buffer
A=[];

% Todos PRIs
TodosPRIs = 50:1000; % Variam de 10us a 1000us

%% Gerando STABLE
if tipoEmissores==1 || tipoEmissores==3 || tipoEmissores==5

    % TOAs e PRIs STABLE

    % Verificação da condição de diferença de 10us
    condicaoSatisfeita = false;
    while ~condicaoSatisfeita
        PRIsCONDICAO = TodosPRIs(randperm(length(TodosPRIs), qtdSTABLE));
        % Verifica se a diferença mínima entre quaisquer dois valores é pelo menos 10us
        if all(pdist(PRIsCONDICAO.')>= 10)  || qtdSTABLE==1
            condicaoSatisfeita = true;
        end
    end
    TzerosSTABLE = randi([0, 5000], 1, qtdSTABLE); % Até 5000
    PRIsSTABLE = PRIsCONDICAO;
    ListaSTABLE = zeros(qtdSTABLE, 3);
    for i=1:qtdSTABLE
        ListaSTABLE(i,:) = [TzerosSTABLE(i), PRIsSTABLE(i), 0];
    end

    % Gerar parcial Buffer STABLE
    deviation=[];
    for j=1:qtdSTABLE
        for k=1:101 % Gerando até 100 pulsos (se couber no buffer)
            if TzerosSTABLE(j)+k*PRIsSTABLE(j)<=50000
                A = [A, TzerosSTABLE(j)+ (k-1)*PRIsSTABLE(j)+ round(random('Normal',0,1))];
                % Margem de erro de leitura do TOA apenas para o STABLE
                deviation=[deviation,(A(end)-(TzerosSTABLE(j)+((k-1)*PRIsSTABLE(j))))];
            else
                break
            end
        end
        % Inserir o deviation médio (para STABLE, apenas erros gerados randômicos)
        ListaSTABLE(j,3)=mean(deviation);
        deviation=[];
    end
end

%% Gerando STAGGER
if tipoEmissores==2 || tipoEmissores==3 || tipoEmissores==5

    % TOAs e PRIs STAGGER
    PRIsSTAGGER = zeros(1, (tipoSTAGGER+1));
    %ListaSTAGGER = zeros(1, (tipoSTAGGER+3));
    for i=1:qtdSTAGGER
        TzerosSTAGGER(i) = randi([0, 5000]); % Até 5000us
        tempos_unicos = zeros(1, (tipoSTAGGER+1));
        for p = 1:(tipoSTAGGER+1)
            uniqueNum = false;
            while ~uniqueNum
                % Gerando um número aleatório para cada t STAGGER
                num = randi([10, 1000]);
                % Verifica se o número já existe ts diferentes
                if ~ismember(num, tempos_unicos) && all(abs(num-tempos_unicos)>50)
                    uniqueNum = true;
                    tempos_unicos(p) = num;
                end
            end
        end
        PRIsSTAGGER(i,:) = tempos_unicos; % Até 1000us    
        ListaSTAGGER(i,:)=[TzerosSTAGGER(i),PRIsSTAGGER(i,:),0];
    end

    % Gerar parcial Buffer STAGGER
    deviation=[];
    for j=1:qtdSTAGGER
        B(1) = TzerosSTAGGER(j);  % Primeiro elemento de B
        %deviation=[deviation,(B(i)-TzerosSTAGGER(j))];
        p_idx=1; % indexador MOD tipo STAGGER
        for i = 2:100  % Iterar de 2 até 101
            B(i) = (B(i-1) + PRIsSTAGGER(j,p_idx) + round(random('Normal',0,1)));  % Adicionar um novo elemento a B
            % Margem de erro de leitura do TOA apenas para o STAGGER
            deviation=[deviation,(B(end)-(B(i-1) + PRIsSTAGGER(j,p_idx)))];
            % Atualizar os índices
            p_idx = mod(p_idx, (tipoSTAGGER+1)) + 1;
            if B(i) + PRIsSTAGGER(j,p_idx)>50000
                break
            end
        end
        A = [A, B];
        % Inserir o deviation médio (para STAGGER, apenas erros gerados randômicos)
        ListaSTAGGER(j,(tipoSTAGGER+3))=mean(deviation);
        deviation=[];
    end
end

%% Gerando JITTER
if tipoEmissores==4 || tipoEmissores==5

    % TOAs e PRIs JITTER

    % Verificação da condição de diferença de 10us
    condicaoSatisfeita = false;
    while ~condicaoSatisfeita
        PRIsCONDICAO = TodosPRIs(randperm(length(TodosPRIs), qtdJITTER));
        % Verifica se a diferença mínima entre quaisquer dois valores é pelo menos 10us
        if all(pdist(PRIsCONDICAO.')>= 10)  || qtdJITTER==1
            condicaoSatisfeita = true;
        end
    end
    TzerosJITTER = randi([0, 5000], 1, qtdJITTER); % Até 5000
    PRIsJITTER = PRIsCONDICAO;
    ListaJITTER = zeros(qtdJITTER, 3);
    for i=1:qtdJITTER
        ListaJITTER(i,:) = [TzerosJITTER(i), PRIsJITTER(i), 0];
    end

    % idx por tipo_jitter
    idxJITTER=[1,0.02;2,0.04;3,0.08;4,0.12;5,0.16];

    % Gerar parcial Buffer JITTER
    deviation=[];
    for j=1:qtdJITTER
        jit=floor(PRIsJITTER(j)*idxJITTER(tipoJITTER,2));
        for k=1:101 % Gerando até 100 pulsos (se couber no buffer)
            if TzerosJITTER(j)+k*PRIsJITTER(j)<=50000
                intervaloJITTER=[ceil(PRIsJITTER(j)-jit) floor(PRIsJITTER(j)+jit)];
                A = [A, TzerosJITTER(j) + (k-1)*(intervaloJITTER(1) + round((intervaloJITTER(2)-intervaloJITTER(1))*rand))];
                % Margem de erro de leitura do TOA apenas para o STABLE
                deviation=[deviation,(A(end)-(TzerosJITTER(j)+ round((k-1)*PRIsJITTER(j))))];
            else
                break
            end
        end
        % Inserir o deviation médio (para STABLE, apenas erros gerados randômicos)
        ListaJITTER(j,3)=mean(deviation);
        deviation=[];
    end
end

%% Resposta em tela e dados

A = sort(A);
disp(ListaSTABLE)
disp(ListaSTAGGER)
disp(ListaJITTER)