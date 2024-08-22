function sorted_points = sortPolygonVertices(points)
    % Ordina i vertici di un poligono in senso orario
    % Calcola il baricentro del poligono
    centroid = mean(points);
    % Calcola l'angolo di ogni punto rispetto al baricentro
    angles = atan2(points(:,2) - centroid(2), points(:,1) - centroid(1));
    % Ordina i punti in base agli angoli in senso orario
    [~, order] = sort(angles);
    sorted_points = points(order, :);
end