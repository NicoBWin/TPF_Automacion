%% TP Final Automación Industrial 
% Diciembre 2024
%
% Alvarez, Matías Ezequiel  - 62275
% Bustelo, Nicolás          - 61431
% Galán, Albertina          - 61665
% Ibañez, Lucía             - 62488

close all; clear; clc

%% Dimensiones Iniciales
% Altura del lapiz
pencilHeight = 10;
% Dimensiones de la hoja
sheetDimensions = [200, 150];
% Posición Inicial
q0 = deg2rad([90, 52.5, -75, -120, 0]);

%% Obtener Imagen
[name,path]=uigetfile({'*.png;*.jpg;*.jpeg'});
fileName=strcat(path,name);
clear path name

%% Configuración y creación del Robot
[Bichito] = robotCreate(q0);

%% Espacio de trabajo 
radios = workSpace(Bichito, q0, sheetDimensions);

%% Análisis de imagén
limitCoords = lineDetector(fileName,0);
limitCoords(1) = round(limitCoords(1)*sheetDimensions(1));
limitCoords(2) = round(limitCoords(2)*sheetDimensions(2));
limitCoords(3) = round(limitCoords(3)*sheetDimensions(1));
limitCoords(4) = round(limitCoords(4)*sheetDimensions(2)); 

%% Control del movimiento
if all(limitCoords == 0)
    disp('Hay un problema bro, sry...');
else
    disp('Linea detecteda...');
    % Movimiento
    motion = controlPosition(Bichito, radios, q0, limitCoords, sheetDimensions, pencilHeight);

    %% Gráfico
    plotter(Bichito, motion);
end
