function in_domain = checkFaceInDomain(domain_face, mesh_face)
    %CHECKFACESINDOMAIN si occupa di verificare se una faccia di un elemento di una mesh è compresa in una faccia del dominio
    % domain_face: matrice nx3, dove ogni riga è un vertice del dominio [x, y, z]
    % mesh_face: matrice nx3, dove ogni riga è un vertice dell'elemento della mesh [x, y, z]
    % in_domain: true se la faccia della mesh è all'interno della faccia del dominio

    % Usa i primi tre punti per calcolare l'equazione del piano per la faccia del dominio
    plane_eq_domain = computePlaneEquationFromPoints(domain_face(1,:), domain_face(2,:), domain_face(3,:));
    
    % Usa i primi tre punti per calcolare l'equazione del piano per la faccia della mesh
    plane_eq_mesh = computePlaneEquationFromPoints(mesh_face(1,:), mesh_face(2,:), mesh_face(3,:));
    
    % Verifica se i piani sono uguali
    tolerance = 1e-10;
    if norm(plane_eq_domain(1:3) - plane_eq_mesh(1:3)) > tolerance || ...
       abs(plane_eq_domain(4) - plane_eq_mesh(4)) > tolerance
        in_domain = false;
        return; % Esce dalla funzione poiché i piani non sono uguali
    end
    
    % Proietta la faccia del dominio su un piano 2D
    [domain_2D, ~] = projectToPlane(domain_face, plane_eq_domain(1:3));
    domain_2D(abs(domain_2D) < tolerance) = 0;
    domain_2D = unique(domain_2D, 'rows', 'stable');
    
    % Controlla se il poligono ha almeno 3 vertici
    if size(domain_2D, 1) < 3 || any(isnan(domain_2D(:)))
        in_domain = false;
        return; % Esce dalla funzione poiché il dominio non è valido
    end
    
    % Ordina i vertici della mesh in senso orario
    domain_2D = sortPolygonVertices(domain_2D);
    domain_2D = round(domain_2D, 10);


    % Crea un poligono per il dominio in 2D
    % Salva lo stato corrente dei warning
    oldWarnState = warning('query', 'all');
    % Disabilita la stampa dei warning di MATLAB
    warning('off', 'all');
    lastwarn('');

    domain_poly = polyshape(domain_2D(:, 1), domain_2D(:, 2));

    % % Recupera l'ultimo warning
    % [msg, ~] = lastwarn;
    % % Se un warning è stato generato, stampa un messaggio personalizzato
    % if ~isempty(msg)
    %     cprintf('SystemCommands', '***WARNING: %s\n', msg);
    %     % Pulire la lista dei warning dopo averli gestiti
    %     lastwarn('');  % Resetta il messaggio e l'ID dell'ultimo warning
    % end
    % Ripristina la stampa dei warning di MATLAB
    warning(oldWarnState);

    
    % Proietta la faccia della mesh sullo stesso piano
    [mesh_2D, ~] = projectToPlane(mesh_face, plane_eq_mesh(1:3));
    mesh_2D(abs(mesh_2D) < tolerance) = 0;
    mesh_2D = unique(mesh_2D, 'rows', 'stable');
    
    % Controlla se il poligono ha almeno 3 vertici
    if size(mesh_2D, 1) < 3 || any(isnan(mesh_2D(:)))
        in_domain = false;
        return; % Esce dalla funzione poiché la faccia della mesh non è valida
    end
    
    % Ordina i vertici della mesh in senso orario
    mesh_2D = sortPolygonVertices(mesh_2D);
    mesh_2D = round(mesh_2D, 10);
    
    % Verifica se tutti i vertici della faccia della mesh sono all'interno del poligono
    in_domain = all(isinterior(domain_poly, mesh_2D(:, 1), mesh_2D(:, 2)));
end