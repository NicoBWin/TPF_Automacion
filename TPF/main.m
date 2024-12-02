%% TP Final Automación Industrial
% Alvarez, Matías Ezequiel  - 62275
% Bustelo, Nicolás          - 61431
% Galán, Albertina          - 61665
% Ibañez, Lucía             - 62488

close all; clear; clc

%% Obtener Imagen
[name,path]=uigetfile({'*.png;*.jpg;*.jpeg'});
Fname=strcat(path,name);
clear path name

%% Configuración del Robot

% Creacion del Robot
[manipulador] = robotCreate();