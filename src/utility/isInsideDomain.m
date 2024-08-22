function isInside = isInsideDomain(point, domain)
    %ISINSIDEDOMAIN si occupa di verificare se un punto è all'interno del dominio
    % point: vettore 1x3 con le coordinate (x,y,z) del punto
    % domain: struttura contenente le coordinate (x_min,y_min,z_min) e (x_max,y_max,z_max) del dominio
    % isInside: booleano che indica se il punto è all'interno del dominio
    %TODO: Estendere la funzione per tutti i tipi comuni di dominio e non solo
    %      il parallelepipedo!

    x = point(1);
    y = point(2);
    z = point(3);
    epsilon = eps(class(x)); % Calcola la precisione macchina per il tipo di dato di x(ovvero double)
    isInside = (x >= domain.x_min-epsilon && x <= domain.x_max+epsilon && ...
                y >= domain.y_min-epsilon && y <= domain.y_max+epsilon && ...
                z >= domain.z_min-epsilon && z <= domain.z_max+epsilon);
end