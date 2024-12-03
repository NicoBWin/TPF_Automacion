function q = controlPosition(bicho, radios, q0, limitCoords, sheetDimensions, pencilHeight)
    %% Parametros del programa
    % Dimensiones de la hoja
    a = sheetDimensions(2);
    b = sheetDimensions(1);
    
    % Area de trabajo
    Rmax = radios(1);
    Rmin = radios(2);
    Rmedio = abs((radios(1) - radios(2))/2) + radios(1);
    
    % Numero de puntos intermedios a calcular en una trayectoria
    N = 30;

    %% Dibujamos el cuadrado de trabajo
    figure('Name','Trayectoria');
    bicho.plot(q0,'trail',{'r', 'LineWidth', 1,'LineStyle','--'});
    rectangle('Position', [(-b / 2) ((Rmax - Rmin) / 2 + Rmin + a / 2) b a], 'EdgeColor', 'b'); 
    hold on

    %% Transformación de puntos al sistema global del actuador
    %LINE INIT
    xSheet = limitCoords(1);
    ySheet = limitCoords(2);
    piG(1) = -xSheet - Rmedio + a/2;
    piG(2) = ySheet - b/2;
    piG(3) = 0;
    piG = piG';

    %LINE END
    xSheet = limitCoords(3);
    ySheet = limitCoords(4);
    pfG(1) = -xSheet - Rmedio + a/2;
    pfG(2) = ySheet - b/2;
    pfG(3) = 0;
    pfG = pfG';

    % Matriz de rotación, indica la orientación del ee 
    %para escribir en la hoja respecto al sistema global
    Rh0 = [0 0 -1 
           0 -1 0
          -1 0 0];

    %Matriz de transformación del S.G. al punto inicial de la línea
    Ti0 = [[Rh0' -Rh0' * piG]; [0 0 0 1]]; 
    T0i = inv(Ti0);

    %Matriz de transformación del S.G. al punto final de la línea
    Tf0 = [[Rh0' -Rh0' * pfG]; [0 0 0 1]]; 
    T0f = inv(Tf0);
    
    %% 1 - Posicionamiento del robot por encima de pi con pencilHeight
    %Agrego el offset para acercar el ee
    T0i_offset = T0i;
    T0i_offset(3,4) = T0i_offset(3,4) + pencilHeight;

    T_q0 = bicho.fkine(q0);
    T0 = ctraj(T_q0,SE3(T0i_offset),N);
    q{1} = bicho.ikine(T0, q0, 'mask', [1 1 1 0 1 1],'q0',q0);
    bicho.plot(q{1},'trail',{'r', 'LineWidth', 1,'LineStyle','--'});


    %% 2- Approach a la hoja (se baja pencilHeight)
    T0 = ctraj(SE3(T0i_offset),SE3(T0i),5);
    q{2} = bicho.ikine(T0, q{1}(end,:), 'mask', [1 1 1 0 1 1],'q0',q{1}(end,:));
    bicho.plot(q{2},'trail',{'r', 'LineWidth', 1,'LineStyle','--'});

    %% 3- Dibujo la recta que une los puntos ingresados 
    T1 = ctraj(SE3(T0i),SE3(T0f),N);
    q{3} = bicho.ikine(T1, q{2}(end,:), 'mask', [1 1 1 0 1 1],'q0',q{2}(end,:));
    bicho.plot(q{3},'trail',{'b', 'LineWidth', 2});

    translVecX = zeros(size(T1)); translVecY = zeros(size(T1)); translVecZ = zeros(size(T1));
    for i = 1:size(T1,2)
        aux = T1(i).double;
        translVecX(i) = aux(1,end);
        translVecY(i) = aux(2,end);
        translVecZ(i) = aux(3,end);
    end
    plot3(translVecX,translVecY,translVecZ,'-r');
    hold on

    %% 4- Retiramos de la hoja (subo pencilHeight)
    T0f_offset = T0f;
    T0f_offset(3,4) = T0f_offset(3,4) + pencilHeight;

    T2 = ctraj(SE3(T0f),SE3(T0f_offset),5);
    q{4} = bicho.ikine(T2, q{3}(end,:), 'mask', [1 1 1 0 1 1],'q0',q{3}(end,:));
    bicho.plot(q{4},'trail',{'r', 'LineWidth', 1,'LineStyle','--'});

    %% 5- Vuelvo a la posicion original
    T3 = ctraj(SE3(T0f_offset),T_q0,N);
    q{5} = bicho.ikine(T3, q{4}(end,:), 'mask', [1 1 1 0 1 1],'q0',q{4}(end,:));
    bicho.plot(q{5},'trail',{'r', 'LineWidth', 1,'LineStyle','--'});
    
end
