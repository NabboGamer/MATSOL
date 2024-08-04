function [arrayNodesFacesForSingleElementWithLocalNumbering] = createArrayNodesFacesForSingleElementWithLocalNumbering(coords)
    % Questa function si occupa di creare la matrice NODI-FACCE per un
    % singolo elemento con la numerazione dei nodi locale

    % Trova tutte le combinazioni di 4 vertici su 8
    combinations = nchoosek(1:size(coords, 1), 4);
    
    % Matrice per memorizzare le facce
    num_combinations = size(combinations, 1);
    arrayNodesFacesForSingleElementWithLocalNumbering = [];
    
    % Funzione per calcolare il determinante della matrice di vettori
    function d = check_complanar(coords, indices)
        % Ottieni i vertici
        vertices = coords(indices, :);
        % Vettori dei lati della faccia
        v1 = vertices(2, :) - vertices(1, :);
        v2 = vertices(3, :) - vertices(1, :);
        v3 = vertices(4, :) - vertices(1, :);
        % Calcola il determinante della matrice dei vettori
        d = abs(dot(cross(v1, v2), v3));
    end

    % Funzione per verificare se una faccia è una faccia valida
    function is_valid_face = check_valid_face(coords, indices)
        % Ottieni i 4 vertici
        vertices = coords(indices, :);
        
        % Crea i vettori dal primo vertice agli altri 3 vertici
        v1 = vertices(2, :) - vertices(1, :);
        v2 = vertices(3, :) - vertices(1, :);
        v3 = vertices(4, :) - vertices(1, :);
        
        % Calcola la normale della faccia
        normal = cross(v1, v2);
        normal = normal / norm(normal);  % Normalizza il vettore normale
        
        % Verifica che il quarto vertice sia complanare
        tolerance = 1e-5;
        complanar = abs(dot(normal, v3)) < tolerance;

        % Controllo delle distanze per verificare che i vertici siano adiacenti
        % Calcoliamo tutte le distanze e verifichiamo che siano consistenti con
        % quelle attese in un cubo/parallelepipedo.
        edges = [norm(v1), norm(v2), norm(vertices(4,:) - vertices(1,:)), ...
                 norm(vertices(3,:) - vertices(2,:)), norm(vertices(4,:) - vertices(2,:)), norm(vertices(4,:) - vertices(3,:))];
        
        % Rimuovi distanze duplicate con una tolleranza
        unique_edges = unique(round(edges/tolerance)*tolerance);
        
        % Un cubo/parallelepipedo ha al massimo 3 diverse lunghezze di spigoli
        is_valid_face = complanar && length(unique_edges) <= 2;
    end
    
    % Verifica ogni combinazione di 4 vertici
    for i = 1:num_combinations
        indices = combinations(i, :);
        if check_complanar(coords, indices) < 1e-10 % Soglia per la precisione numerica
            % Se i vertici sono complanari, aggiungi la faccia
            if check_valid_face(coords, indices)
                arrayNodesFacesForSingleElementWithLocalNumbering = [arrayNodesFacesForSingleElementWithLocalNumbering; indices];
            end
        end
    end

end


