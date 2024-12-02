function [Bichito] = robotCreate(q0)
%% Características del Bichito

% Número de links
N = 5; 

% Tipo de joint
type = {'revolute', 'revolute', 'revolute', 'revolute', 'revolute'};

% Longitud de los links (consigna)
L1 = 130;
L2 = 144;
L3 = 58;
L4 = 144;
L5 = 144;
LEE = 30;

L = [L1, sqrt(L2^2 + L3^2), L4, L5, LEE];

% Masa de los links
M = [1, 1, 1, 1, 1]; 

% Momentos de inercia (masa unitaria concentrada)
I = {0*eye(3), 0*eye(3),  0*eye(3),  0*eye(3), 0*eye(3)};  

% Fricción unitaria
B = [1, 1, 1, 1, 1]; 

% Gear ratio (distinto de 0)
GR = [1, 1, 1, 1, 1];

% Límites angulares
qlim = cell(1,N);
qlim{1} = deg2rad([-180,180]);
qlim{2} = deg2rad([-180,180]);
qlim{3} = deg2rad([-180,180]);
qlim{4} = deg2rad([-180,180]);
qlim{5} = deg2rad([-180,180]);


% Parámetros DH
DH = struct('d', cell(1,N), 'alpha', cell(1,N), 'a', cell(1,N), 'theta', cell(1,N));
DH(1).a = 0; DH(1).alpha = 0; DH(1).d = L(1); 
DH(2).a = 0; DH(2).alpha = pi/2; DH(2).d =0; 
DH(3).a = L(2); DH(3).alpha = 0; DH(3).d =0; 
DH(4).a = L(3); DH(4).alpha = 0; DH(4).d =0;
DH(5).a = 0; DH(5).alpha = -pi/2; DH(5).d = L(4);
 
%% Creación de links
% Arreglo de links
for i = 1:N
    links{i} = Link(type{i}, 'modified', 'd', DH(i).d, 'a', DH(i).a, 'alpha', DH(i).alpha, ...
        'I', I{i}, 'm', M(i), 'B', B(i), 'qlim', qlim{i}, 'G', GR(i)); 
end

%% Creación del Bichito

Bichito = SerialLink([links{:}], 'tool', transl([0, 0, L(5)]), 'name', 'Bichito');

% Posición inicial

figure()
Bichito.teach(q0)
end
