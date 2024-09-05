function arrayBoundaryFacesDomainBoundaryFacesElement = createArrayBfdBfePolyhedraWithDifferentFaces(model, tableNodesBoundaryFaces, tableNodalCoordinates, selectedComponentGeometryTag, numberOfBoundary, elementsOrder)
    %CREATEARRAYARRAYBOUNDARYFACESDOMAINBOUNDARYFACESELEMENT si occupa di creare la matrice FACCE_DOMINIO-FACCE_ELEMENTO

    arrayNodesBoundaryFaces = table2array(tableNodesBoundaryFaces);
    arrayNodalCoordinates = table2array(tableNodalCoordinates);
    % Inizializzazione di una cell array vuota
    arrayBoundaryCoordinates = cell(numberOfBoundary, 1);
    for j=1:numberOfBoundary
        % Ottieni le coordinate del contorno e trasponi la matrice
        boundaryCoordinates = mphgetcoords(model, selectedComponentGeometryTag, 'boundary', j)';
        % Aggiungi le coordinate come nuova cella nell'array di celle
        arrayBoundaryCoordinates{j} = boundaryCoordinates;
    end

    [m, ~] = size(arrayNodesBoundaryFaces);
    arrayBoundaryFacesDomainBoundaryFacesElement = zeros(m,1);
    for i=1:m
        faceNodes = arrayNodesBoundaryFaces(i,:);
        isTriangularFace = any(faceNodes == -1, 2);
        if elementsOrder == 2
            if isTriangularFace
                faceNodes = faceNodes(1:end-2);
                faceNodes([2 4 6]) = [];
            else
                faceNodes([2 4 6 8]) = [];
            end
        else
            if isTriangularFace
                faceNodes = faceNodes(1:end-1);
            end
        end
        faceCoordinates = arrayNodalCoordinates(faceNodes, :);

        for j=1:numberOfBoundary
            boundaryCoordinates = arrayBoundaryCoordinates{j,1};

            isInside = checkFaceInDomain(boundaryCoordinates, faceCoordinates);

            if isInside
                arrayBoundaryFacesDomainBoundaryFacesElement(i,1) = j;
            end
        end

    end

end

