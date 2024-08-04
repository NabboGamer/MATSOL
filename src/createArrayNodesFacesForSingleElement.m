function [arrayNodesFacesForSingleElement] = createArrayNodesFacesForSingleElement(coords, arrayNodalCoordinates)
    % Questa function si occupa di creare la matrice NODI-FACCE per un
    % singolo elemento
    
    arrayNodesFacesForSingleElementWithLocalNumbering = createArrayNodesFacesForSingleElementWithLocalNumbering(coords);

    [n,m] = size(arrayNodesFacesForSingleElementWithLocalNumbering);
    arrayNodesFacesForSingleElement = zeros(n, m);
    
    % Mapping dai Nodi Locali ai Nodi Globali
    for i = 1 : n
        % ismember verifica se le coordinate dei nodi (selezionate da coords usando gli indici locali) sono presenti in arrayNodalCoordinates,
        % è un vettore booleano che indica quali righe di coords sono trovate in arrayNodalCoordinates.
        [isMember, loc] = ismember(coords(arrayNodesFacesForSingleElementWithLocalNumbering(i,:), :), arrayNodalCoordinates, 'rows');
        % loc contiene gli indici delle corrispondenti righe in arrayNodalCoordinates che corrispondono a quelle in coords
        arrayNodesFacesForSingleElement(i, :) = loc(isMember)';
    end

end

