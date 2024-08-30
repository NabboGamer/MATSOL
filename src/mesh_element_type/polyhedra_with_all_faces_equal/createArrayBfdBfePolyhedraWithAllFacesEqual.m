function arrayBoundaryFacesDomainBoundaryFacesElement = createArrayBfdBfePolyhedraWithAllFacesEqual(model, tableNodesBoundaryFaces, tableNodalCoordinates, selectedComponentGeometryTag, numberOfBoundary)
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

