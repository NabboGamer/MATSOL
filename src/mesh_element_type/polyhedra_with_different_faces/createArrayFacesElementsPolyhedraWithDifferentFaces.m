function arrayFacesElements = createArrayFacesElementsPolyhedraWithDifferentFaces(tableNodesElements, tableNodesFaces)
    %CREATEARRAYFACESELEMENTS si occupa di creare la matrice FACCE-ELEMENTI
    
    arrayNodesElements = table2array(tableNodesElements);
    arrayNodesFaces = table2array(tableNodesFaces);

    [m, ~] = size(arrayNodesElements);
    [o, ~] = size(arrayNodesFaces);
    numFacesPerElements = 5;
    arrayFacesElements = zeros(m, numFacesPerElements);

    for i = 1 : m
        column = 1;
        elementNodes = arrayNodesElements(i, :);
        for j = 1 : o
            facesNodes = arrayNodesFaces(j, :);

            isTriangularFace = any(facesNodes == -1, 2);
            if isTriangularFace
                facesNodes = facesNodes(1:end-1);
            end

            if all(ismember(facesNodes, elementNodes))
                arrayFacesElements(i, column) = j;
                column = column + 1;
            end

        end
        
    end
    

end

