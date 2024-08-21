function [inside] = isInsideDomain(point, domain)
    %ISINSIDEDOMAIN si occupa di verificare se un punto è all'interno del dominio.
    %TODO: Estendere la funzione per tutti i tipi comuni di dominio e non solo
    %      il parallelepipedo.

    x = point(1);
    y = point(2);
    z = point(3);
    epsilon = eps(class(x)); % Calcola la precisione macchina per il tipo di dato di x(ovvero double)
    inside = (x >= domain.x_min-epsilon && x <= domain.x_max+epsilon && ...
              y >= domain.y_min-epsilon && y <= domain.y_max+epsilon && ...
              z >= domain.z_min-epsilon && z <= domain.z_max+epsilon);
end