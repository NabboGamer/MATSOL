function [arrayNodesFaces] = createArrayNodesFaces(tableNodalCoordinates, tableNodesElements)
    % Questa function si occupa di creare la matrice NODI-FACCE per
    % tutti gli elementi
    
    arrayNodalCoordinates = table2array(tableNodalCoordinates);
    arrayNodesElements = table2array(tableNodesElements);

    n = size(arrayNodesElements, 1);
    arrayNodesFaces = [];
    for i = 1 : n
        coords = arrayNodalCoordinates(arrayNodesElements(i, :), :);
        arrayNodesFacesForSingleElement = createArrayNodesFacesForSingleElement(coords, arrayNodalCoordinates);
        arrayNodesFaces = [arrayNodesFaces; arrayNodesFacesForSingleElement];
    end

    % Ordina gli elementi di ciascuna riga
    arrayNodesFacesSorted = sort(arrayNodesFaces, 2);
    % Trova le righe uniche ordinate
    [~, ia, ~] = unique(arrayNodesFacesSorted, 'rows');
    % Estrai le righe uniche dall'array originale
    arrayNodesFaces = arrayNodesFaces(ia, :);

end

