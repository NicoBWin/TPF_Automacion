%% TP Final Automación Industrial
% Alvarez, Matías Ezequiel  - 62275
% Bustelo, Nicolás          - 61431
% Galán, Albertina          - 61665
% Ibañez, Lucía             - 62488

close all; clear; clc
%% Dimensiones Iniciales
% Altura del lapiz
pencil_height = 15;

% Dimensiones de la hoja
sheet_dimensions = [200, 150];

% Vértice origen de la hoja (respecto a la base del Bichito)
sheet_apex = [-100, 50, 0];

% Posición Inicial
q0 = deg2rad([90, 52.5, -75, -120, 0]);

%% Obtener Imagen
% [name,path]=uigetfile({'*.png;*.jpg;*.jpeg'});
% Fname=strcat(path,name);
% clear path name

%% Configuración del Robot

% Creacion del Robot
[manipulador] = robotCreate(q0);