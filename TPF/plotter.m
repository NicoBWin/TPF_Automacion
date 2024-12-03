function plotter(bicho, movimiento)

    Nlinks = numel(bicho.links);
    links = bicho.links;
    qMat = [];
    for i = 1:size(movimiento,2)
        aux = movimiento{i};
        qMat = [qMat;aux];
    end

    figure('Name','Angulo de Joint');
    for i = 1:Nlinks
        subplot(Nlinks,1,i);
        if i == 1
            plot(abs(qMat(:,i)),'LineWidth',1.5);
        else 
            plot(qMat(:,i),'LineWidth',1.5);
        end
        xlabel('Tiempo (s)')
        ylabel('q (rad)')
        ylim(links(i).qlim)
        grid
    end
    sgtitle('Angulo de Joint')
    %%
    vMat = derivarMatrizJoint(qMat);

    %%
    figure('Name','Velocidad Angular de Joint')

     for i = 1:Nlinks
        subplot(Nlinks,1,i);
        plot(vMat(:,i),'LineWidth',1.5);

        xlabel('Tiempo (s)')
        ylabel('q'' (rad/s)')
        grid
    end
    sgtitle('Velocidad Angular de Joint')
    %%
    aMat = derivarMatrizJoint(vMat);

    figure('Name','Aceleracion Angular de Joint')

    for i = 1:Nlinks
        subplot(Nlinks,1,i);
        plot(aMat(:,i),'LineWidth',1.5);

        xlabel('Tiempo (s)')
        ylabel('q'''' (rad/s^2)')
        grid
    end
    sgtitle('Aceleracion Angular de Joint')
    %%
    jMat = derivarMatrizJoint(aMat);

    figure('Name','Jerk')

    for i = 1:Nlinks
        subplot(Nlinks,1,i);
        plot(jMat(:,i),'LineWidth',1.5);
        xlabel('Tiempo (s)')
        ylabel('q'''''' (rad/s^2)')
        grid
    end
    sgtitle('Jerk')
    end

    function vMat = derivarMatrizJoint(qMat)

    qMatExt = [qMat(1,:);qMat;qMat(end,:)];
    vMat = zeros(size(qMat));
    for n = 2:size(qMatExt,1)-1
        vMat(n-1,:) = mean([(qMatExt(n,:)-qMatExt(n-1,:))/1;(qMatExt(n+1,:)-qMatExt(n,:))/1]);
    end

end