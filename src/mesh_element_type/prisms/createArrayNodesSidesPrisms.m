function [arrayNodesSides] = createArrayNodesSidesPrisms(tableNodesFaces)
    %CREATEARRAYNODESSIDES si occupa di creare la matrice NODI-LATI per tutte le facce

    arrayNodesFaces = table2array(tableNodesFaces);

    % Inizializzazione della matrice NODI-LATI
    numFaces = size(arrayNodesFaces, 1);
    numTriangularFaces = sum(any(arrayNodesFaces == -1, 2));
    numRectangularFaces = numFaces - numTriangularFaces;
    numSidesPerTriangularFace = 3;     % Ogni faccia triangolare ha 3 lati
    numSidesPerRectangularFace = 4;    % Ogni faccia rettangolare ha 4 lati
    numNodesPerSide = 2;               % Ogni lato è definito da 2 nodi
    numSidesTriangle = numTriangularFaces*numSidesPerTriangularFace;
    numSidesRectangle = numRectangularFaces*numSidesPerRectangularFace;

    % Creare due array per memorizzare tutti i lati
    arrayNodesSidesTriangle = zeros(numSidesTriangle, numNodesPerSide);
    arrayNodesSidesRectangle = zeros(numSidesRectangle, numNodesPerSide);
    

    % Trova le righe con almeno un -1
    retentionIndices = any(arrayNodesFaces == -1, 2);
    arrayNodesTriangularFaces = arrayNodesFaces(retentionIndices, :);
    % Iterare su tutte le facce per ottenere i lati
    for i = 1:numTriangularFaces
        % Prendere i nodi della faccia corrente
        face = arrayNodesTriangularFaces(i, :);
        face = face(2:end);

        % Generare i lati per la faccia corrente (lati per una faccia triangolare)
        faceSides = [face(1), face(2);  % Lato inferiore  (N1, N2)
                     face(2), face(3);  % Lato destro     (N2, N3)
                     face(3), face(1)]; % Lato sinistro   (N3, N1)
            
        % Inserimento delle facce nella matrice NODI-LATI
        startIdx = (i - 1) * numSidesPerTriangularFace + 1;
        endIdx = i * numSidesPerTriangularFace;
        arrayNodesSidesTriangle(startIdx:endIdx, :) = faceSides;
       
    end

    % Trova le righe con almeno un -1
    removalIndices = any(arrayNodesFaces == -1, 2);
    % Nega l'indice per selezionare le righe da mantenere
    arrayNodesRectangularFaces = arrayNodesFaces(~removalIndices, :);
    for j = 1:numRectangularFaces
        % Prendere i nodi della faccia corrente
        face = arrayNodesRectangularFaces(j, :);

        % Generare i lati per la faccia corrente (lati per una faccia quadrilatera)
        faceSides = [face(1), face(2);  % Lato inferiore  (N1, N2)
                     face(2), face(4);  % Lato destro     (N2, N4)
                     face(4), face(3);  % Lato superiore  (N4, N3)
                     face(3), face(1)]; % Lato sinistro   (N3, N1)
            
        % Inserimento delle facce nella matrice NodiLati
        startIdx = (j - 1) * numSidesPerRectangularFace + 1;
        endIdx = j * numSidesPerRectangularFace;
        arrayNodesSidesRectangle(startIdx:endIdx, :) = faceSides;
       
    end

    arrayNodesSides = [arrayNodesSidesTriangle;arrayNodesSidesRectangle];
    
    % Ordina gli elementi di ciascuna riga
    arrayNodesSidesSorted = sort(arrayNodesSides, 2);
    % Trova le righe uniche ordinate
    [~, ia, ~] = unique(arrayNodesSidesSorted, 'rows');
    % Estrai le righe uniche dall'array originale
    arrayNodesSides = arrayNodesSides(ia, :);

end

