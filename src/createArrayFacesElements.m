function arrayFacesElements = createArrayFacesElements(tableNodesElements, tableNodesFaces)
    %CREATEARRAYFACESELEMENTS si occupa di creare la matrice FACCE-ELEMENTI
    
    arrayNodesElements = table2array(tableNodesElements);
    arrayNodesFaces = table2array(tableNodesFaces);

    [m, n] = size(arrayNodesElements);
    [o, p] = size(arrayNodesFaces);
    numFacesPerElements = 6;
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

