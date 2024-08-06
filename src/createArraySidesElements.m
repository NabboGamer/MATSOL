function arraySidesElements = createArraySidesElements(tableNodesElements, tableNodesSides)
    %CREATEARRAYSIDESELEMENTS si occupa di creare la matrice LATI-ELEMENTI
    
    arrayNodesElements = table2array(tableNodesElements);
    arrayNodesSides = table2array(tableNodesSides);

    [m, n] = size(arrayNodesElements);
    [o, p] = size(arrayNodesSides);
    numSidesPerElement = 12;
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

