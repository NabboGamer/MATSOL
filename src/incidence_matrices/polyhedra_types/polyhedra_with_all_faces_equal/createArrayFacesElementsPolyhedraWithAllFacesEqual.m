function arrayFacesElements = createArrayFacesElementsPolyhedraWithAllFacesEqual(tableNodesElements, tableNodesFaces, elementType)
    %CREATEARRAYFACESELEMENTS si occupa di creare la matrice FACCE-ELEMENTI
    
    arrayNodesElements = table2array(tableNodesElements);
    arrayNodesFaces = table2array(tableNodesFaces);

    [m, ~] = size(arrayNodesElements);
    [o, ~] = size(arrayNodesFaces);

    if strcmp(elementType, 'hex')
        numFacesPerElements = 6;
    elseif strcmp(elementType, 'tet')
        numFacesPerElements = 4;
    end
    
    arrayFacesElements = zeros(m, numFacesPerElements);

    for i = 1 : m
        column = 1;
        elementNodes = arrayNodesElements(i, :);
        for j = 1 : o
            facesNodes = arrayNodesFaces(j, :);
            if all(ismember(facesNodes, elementNodes))
                arrayFacesElements(i, column) = j;
                column = column + 1;
            end
        end
    end
    

end

