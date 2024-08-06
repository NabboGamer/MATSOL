function [arrayNodesFaces] = createArrayNodesFaces(tableNodesElements)
    %CREATEARRAYNODESFACES si occupa di creare la matrice NODI-FACCE per
    %tutti gli elementi
    
    arrayNodesElements = table2array(tableNodesElements);

    % Inizializzazione della matrice NODI-FACCE
    numElementi = size(arrayNodesElements, 1);
    numFaccePerElemento = 6;  % Ogni esaedro ha 6 facce
    numNodiPerFaccia = 4;     % Ogni faccia è definita da 4 nodi
    
    % Inizializzazione della matrice che conterrà i nodi per ogni faccia
    arrayNodesFaces = zeros(numElementi * numFaccePerElemento, numNodiPerFaccia);
    
    % Iterazione sugli elementi
    for e = 1:numElementi
        % Nodi dell'elemento corrente
        nodi = arrayNodesElements(e, :);
        
        % Definizione delle 6 facce per l'elemento secondo la notazione corretta
        facce = [
            nodi([1, 2, 3, 4]); % Faccia inferiore  (N1, N2, N3, N4)
            nodi([5, 6, 7, 8]); % Faccia superiore  (N5, N6, N7, N8)
            nodi([1, 2, 5, 6]); % Faccia frontale   (N1, N2, N5, N6)
            nodi([3, 4, 7, 8]); % Faccia posteriore (N3, N4, N7, N8)
            nodi([1, 3, 5, 7]); % Faccia sinistra   (N1, N3, N5, N7)
            nodi([2, 4, 6, 8]); % Faccia destra     (N2, N4, N6, N8)
        ];
        
        % Inserimento delle facce nella matrice NodiFacce
        startIdx = (e - 1) * numFaccePerElemento + 1;
        endIdx = e * numFaccePerElemento;
        arrayNodesFaces(startIdx:endIdx, :) = facce;
    end

    % Ordina gli elementi di ciascuna riga
    arrayNodesFacesSorted = sort(arrayNodesFaces, 2);
    % Trova le righe uniche ordinate
    [~, ia, ~] = unique(arrayNodesFacesSorted, 'rows');
    % Estrai le righe uniche dall'array originale
    arrayNodesFaces = arrayNodesFaces(ia, :);

end

