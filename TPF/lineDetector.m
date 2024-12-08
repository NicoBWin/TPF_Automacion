%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   lineDetector: Recibe el path del archivo para identificar la linea
%   y si se quiere imprimir imagenes intermedias para mostrar el proceso.
%   Plot = 0 no muestra imagenes intermedias.
%
%   Devuelve las coordenadas de inicio y fin de la recta relativas al
%   tamano de la imagen.
%
%   Devuelve ceros si falla en el procedimiento
%
%   Limitaciones: La recta debe ser roja y no demasiado fina
%                 La imagen debe ser nitida
%                 El encuadre debe ser verde y deben aparecer los cuatro
%                 marcos, de manera nitida y simetricos.
%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [limitCoords] = lineDetector(fileName, plots)

    % Importo la imagen
    im = imread(fileName);
    im_d = idouble(im);
    im_grey = imono(im_d);

    % Obtengo imagen logica de la linea roja
    im_R = im(:, :, 1); % Canal Rojo
    im_G = im(:, :, 2); % Canal Verde
    im_B = im(:, :, 3); % Canal Azul
    im_lineaRoja = im_R > 105 & im_G < 100 & im_B < 100;
    S = ones(8, 8);
    im_lineaRoja = idilate(im_lineaRoja, S, 'none');
    if(plots)
        figure(1)
        idisp(im_lineaRoja);
    end
    
    % Obtengo imagen logica de los bordes de la hoja
    im_hoja = im_grey > 0.12;
    im_bordeshoja = icanny(im_hoja);
    im_bordeshoja= idilate(im_bordeshoja, S, 'none');
    if(plots)
        figure(2)
        idisp(im_bordeshoja);
    end

    % Obtengo imagen logica de la imagen original
    im_todo = im_grey > 0.51;

    % Sacamos la recta y terminamos con solo los marcos y el fondo
    im_todomenoslinea = im_todo | im_lineaRoja;
    if(plots)
        figure(3)
        idisp(im_todomenoslinea);
    end
    % Sacamos el fondo negro
    im_marco = (~(im_todo | im_hoja))|im_todomenoslinea;
    im_marco = im_marco | im_bordeshoja;
    if(plots)
        figure(4)
        idisp(im_marco);
    end

    % Obtengo los bordes de la imagen
    fail = 0;
    try
        bordes_h = icanny(im_marco);
        S = ones(4,4);
        bordes_h = idilate(bordes_h,S);
        h = Hough(bordes_h, 'houghthresh', 0.5, 'suppress', 30);    %0.45 33
        lineas = h.lines();

        if(plots)
            figure(5)
            idisp(bordes_h);
            lineas.plot('r--')
        end

        % Obtengo las coordenadas de las puntas de la imagen
        warped_coords = [];
        for i = 1:length(lineas.rho)-1
            for j = (i+1):length(lineas.rho)
                warped_coords = [warped_coords, intersecciones(lineas(i), lineas(j), im_marco)];
            end
        end
        [H, W] = size(im_marco);
        warped_coords = round(warped_coords);
        warped_coords = warped_coords';
        warped_coords = warped_coords(:, [2, 1]);
        warped_coords = ordenarVertices(warped_coords, W, H);

        % Warpeo la imagen
        % Coordenadas de los puntos destino (esquinas ideales de la imagen)
        destination_coords = [1, 1;              
                          1, H;           
                          W , 1;            
                          W, H];       
        % Calcular la transformación homográfica
         tform = fitgeotrans(warped_coords, destination_coords, 'projective');

        % Warpear la imagen
        im_warpeada_l = imwarp(im_lineaRoja, tform, 'OutputView', imref2d([H W]));
        im_warpeada = imwarp(im, tform, 'OutputView', imref2d([H W]));
         S = ones(10,10);
        im_warpeada_l = iopen(im_warpeada_l,S);

        if(plots)
            figure(6)
            idisp(im_warpeada);
            figure(7)
            idisp(im_warpeada_l);
        end

        extremos = icorner(im_warpeada_l, 'detector','harris','sigma',5, 'edgegap',1,'supress',1, 'nfeat', 2);

        u = extremos.u;
        v = extremos.v;

        coord_A = [u(1), v(1)];
        coord_B = [u(2), v(2)];

        coord_A_ratio = [u(1)/W, v(1)/H];
        coord_B_ratio = [u(2)/W, v(2)/H];

        % Mostrar resultados
        figure('Name', 'Line Detector');
        idisp(im_warpeada_l);
        hold on;
        plot([coord_A(1) coord_B(1)], [coord_A(2) coord_B(2)], 'r', 'LineWidth', 1);
        hold off;    

        limitCoords = zeros(2);
    catch 
         fail = 1;
    end
    
    if ~fail
        for i = 1:length(coord_A_ratio)
            limitCoords(i,1) = coord_A_ratio(i);
            limitCoords(i,2) = coord_B_ratio(i);
        end
    else 
        for i = 1:2
            limitCoords(i,1) = 0;
            limitCoords(i,2) = 0;
        end
    end
end
 
function punto = intersecciones(lineaA, lineaB, im)
    [v,u] = size(im);
    rhoA = lineaA.rho;
    rhoB = lineaB.rho;
    thetaA = lineaA.theta;
    thetaB = lineaB.theta;

    % Armo el sistema de ecuaciones
    A = [cos(thetaA), sin(thetaA); cos(thetaB), sin(thetaB)];
    B = [rhoA; rhoB];

    % Resuelvo el sistema
    punto = A \ B;

    if punto(1) > v || punto(2) > u || any(punto < 0)
        punto = [];
    end
end    


function sorted_points = ordenarVertices(puntos, W, H)
    % puntos: matriz 4x2 con las coordenadas (x, y) de los puntos.
    % W, H: ancho y alto de la imagen.
    % Definir las esquinas ideales
    esquinas = [1, 1;      % Esquina superior izquierda
                1, H;      % Esquina inferior izquierda
                W, 1;      % Esquina superior derecha
                W, H];     % Esquina inferior derecha

    % Generar todas las permutaciones posibles de los puntos
    permutaciones = perms(1:4);
    num_perms = size(permutaciones, 1);
    
    % Inicializar el error mínimo y la mejor asignación
    min_ecm = inf;
    mejor_asignacion = [];

    % Evaluar el ECM para cada permutación
    for i = 1:num_perms
        perm = permutaciones(i, :);
        puntos_permutados = puntos(perm, :);
        
        % Calcular el error cuadrático medio para esta permutación
        errores = sqrt(sum((puntos_permutados - esquinas).^2, 2));
        ecm = mean(errores.^2);
        
        % Actualizar si se encuentra un menor ECM
        if ecm < min_ecm
            min_ecm = ecm;
            mejor_asignacion = puntos_permutados;
        end
    end

    % Devolver la mejor asignación encontrada
    sorted_points = mejor_asignacion;
end


