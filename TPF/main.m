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
sheetDimensions = [150, 200];
% Vértice origen de la hoja (respecto a la base del Bichito)
sheetApex = [-100, 400, 65];
% Posición Inicial
q0 = deg2rad([90, 52.5, -75, -120, 0]);

%% Obtener Imagen
[name,path]=uigetfile({'*.png;*.jpg;*.jpeg'});
fileName=strcat(path,name);
clear path name

%% Configuración y creación del Robot
[Bichito] = robotCreate(q0);
%figure()
%Bichito.teach(q0)

% Mesa de trabajo
table_start = [-100, 400, 65];    % Posición del borde de la hoja (mm)
table_end = [100, 250, 65];       % Posición en diagonal a la posición anterior
%dibujarMesa(table_start, table_end);
%Bichito.teach(q0)

%% Espacio de trabajo 
[rMax,rMin] = workSpace(Bichito, q0, sheetDimensions);

%% Análisis de imagén
limitCoords = lineDetector(fileName,1);
limitCoords(1) = round(limitCoords(1)*sheetDimensions(2)) - 100;
limitCoords(2) = 400 - round(limitCoords(2)*sheetDimensions(1)); 
limitCoords(3) = round(limitCoords(3)*sheetDimensions(2)) - 100;
limitCoords(4) = 400 - round(limitCoords(4)*sheetDimensions(1));  
%% Trayectoria
movimiento = controlPosition(Bichito, q0, limitCoords, sheetDimensions, pencilHeight);
