function [arrayNodesSides] = createArrayNodesSidesPolyhedraWithAllFacesEqual(tableNodesFaces, elementType, elementsOrder)
    %CREATEARRAYNODESSIDES si occupa di creare la matrice NODI-LATI per tutte le facce

    arrayNodesFaces = table2array(tableNodesFaces);

    % Inizializzazione della matrice NODI-LATI
    numFaces = size(arrayNodesFaces, 1);
    if elementsOrder == 2
        if strcmp(elementType, 'hex')
            numSidesPerFace = 8;  % Ogni faccia dell'esaedro ha 8 lati      
        elseif strcmp(elementType, 'tet')
            numSidesPerFace = 6;  % Ogni faccia del tetraedro ha 6 lati
        end
    else
        if strcmp(elementType, 'hex')
            numSidesPerFace = 4;  % Ogni faccia dell'esaedro ha 4 lati      
        elseif strcmp(elementType, 'tet')
            numSidesPerFace = 3;  % Ogni faccia del tetraedro ha 3 lati
        end
    end
    numNodesPerSide = 2;    % Ogni lato è definita da 2 nodi  
    
    % Creare una lista per memorizzare tutti i lati unici
    arrayNodesSides = zeros(numFaces * numSidesPerFace, numNodesPerSide);
    
    % Iterare su tutte le facce per ottenere i lati
    for i = 1:numFaces
        % Prendere i nodi della faccia corrente
        face = arrayNodesFaces(i, :);
        
        if elementsOrder == 2
            if strcmp(elementType, 'hex')
                % Generare i lati per la faccia corrente (lati per una faccia quadrilatera)
                faceSides = [face(1), face(2);  % Lato inferiore 1
                             face(2), face(3);  % Lato inferiore 2
                             face(3), face(6);  % Lato destro 1
                             face(6), face(9);  % Lato destro 2
                             face(9), face(8);  % Lato superiore 1
                             face(8), face(7);  % Lato superiore 2
                             face(7), face(4);  % Lato sinistro 1
                             face(4), face(1)]; % Lato sinistro 2
            elseif strcmp(elementType, 'tet')
                % Generare i lati per la faccia corrente (lati per una faccia triangolare)
                faceSides = [face(1), face(2);  % Lato inferiore 1
                             face(2), face(3);  % Lato inferiore 2
                             face(3), face(4);  % Lato destro 1
                             face(4), face(5);  % Lato destro 2
                             face(5), face(6);  % Lato sinistro 1
                             face(6), face(1)]; % Lato sinistro 2
            end
        else
            if strcmp(elementType, 'hex')
                % Generare i lati per la faccia corrente (lati per una faccia quadrilatera)
                faceSides = [face(1), face(2);  % Lato inferiore  (N1, N2)
                             face(2), face(4);  % Lato destro     (N2, N4)
                             face(4), face(3);  % Lato superiore  (N4, N3)
                             face(3), face(1)]; % Lato sinistro   (N3, N1)
            elseif strcmp(elementType, 'tet')
                % Generare i lati per la faccia corrente (lati per una faccia triangolare)
                faceSides = [face(1), face(2);  % Lato inferiore  (N1, N2)
                             face(2), face(3);  % Lato destro     (N2, N3)
                             face(3), face(1)]; % Lato sinistro   (N3, N1)
            end
        end
        
        % Inserimento delle facce nella matrice NodiLati
        startIdx = (i - 1) * numSidesPerFace + 1;
        endIdx = i * numSidesPerFace;
        arrayNodesSides(startIdx:endIdx, :) = faceSides;
    end
    
    % Ordina gli elementi di ciascuna riga
    arrayNodesSidesSorted = sort(arrayNodesSides, 2);
    % Trova le righe uniche ordinate
    [~, ia, ~] = unique(arrayNodesSidesSorted, 'rows', 'stable');
    % Estrai le righe uniche dall'array originale
    arrayNodesSides = arrayNodesSides(ia, :);

end

