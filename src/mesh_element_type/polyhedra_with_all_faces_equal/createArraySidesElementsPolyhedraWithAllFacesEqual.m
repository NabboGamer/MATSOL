function arraySidesElements = createArraySidesElementsPolyhedraWithAllFacesEqual(tableNodesElements, tableNodesSides, elementType, elementsOrder)
    %CREATEARRAYSIDESELEMENTS si occupa di creare la matrice LATI-ELEMENTI
    
    arrayNodesElements = table2array(tableNodesElements);
    arrayNodesSides = table2array(tableNodesSides);

    [m, ~] = size(arrayNodesElements);
    [o, ~] = size(arrayNodesSides);

    if elementsOrder == 2
        if strcmp(elementType, 'hex')
            numSidesPerElement = 24;
        elseif strcmp(elementType, 'tet')
            numSidesPerElement = 12;
        end
    else
        if strcmp(elementType, 'hex')
            numSidesPerElement = 12;
        elseif strcmp(elementType, 'tet')
            numSidesPerElement = 6;
        end
    end

    arraySidesElements = zeros(m, numSidesPerElement);

    for i = 1 : m
        column = 1;
        elementNodes = arrayNodesElements(i, :);
        for j = 1 : o
            sideNodes = arrayNodesSides(j, :);
            if all(ismember(sideNodes, elementNodes))
                arraySidesElements(i, column) = j;
                column = column + 1;
            end
        end
    end
    

end

