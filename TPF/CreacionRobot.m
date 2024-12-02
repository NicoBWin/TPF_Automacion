% Configuración inicial del robot

% Número de links
N = 5; 

% Tipo de joint
type = {'revolute', 'revolute', 'revolute', 'revolute', 'revolute'};

% Largo de los links
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

% Gear ratio
GR = [1, 1, 1, 1, 1];

% Limites angulares
qlim = cell(1,N);
qlim{1} = deg2rad([-180,180]);
qlim{2} = deg2rad([-180,180]);
qlim{3} = deg2rad([-180,180]);
qlim{4} = deg2rad([-180,180]);
qlim{5} = deg2rad([-180,180]);


% Parametros DH
DH = struct('d', cell(1,N), 'alpha', cell(1,N), 'a', cell(1,N), 'theta', cell(1,N));
DH(1).a = 0; DH(1).alpha = 0; DH(1).d = L(1); 
DH(2).a = 0; DH(2).alpha = pi/2; DH(2).d =0; 
DH(3).a = L(2); DH(3).alpha = 0; DH(3).d =0; 
DH(4).a = L(3); DH(4).alpha = 0; DH(4).d =0;
DH(5).a = 0; DH(5).alpha = -pi/2; DH(5).d = L(4);
 
%Creación de los links
% Arreglo de links
for i = 1:N
    links{i} = Link(type{i}, 'modified', 'd', DH(i).d, 'a', DH(i).a, 'alpha', DH(i).alpha, ...
        'I', I{i}, 'm', M(i), 'B', B(i), 'qlim', qlim{i}, 'G', GR(i)); 
end

%Creación del robot

Bichito = SerialLink([links{:}], 'tool', transl([0, 0, L(5)]), 'name', 'Bichito');

%Posicion inicial manipulador

q0 = deg2rad([90, 52.5, -75, -120, 0]);
figure()
Bichito.teach(q0)

% Altura del lapiz para realizar el movimiento
Alt_lapiz = 15;

% Dimensiones de la hoja
Dim_h = [200, 150];

%Posicion del vertice origen de la hoja respecto a la base
Pos_h = [-100, 50, 0];





