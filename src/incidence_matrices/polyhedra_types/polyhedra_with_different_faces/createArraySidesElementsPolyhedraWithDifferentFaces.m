function arraySidesElements = createArraySidesElementsPolyhedraWithDifferentFaces(tableNodesElements, tableNodesSides, elementType, elementsOrder)
    %CREATEARRAYSIDESELEMENTS si occupa di creare la matrice LATI-ELEMENTI
    
    arrayNodesElements = table2array(tableNodesElements);
    arrayNodesSides = table2array(tableNodesSides);

    [m, ~] = size(arrayNodesElements);
    [o, ~] = size(arrayNodesSides);
    
    if elementsOrder == 2
        if strcmp(elementType, 'prism')
            numSidesPerElement = 18;
        elseif strcmp(elementType, 'pyr')
            numSidesPerElement = 16;
        end
    else
        if strcmp(elementType, 'prism')
            numSidesPerElement = 9;
        elseif strcmp(elementType, 'pyr')
            numSidesPerElement = 8;
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

