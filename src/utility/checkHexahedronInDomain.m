function is_inside = checkHexahedronInDomain(vertices, domain)
    %CHECKHEXAEDRONINDOMAIN si occupa di verificare se ogni vertice di un esaedro è compreso in un dominio esaedrico
    % vertices: matrice 8x3 dove ogni riga rappresenta un vertice (x, y, z) dell'elmento in esame
    % domain: è una struttura dati comprendente (x_min, y_min, z_min, x_max, y_max, z_max) del dominio esaedrico
    % is_inside: true se tutti i vertici sono interni al dominio
    
    is_inside = true;
    [p, ~] = size(vertices); 
    for k=1:p
        if ~isInsideDomain(vertices(k, :), domain)
            is_inside = false;
            break;
        end
    end
end