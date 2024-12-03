function dibujarMesa(table_start, table_end)
    xRect = [table_start(1), table_end(1), table_end(1), table_start(1)];
    yRect = [table_start(2), table_start(2), table_end(2), table_end(2)];
    zRect = [table_start(3), table_start(3), table_start(3), table_start(3)];
    fill3(xRect, yRect, zRect, 'g'); % color azul
end