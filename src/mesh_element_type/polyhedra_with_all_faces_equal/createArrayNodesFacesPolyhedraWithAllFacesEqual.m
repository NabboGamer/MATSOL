function [arrayNodesFaces, arrayNodesBoundaryFaces] = createArrayNodesFacesPolyhedraWithAllFacesEqual(tableNodesElements, elementType, elementsOrder)
    %CREATEARRAYNODESFACES si occupa di creare la matrice NODI-FACCE(sia per tutte le facce, che per le sole facce di frontiera) per tutti gli elementi
    
    arrayNodesElements = table2array(tableNodesElements);

    % Inizializzazione della matrice NODI-FACCE
    numElements = size(arrayNodesElements, 1);
    if elementsOrder == 2
        if strcmp(elementType, 'hex')
            numFacesPerElements = 6;  % Ogni esaedro ha 6 facce
            numNodesPerFace = 9;      % Ogni faccia è definita da 9 nodi
        elseif strcmp(elementType, 'tet')
            numFacesPerElements = 4;  % Ogni tetraedro ha 4 facce
            numNodesPerFace = 6;      % Ogni faccia è definita da 6 nodi
        end
    else
        if strcmp(elementType, 'hex')
            numFacesPerElements = 6;  % Ogni esaedro ha 6 facce
            numNodesPerFace = 4;      % Ogni faccia è definita da 4 nodi
        elseif strcmp(elementType, 'tet')
            numFacesPerElements = 4;  % Ogni tetraedro ha 4 facce
            numNodesPerFace = 3;      % Ogni faccia è definita da 3 nodi
        end
    end
    
    % Inizializzazione della matrice che conterrà i nodi per ogni faccia
    arrayNodesFaces = zeros(numElements * numFacesPerElements, numNodesPerFace);
    
    % Iterazione sugli elementi
    for e = 1:numElements
        % Nodi dell'elemento corrente
        nodes = arrayNodesElements(e, :);

        if elementsOrder == 2
            % N.B.: In questo caso le facce non le ho formate seguendo
            %       la convenzione dettata da COMSOL, poichè i nodi non
            %       si trovavano in quell'ordine nelle righe dell'array ricavato
            %       con mphxmeshinfo. Le ho invece formate disegnando a
            %       mano un elemento qualsiasi e trovando la posizione nell'array
            %       dei nodi che formano le varie facce per quell'elemento.
            if strcmp(elementType, 'hex')
                % Definizione delle 6 facce per l'elemento secondo la notazione corretta
                faces = [
                    nodes([1, 2, 3, 4, 5, 6, 7, 8, 9]);             % Faccia inferiore
                    nodes([19, 20, 21, 22, 23, 24, 25, 26, 27]);    % Faccia superiore
                    nodes([1, 4, 7, 10, 13, 16, 19, 22, 25]);       % Faccia frontale
                    nodes([3, 6, 9, 12, 15, 18, 21, 24, 27]);       % Faccia posteriore
                    nodes([7, 8, 9, 16, 17, 18, 25, 26, 27]);       % Faccia sinistra
                    nodes([1, 2, 3, 10, 11, 12, 19, 20, 21]);       % Faccia destra
                ];
            elseif strcmp(elementType, 'tet')
                % Definizione delle 6 facce per l'elemento secondo la notazione corretta
                faces = [
                    nodes([1, 2, 3, 5, 6, 7]);       % Faccia inferiore    (N1, N2, N3, N5, N6, N7)
                    nodes([1, 2, 4, 5, 8, 9]);       % Faccia laterale 1   (N1, N2, N4, N5, N8, N9)
                    nodes([1, 3, 4, 6, 8, 10]);      % Faccia laterale 2   (N1, N3, N4, N6, N8, N10)
                    nodes([2, 3, 4, 7, 9, 10]);      % Faccia laterale 3   (N2, N3, N4, N7, N9, N10)
                ]; 
            end
        else
            if strcmp(elementType, 'hex')
                % Definizione delle 6 facce per l'elemento secondo la notazione corretta
                faces = [
                    nodes([1, 2, 3, 4]);    % Faccia inferiore  (N1, N2, N3, N4)
                    nodes([5, 6, 7, 8]);    % Faccia superiore  (N5, N6, N7, N8)
                    nodes([1, 2, 5, 6]);    % Faccia frontale   (N1, N2, N5, N6)
                    nodes([3, 4, 7, 8]);    % Faccia posteriore (N3, N4, N7, N8)
                    nodes([1, 3, 5, 7]);    % Faccia sinistra   (N1, N3, N5, N7)
                    nodes([2, 4, 6, 8]);    % Faccia destra     (N2, N4, N6, N8)
                ];
            elseif strcmp(elementType, 'tet')
                % Definizione delle 6 facce per l'elemento secondo la notazione corretta
                faces = [
                    nodes([1, 2, 3]);       % Faccia inferiore    (N1, N2, N3)
                    nodes([1, 2, 4]);       % Faccia laterale 1   (N1, N2, N4)
                    nodes([1, 3, 4]);       % Faccia laterale 2   (N1, N3, N4)
                    nodes([2, 3, 4]);       % Faccia laterale 3   (N2, N3, N4)
                ]; 
            end
        end
        
        % Inserimento delle facce nella matrice NodiFacce
        startIdx = (e - 1) * numFacesPerElements + 1;
        endIdx = e * numFacesPerElements;
        arrayNodesFaces(startIdx:endIdx, :) = faces;
    end

    % Ordina gli elementi di ciascuna riga. Ordinare ogni riga di arrayNodesFaces serve a garantire che le facce siano 
    % considerate uguali indipendentemente dall'ordine dei nodi. In altre parole, se due facce contengono gli stessi nodi
    % ma in ordine diverso, il sorting delle righe permette di riconoscerle come identiche.
    arrayNodesFacesSorted = sort(arrayNodesFaces, 2);
    % Trova le righe uniche ordinate e la loro occorrenza
    %   uniqueFaces: contiene le righe uniche di arrayNodesFacesSorted, che rappresentano le facce uniche
    %            ia: contiene gli indici delle prime occorrenze delle righe uniche in arrayNodesFacesSorted
    %            ic: è un array della stessa dimensione di arrayNodesFacesSorted che indica a quale riga unica 
    %                (tra quelle in uniqueFaces) corrisponde ciascuna riga originale.
    [~, ia, ic] = unique(arrayNodesFacesSorted, 'rows', 'stable');
    uniqueFaces = arrayNodesFaces(ia, :);
    % Trova la loro occorrenza 
    %   unique(ic): restituisce i valori unici presenti in ic. Questi valori corrispondono alle righe uniche 
    %               trovate in arrayNodesFacesSorted.
    %        histc: conta il numero di occorrenze di ciascun valore in un array, ovvero conta quante volte ogni 
    %               valore unico appare in ic. 
    %   faceCounts: è un array che contiene il numero di volte che ogni faccia unica appare in arrayNodesFacesSorted
    faceCounts = histc(ic, unique(ic));
    
    % Identifica le facce di frontiera(una faccia di frontiera è una faccia unica che appartiene a un solo elemento)
    boundaryFaceIdx = faceCounts == 1;
    
    arrayNodesBoundaryFaces = uniqueFaces(boundaryFaceIdx, :);
    arrayNodesFaces = uniqueFaces;

end
