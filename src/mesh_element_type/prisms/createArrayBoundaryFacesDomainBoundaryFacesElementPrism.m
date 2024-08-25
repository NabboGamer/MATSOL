function arrayBoundaryFacesDomainBoundaryFacesElement = createArrayBoundaryFacesDomainBoundaryFacesElementPrism(model, tableNodesBoundaryFaces, tableNodalCoordinates, selectedComponentGeometryTag, numberOfBoundary)
    %CREATEARRAYARRAYBOUNDARYFACESDOMAINBOUNDARYFACESELEMENT si occupa di creare la matrice FACCE_DOMINIO-FACCE_ELEMENTO

    arrayNodesBoundaryFaces = table2array(tableNodesBoundaryFaces);
    arrayNodalCoordinates = table2array(tableNodalCoordinates);
    [m, ~] = size(arrayNodesBoundaryFaces);

    arrayBoundaryFacesDomainBoundaryFacesElement = zeros(m,1);

    for i=1:m
        faceNodes = arrayNodesBoundaryFaces(i,:);
        isTriangularFace = any(faceNodes == -1, 2);
        if isTriangularFace
            faceNodes = faceNodes(2:end);
        end
        faceCoordinates = arrayNodalCoordinates(faceNodes, :);

        for j=1:numberOfBoundary
            boundaryCoordinates = mphgetcoords(model, selectedComponentGeometryTag, 'boundary', j)';

            isInside = checkFacesInDomain(boundaryCoordinates, faceCoordinates);

            if isInside
                arrayBoundaryFacesDomainBoundaryFacesElement(i,1) = j;
            end
        end

    end

end

