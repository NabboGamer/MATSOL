function arraySidesFaces = createArraySidesFacesPolyhedraWithAllFacesEqual(tableNodesFaces, tableNodesSides, elementType, elementsOrder)
    %CREATEARRAYSIDESFACES si occupa di creare la matrice LATI-FACCE
    
    arrayNodesFaces = table2array(tableNodesFaces);
    arrayNodesSides = table2array(tableNodesSides);

    [m, ~] = size(arrayNodesFaces);
    [o, ~] = size(arrayNodesSides);

    if elementsOrder == 2
        if strcmp(elementType, 'hex')
            numSidesPerFace = 8;
        elseif strcmp(elementType, 'tet')
            numSidesPerFace = 6;
        end
    else
        if strcmp(elementType, 'hex')
            numSidesPerFace = 4;
        elseif strcmp(elementType, 'tet')
            numSidesPerFace = 3;
        end
    end

    arraySidesFaces = zeros(m, numSidesPerFace);

    for i = 1 : m
        column = 1;
        faceNodes = arrayNodesFaces(i, :);
        for j = 1 : o
            sideNodes = arrayNodesSides(j, :);
            if all(ismember(sideNodes, faceNodes))
                arraySidesFaces(i, column) = j;
                column = column + 1;
            end
        end
    end
    

end

