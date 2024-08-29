function arraySidesFaces = createArraySidesFacesPolyhedraWithDifferentFaces(tableNodesFaces, tableNodesSides)
    %CREATEARRAYSIDESFACES si occupa di creare la matrice LATI-FACCE
    
    arrayNodesFaces = table2array(tableNodesFaces);
    arrayNodesSides = table2array(tableNodesSides);

    [m, ~] = size(arrayNodesFaces);
    [o, ~] = size(arrayNodesSides);

    numSidesPerRectangularFace = 4;     % Ogni faccia rettangolare è definita da 4 lati
    % numSidesPerTriangularFace = 3;      % Ogni faccia triangolare è definita da 3 lati
    arraySidesFaces = zeros(m, numSidesPerRectangularFace);

    for i = 1 : m
        column = 1;
        faceNodes = arrayNodesFaces(i, :);

        isTriangularFace = any(faceNodes == -1, 2);
        if isTriangularFace
            faceNodes = faceNodes(1:end-1);
        end

        for j = 1 : o
            sideNodes = arrayNodesSides(j, :);
            if all(ismember(sideNodes, faceNodes))
                arraySidesFaces(i, column) = j;
                column = column + 1;
            end
        end

        if isTriangularFace
            arraySidesFaces(i, column) = -1;
        end

    end
    

end

