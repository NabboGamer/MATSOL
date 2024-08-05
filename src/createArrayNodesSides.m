function [arrayNodesSides] = createArrayNodesSides(tableNodesFaces)

    arrayNodesFaces = table2array(tableNodesFaces);

    num_faces = size(arrayNodesFaces, 1);
    
    % Creare una lista per memorizzare tutti i lati unici
    arrayNodesSides = [];
    
    % Iterare su tutte le facce per ottenere i lati
    for i = 1:num_faces
        % Prendere i nodi della faccia corrente
        face = arrayNodesFaces(i, :);
        
        % Generare i lati per la faccia corrente (lati per una faccia quadrilatera)
        faceSides = [face(1), face(2); 
                     face(2), face(4); 
                     face(4), face(3); 
                     face(3), face(1)];
        
        % Aggiungere i lati alla lista complessiva, evitando duplicati
        arrayNodesSides = [arrayNodesSides; faceSides];
    end
    
    % Ordina gli elementi di ciascuna riga
    arrayNodesSidesSorted = sort(arrayNodesSides, 2);
    % Trova le righe uniche ordinate
    [~, ia, ~] = unique(arrayNodesSidesSorted, 'rows');
    % Estrai le righe uniche dall'array originale
    arrayNodesSides = arrayNodesSides(ia, :);

end

