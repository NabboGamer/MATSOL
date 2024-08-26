function [arrayNodesSides] = createArrayNodesSidesTetrahedrons(tableNodesFaces)
    %CREATEARRAYNODESSIDES si occupa di creare la matrice NODI-LATI per tutte le facce

    arrayNodesFaces = table2array(tableNodesFaces);

    % Inizializzazione della matrice NODI-LATI
    numFaces = size(arrayNodesFaces, 1);
    numSidesPerFace = 3;  % Ogni faccia ha 3 lati
    numNodesPerSide = 2;  % Ogni lato è definito da 2 nodi
    
    % Creare una lista per memorizzare tutti i lati unici
    arrayNodesSides = zeros(numFaces * numSidesPerFace, numNodesPerSide);
    
    % Iterare su tutte le facce per ottenere i lati
    for i = 1:numFaces
        % Prendere i nodi della faccia corrente
        face = arrayNodesFaces(i, :);
        
        % Generare i lati per la faccia corrente (lati per una faccia triangolare)
        faceSides = [face(1), face(2);  % Lato inferiore  (N1, N2)
                     face(2), face(3);  % Lato destro     (N2, N3)
                     face(3), face(1)]; % Lato sinistro   (N3, N1)
        
        % Inserimento delle facce nella matrice NodiLati
        startIdx = (i - 1) * numSidesPerFace + 1;
        endIdx = i * numSidesPerFace;
        arrayNodesSides(startIdx:endIdx, :) = faceSides;
    end
    
    % Ordina gli elementi di ciascuna riga
    arrayNodesSidesSorted = sort(arrayNodesSides, 2);
    % Trova le righe uniche ordinate
    [~, ia, ~] = unique(arrayNodesSidesSorted, 'rows');
    % Estrai le righe uniche dall'array originale
    arrayNodesSides = arrayNodesSides(ia, :);

end

