function [arrayNodesSides] = createArrayNodesSides(tableNodesFaces)
    %CREATEARRAYNODESSIDES si occupa di creare la matrice NODI-LATI per
    %tutte le facce

    arrayNodesFaces = table2array(tableNodesFaces);

    % Inizializzazione della matrice NODI-LATI
    numFacce = size(arrayNodesFaces, 1);
    numLatiPerFaccia = 4;  % Ogni faccia ha 4 lati
    numNodiPerLato = 2;    % Ogni lato è definita da 2 nodi
    
    % Creare una lista per memorizzare tutti i lati unici
    arrayNodesSides = zeros(numFacce * numLatiPerFaccia, numNodiPerLato);
    
    % Iterare su tutte le facce per ottenere i lati
    for i = 1:numFacce
        % Prendere i nodi della faccia corrente
        face = arrayNodesFaces(i, :);
        
        % Generare i lati per la faccia corrente (lati per una faccia quadrilatera)
        faceSides = [face(1), face(2);  % Lato inferiore  (N1, N2)
                     face(2), face(4);  % Lato destro     (N2, N4)
                     face(4), face(3);  % Lato superiore  (N4, N3)
                     face(3), face(1)]; % Lato sinistro   (N3, N1)
        
        % Inserimento delle facce nella matrice NodiLati
        startIdx = (i - 1) * numLatiPerFaccia + 1;
        endIdx = i * numLatiPerFaccia;
        arrayNodesSides(startIdx:endIdx, :) = faceSides;
    end
    
    % Ordina gli elementi di ciascuna riga
    arrayNodesSidesSorted = sort(arrayNodesSides, 2);
    % Trova le righe uniche ordinate
    [~, ia, ~] = unique(arrayNodesSidesSorted, 'rows');
    % Estrai le righe uniche dall'array originale
    arrayNodesSides = arrayNodesSides(ia, :);

end

