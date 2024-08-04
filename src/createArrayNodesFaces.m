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

end

