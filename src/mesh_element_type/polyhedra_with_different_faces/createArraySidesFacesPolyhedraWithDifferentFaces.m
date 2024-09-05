function arraySidesFaces = createArraySidesFacesPolyhedraWithDifferentFaces(tableNodesFaces, tableNodesSides, elementsOrder)
    %CREATEARRAYSIDESFACES si occupa di creare la matrice LATI-FACCE
    
    arrayNodesFaces = table2array(tableNodesFaces);
    arrayNodesSides = table2array(tableNodesSides);

    [m, ~] = size(arrayNodesFaces);
    [o, ~] = size(arrayNodesSides);

    if elementsOrder == 2
        numSidesPerRectangularFace = 8;     % Ogni faccia rettangolare è definita da 8 lati
        % numSidesPerTriangularFace = 6;      % Ogni faccia triangolare è definita da 6 lati
    else
        numSidesPerRectangularFace = 4;     % Ogni faccia rettangolare è definita da 4 lati
        % numSidesPerTriangularFace = 3;      % Ogni faccia triangolare è definita da 3 lati
    end
    arraySidesFaces = zeros(m, numSidesPerRectangularFace);

    for i = 1 : m
        column = 1;
        faceNodes = arrayNodesFaces(i, :);

        isTriangularFace = any(faceNodes == -1, 2);
        if elementsOrder == 2
            if isTriangularFace
                faceNodes = faceNodes(1:end-2);
            end
        else
            if isTriangularFace
                faceNodes = faceNodes(1:end-1);
            end
        end

        for j = 1 : o
            sideNodes = arrayNodesSides(j, :);
            if all(ismember(sideNodes, faceNodes))
                arraySidesFaces(i, column) = j;
                column = column + 1;
            end
        end
        
        if elementsOrder == 2
            if isTriangularFace
                arraySidesFaces(i, column) = -1;
                arraySidesFaces(i, column+1) = -1;
            end
        else
            if isTriangularFace
                arraySidesFaces(i, column) = -1;
            end
        end

    end
    

end

