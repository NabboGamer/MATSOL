function [arrayDomainsElements] = createArrayDomainsElements(model, tableNodesElements, tableNodalCoordinates, selectedComponentGeometryTag, numberOfDomains, domainType)
    %CREATEARRAYDOMAINSELEMENTS si occupa di creare la matrice DOMINI-ELEMENTI

    arrayNodesElements = table2array(tableNodesElements);
    arrayNodalCoordinates = table2array(tableNodalCoordinates);
    [m, ~] = size(tableNodesElements);

    arrayDomainsElements = zeros(m,1);

    for i=1:m
        elementNodes = arrayNodesElements(i, :);
        elementCoordinates = arrayNodalCoordinates(elementNodes, :);

        for j=1:numberOfDomains
            domainCoordinates = mphgetcoords(model, selectedComponentGeometryTag, 'domain', j)';

            [minColumnValue, ~] = min(domainCoordinates, [], 1);
            [maxColumnValue, ~] = max(domainCoordinates, [], 1);
            domain.x_min = minColumnValue(1); 
            domain.y_min = minColumnValue(2); 
            domain.z_min = minColumnValue(3);
            domain.x_max = maxColumnValue(1);
            domain.y_max = maxColumnValue(2);
            domain.z_max = maxColumnValue(3);

            isInside = checkElementInDomain(elementCoordinates, domain, domainType);

            if isInside
                arrayDomainsElements(i,1) = j;
            end
        end
    end

end

