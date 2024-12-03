function [limitCoords] = lineDetector(fileName)

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
    figure(1)
    idisp(im_lineaRoja);

    % Obtengo imagen logica de los bordes de la hoja
    im_hoja = im_grey > 0.12;
    im_bordeshoja = icanny(im_hoja);
    im_bordeshoja= idilate(im_bordeshoja, S, 'none');
    figure(2)
    idisp(im_bordeshoja);

    % Obtengo imagen logica de la imagen original
    im_todo = im_grey > 0.5;

    % Sacamos la recta y terminamos con solo los marcos y el fondo
    im_todomenoslinea = im_todo | im_lineaRoja;
    figure(3)
    idisp(im_todomenoslinea);

    % Sacamos el fondo negro
    im_marco = (~(im_todo | im_hoja))|im_todomenoslinea;
    im_marco = im_marco | im_bordeshoja;
    figure(4)
    idisp(im_marco);

    % Obtengo los bordes de la imagen
    bordes_h = icanny(im_marco);
    h = Hough(bordes_h, 'houghthresh', 0.55, 'suppress', 10);
    lineas = h.lines();
    figure(5)
    idisp(bordes_h);
    lineas.plot('r--')

    % Obtengo las coordenadas de las puntas de la imagen
    warped_coords = [];
    for i = 1:length(lineas.rho)-1
        for j = (i+1):length(lineas.rho)
            warped_coords = [warped_coords, intersecciones(lineas(i), lineas(j), im_marco)];
        end
    end
    warped_coords = round(warped_coords);
    warped_coords = warped_coords';
    warped_coords = warped_coords(:, [2, 1]);

    % Warpeo la imagen
    % Coordenadas de los puntos destino (esquinas ideales de la imagen)
    [H, W] = size(im_marco);
    destination_coords = [W, H;              
                      1, H;           
                      W, 1;            
                      1, 1];       

    % Calcular la transformación homográfica
    tform = fitgeotrans(warped_coords, destination_coords, 'projective');

    % Warpear la imagen
    im_warpeada_l = imwarp(im_lineaRoja, tform, 'OutputView', imref2d([H W]));
    im_warpeada = imwarp(im, tform, 'OutputView', imref2d([H W]));

    figure(6)
    idisp(im_warpeada);
    figure(7)
    idisp(im_warpeada_l);

    extremos = icorner(im_warpeada_l, 'detector','harris','sigma',5,'cmin', 0.005, 'edgegap',1,'supress',1, 'nfeat', 2);

    coord_A = coord_strvect(extremos(2).char());
    coord_B = coord_strvect(extremos(1).char());

    % Mostrar resultados
    imshow(im_warpeada);
    hold on;
    plot([coord_A(1) coord_B(1)], [coord_A(2) coord_B(2)], 'r', 'LineWidth', 1);
    hold off;    

    limitCoords = zeros(2);
    for i = 1:length(coord_A)
        limitCoords(i,1) = coord_A(i);
        limitCoords(i,2) = coord_B(i);
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

function coordenada_double = coord_strvect(coord_string)
    % Del string que llega, se queda con la info hasta el )
    coord_string = extractBefore(coord_string, ')') ;

    % Elimina tambien el '('. Queda el string ' x,y'
    coord_string = strrep(coord_string, '(', ''); 

    % Elimina los espacios en blanco al ppio y al final. Queda 'x,y'
    coord_string = strtrim(coord_string);

    % Genera un double con la coordenada, [x,y]
    coordenada_double = str2double(split(coord_string, ','));
end
