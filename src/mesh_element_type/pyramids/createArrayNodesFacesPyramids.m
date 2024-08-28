function [arrayNodesFaces, arrayNodesBoundaryFaces] = createArrayNodesFacesPyramids(tableNodesElements)
    %CREATEARRAYNODESFACES si occupa di creare la matrice NODI-FACCE(sia per tutte le facce, che per le sole facce di frontiera) per tutti gli elementi
    
    arrayNodesElements = table2array(tableNodesElements);

    % Inizializzazione della matrice NODI-FACCE
    numElements = size(arrayNodesElements, 1);
    numFacesPerElement = 5;             % Ogni prisma retto triangolare ha 5 facce(2 triangoli e 3 rettangoli)
    numNodesPerRectangularFace = 4;     % Ogni faccia rettangolare è definita da 4 nodi
    % numNodesPerTriangularFace = 3;      % Ogni faccia triangolare è definita da 3 nodi
    
    % Inizializzazione della matrice che conterrà i nodi per ogni faccia
    arrayNodesFaces = zeros(numElements * numFacesPerElement, numNodesPerRectangularFace);
    
    % Iterazione sugli elementi
    for e = 1:numElements
        % Nodi dell'elemento corrente
        nodes = arrayNodesElements(e, :);
        
        % Definizione delle 6 facce per l'elemento secondo la notazione corretta
        faces = [
            nodes([1, 2, 3, 4]);    % Faccia inferiore    (N1, N2, N3, N4)
            nodes([1, 2, 5]),-1;    % Faccia laterale 1   (N1, N2, N5)
            nodes([1, 3, 5]),-1;    % Faccia laterale 2   (N1, N3, N5)
            nodes([2, 4, 5]),-1;    % Faccia laterale 3   (N2, N4, N5)
            nodes([3, 4, 5]),-1;    % Faccia laterale 4   (N3, N4, N5)
        ];
        
        % Inserimento delle facce nella matrice NodiFacce
        startIdx = (e - 1) * numFacesPerElement + 1;
        endIdx = e * numFacesPerElement;
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
