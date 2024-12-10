function q = controlPosition(Bichito, radios, q0, limitCoords, sheetDimensions, pencilHeight)
    %% Parametros del programa
    % Dimensiones de la hoja
    sheetWidth = sheetDimensions(2);
    sheetLength = sheetDimensions(1);
    
    % Area de trabajo
    rMin = radios(1);
    rMax = radios(2);
    Rmedio = abs(((rMax - rMin)/2) + rMin); % Si quiero que la hoja este fija, pongo Rmedio = 275
    
    % Numero de puntos intermedios a calcular en una trayectoria ctraj
    N = 15;

    %% Dibujamos el cuadrado de trabajo
    figure('Name','Trayectoria');
    Bichito.plot(q0,'trail',{'r', 'LineWidth', 1,'LineStyle','--'});
    rectangle('Position', [(-sheetLength / 2) (Rmedio - sheetWidth/2) sheetLength sheetWidth], 'EdgeColor', 'b'); 
    hold on

    %% Transformación de puntos al sistema global del actuador
    %LINE INIT
    xSheet = limitCoords(1);
    ySheet = limitCoords(2);
    pi(1) = xSheet - sheetLength/2;
    pi(2) = -ySheet + Rmedio + sheetWidth/2;
    pi(3) = pencilHeight;
    pi = pi';

    %LINE END
    xSheet = limitCoords(3);
    ySheet = limitCoords(4);
    pf(1) = xSheet - sheetLength/2;
    pf(2) = -ySheet + Rmedio + sheetWidth/2;
    pf(3) = pencilHeight;
    pf = pf';

    % Relación EE/Sist. Global
    Rh0 = [0 0 1 
           0 1 0
           1 0 0];

    % Matriz de transformación Sist. Global/pi
    Ti0 = [[Rh0' -Rh0' * pi]; [0 0 0 1]]; 
    T0i = inv(Ti0);

    % Matriz de transformación Sist. Global/pf
    Tf0 = [[Rh0' -Rh0' * pf]; [0 0 0 1]]; 
    T0f = inv(Tf0);
    
    %% 1 - Posicionamiento por encima del pi con pencilHeight
    % Agrego un offset para acercar el EE mas lento
    T0i_of = T0i;
    T0i_of(3,4) = T0i_of(3,4) + 10;

    T_q0 = Bichito.fkine(q0);
    T0 = ctraj(T_q0,SE3(T0i_of),N);
    q{1} = Bichito.ikine(T0, q0, 'mask', [1 1 1 0 1 1],'q0',q0);
    Bichito.plot(q{1},'trail',{'r', 'LineWidth', 1,'LineStyle','--'});


    %% 2- Acercamiento a la hoja
    T0 = ctraj(SE3(T0i_offset),SE3(T0i),N);
    q{2} = Bichito.ikine(T0, q{1}(end,:), 'mask', [1 1 1 0 1 1],'q0',q{1}(end,:));
    Bichito.plot(q{2},'trail',{'r', 'LineWidth', 1,'LineStyle','--'});

    %% 3- Dibujo de la recta 
    T1 = ctraj(SE3(T0i),SE3(T0f),N);
    q{3} = Bichito.ikine(T1, q{2}(end,:), 'mask', [1 1 1 0 1 1],'q0',q{2}(end,:));
    Bichito.plot(q{3},'trail',{'b', 'LineWidth', 2});

    translVecX = zeros(size(T1)); translVecY = zeros(size(T1)); translVecZ = zeros(size(T1));
    for i = 1:size(T1,2)
        aux = T1(i).double;
        translVecX(i) = aux(1,end);
        translVecY(i) = aux(2,end);
        translVecZ(i) = aux(3,end);
    end
    plot3(translVecX,translVecY,translVecZ,'-r');
    hold on

    %% 4- Alejamineto de la hoja
    T0f_offset = T0f;
    T0f_offset(3,4) = T0f_offset(3,4) + 10;

    T2 = ctraj(SE3(T0f),SE3(T0f_offset),N);
    q{4} = Bichito.ikine(T2, q{3}(end,:), 'mask', [1 1 1 0 1 1],'q0',q{3}(end,:));
    Bichito.plot(q{4},'trail',{'r', 'LineWidth', 1,'LineStyle','--'});

    %% 5- Vuelta a posicion original
    T3 = ctraj(SE3(T0f_offset),T_q0,N);
    q{5} = Bichito.ikine(T3, q{4}(end,:), 'mask', [1 1 1 0 1 1],'q0',q{4}(end,:));
    Bichito.plot(q{5},'trail',{'r', 'LineWidth', 1,'LineStyle','--'});
    
    
    %% Ploteo la trayectoria real vs. la recta obtenida por vision
    
    xLine = linspace(pi(1), pf(1), 100); % Puntos de la recta en x
    yLine = linspace(pi(2), pf(2), 100); % Puntos de la recta en y

    % Graficar la trayectoria
    figure;
    plot(translVecX, translVecY, 'b-', 'LineWidth', 1.5); % Trayectoria en azul
    hold on;
    plot(xLine, yLine, 'r--', 'LineWidth', 1.5); % Recta en rojo
    
    rectangle('Position', [(-sheetLength / 2) (Rmedio - sheetWidth/2) sheetLength sheetWidth], 'EdgeColor', 'b');
    
    xlim([-150, 150]);
    ylim([150, 400]);

    % Estética del gráfico
    xlabel('X [m]');
    ylabel('Y [m]');
    title('Trayectoria vs. recta');
    legend('Trayectoria', 'Recta');
    grid on;

end
