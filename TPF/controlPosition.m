function q = controlPosition(Bichito, q0, Pi, Pf, sheetDimensions, pencilHeight)
%% Parametros del programa
% Dimensiones de la hoja
a = sheetDimensions(2);
b = sheetDimensions(1);

%% Transformación de puntos al sistema global ('0')
% Se toman las coordenadas x e y, y se transforman considerando la posición
% de la hoja respecto al manipulador
% Notación:
% - 0: Global
% - h: Hoja
% - i: Punto inicial de la recta
% - f: Punto final de la recta

xSheet = Pi(1);
ySheet = Pi(2);
piG(1) = -xSheet - Rmedio + a/2;
piG(2) = ySheet - b/2;
piG(3) = 0;
piG = piG';

xSheet = Pf(1);
ySheet = Pf(2);
pfG(1) = -xSheet - Rmedio + a/2;
pfG(2) = ySheet - b/2;
pfG(3) = 0;
pfG = pfG';

%Matriz de rotación, indica la orientación del ee para escribir en la hoja 
%respecto al sistema global
Rh0 = [0 0 -1 
        0 -1 0
        -1 0 0];

%Matriz de transformación del sist global al punto inicial de la línea
Ti0 = [[Rh0' -Rh0' * piG]; [0 0 0 1]]; 
T0i = inv(Ti0);

%Matriz de transformación del sist global al punto final de la línea
Tf0 = [[Rh0' -Rh0' * pfG]; [0 0 0 1]]; 
T0f = inv(Tf0);

end
