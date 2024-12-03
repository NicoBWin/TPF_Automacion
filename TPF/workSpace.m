function radios = workSpace(Bichito, q0, sheetDimensions)
    %% Graficar Espacio de Trabajo
    figure('Name', 'Mesa de Trabajo');

    % Posición Inicial
    Bichito.plot(q0);
    hold on;

    % Número de Links
    Nlinks = size(Bichito.links, 2);

    % Array de ángulos
    theta = cell(1, Nlinks);

    N = 4;
    for i = 1:Nlinks
        limiteInf = Bichito.qlim(i, 1);
        limiteSup = Bichito.qlim(i, 2);
        if i == 1
            theta{i} = linspace(limiteInf, limiteSup, 4*N);
        else
            theta{i} = linspace(limiteInf, limiteSup, N);
        end
    end

    %% Cálculos
    % Matriz de Espacio de Trabajo
    [grid1, grid2, grid3, grid4, grid5] = ndgrid(theta{1}, theta{2}, theta{3}, theta{4}, theta{5});
    q = [grid1(:), grid2(:), grid3(:), grid4(:), grid5(:)];

    T = double(Bichito.fkine(q));
    pos = T(1:3,4,:);
    pos = reshape(pos,3,[]);
    pos = pos';

    % Limitaciones físicas ("Mesa")
    zSupPos = pos(pos(:,3) >= 0 & pos(:,2) > 0,:);

    scatter3(zSupPos(:,1), zSupPos(:,2), zSupPos(:,3),4, 'blue', 'filled');
    hold on;
    
    rMax = max(abs(zSupPos(:,2)));
    rMin = min(abs(zSupPos(5,2)));
    radios = [rMin, rMax];

    a = sheetDimensions(2);
    b = sheetDimensions(1);
    
    circle([0 0],rMax); % Círculo externo
    circle([0 0],rMin); % Círculo interno
    rectangle('Position', [(-b / 2) ((rMax - rMin) / 2 + rMin - a / 2) b a]);
    hold on
end