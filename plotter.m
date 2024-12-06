function plotter(Bichito, motion)
    % Número de enlaces en el robot
    numLinks = numel(Bichito.links);
    links = Bichito.links;
    jointAngles = [];

    % Concatenar todos los datos de movimiento en una sola matriz
    for i = 1:size(motion, 2)
        temp = motion{i};
        jointAngles = [jointAngles; temp];
    end
    
    %% Posiciones Angulares
    % Graficar ángulos de las articulaciones a lo largo del tiempo
    figure('Name', 'Joint Angles');
    for i = 1:numLinks
        subplot(numLinks, 1, i);
        if i == 1
            plot(abs(jointAngles(:, i)), 'LineWidth', 1.5);
        else 
            plot(jointAngles(:, i), 'LineWidth', 1.5);
        end
        xlabel('Time (s)');
        ylabel('q (rad)');
        ylim(links(i).qlim);
        grid on;
    end
    sgtitle('Joint Angles');

    %% Velocidades Angulares
    % Calcular velocidades de las articulaciones
    jointVelocities = calculateDerivatives(jointAngles);

    % Graficar velocidades de las articulaciones a lo largo del tiempo
    figure('Name', 'Joint Angular Velocities');
    for i = 1:numLinks
        subplot(numLinks, 1, i);
        plot(jointVelocities(:, i), 'LineWidth', 1.5);
        xlabel('Tiempo (s)');
        ylabel('q'' (rad/s)');
        grid on;
    end
    sgtitle('Joint Angular Velocities');

    %% Aceleraciones Angulares
    % Calcular aceleraciones de las articulaciones
    jointAccelerations = calculateDerivatives(jointVelocities);

    % Graficar aceleraciones de las articulaciones a lo largo del tiempo
    figure('Name', 'Joint Angular Accelerations');
    for i = 1:numLinks
        subplot(numLinks, 1, i);
        plot(jointAccelerations(:, i), 'LineWidth', 1.5);
        xlabel('Tiempo (s)');
        ylabel('q'''' (rad/s^2)');
        grid on;
    end
    sgtitle('Joint Angular Accelerations');

    %% Jerks
    % Calcular jerks de las articulaciones
    jointJerks = calculateDerivatives(jointAccelerations);

    % Graficar jerks de las articulaciones a lo largo del tiempo
    figure('Name', 'Joint Jerks');
    for i = 1:numLinks
        subplot(numLinks, 1, i);
        plot(jointJerks(:, i), 'LineWidth', 1.5);
        xlabel('Tiempo (s)');
        ylabel("q''''' (rad/s^3)");
        grid on;
    end
    sgtitle('Joint Jerks');
end

function derivatives = calculateDerivatives(data)
    derivatives = diff(data) / 0.01;                    % Paso de 0.01 s
    derivatives = [derivatives; derivatives(end, :)];
end