function is_inside = checkElementInDomain(vertices, domain, domainType)
    %CHECKHEXAEDRONINHEXAEDRALDOMAIN si occupa di verificare se ogni vertice di un elemento è compreso nel dominio
    % vertices: matrice nx3 dove ogni riga rappresenta un vertice (x, y, z) dell'elmento in esame
    % domain: è una struttura dati comprendente informazioni sul dominio
    % is_inside: true se tutti i vertici sono interni al dominio
    
    is_inside = true;
    [p, ~] = size(vertices); 
    for k=1:p

        if strcmp(domainType, 'hex')
            if ~isInsideHexahedralDomain(vertices(k, :), domain)
                is_inside = false;
                break;
            end
        end

        if strcmp(domainType, 'prism')
            
        end


    end
end