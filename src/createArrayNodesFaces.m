function [arrayNodesFaces, arrayNodesBoundaryFaces] = createArrayNodesFaces(tableNodesElements)
    %CREATEARRAYNODESFACES si occupa di creare la matrice NODI-FACCE(sia per tutte le facce, che per le sole facce di frontiera) per tutti gli elementi
    
    arrayNodesElements = table2array(tableNodesElements);

    % Inizializzazione della matrice NODI-FACCE
    numElementi = size(arrayNodesElements, 1);
    numFaccePerElemento = 6;  % Ogni esaedro ha 6 facce
    numNodiPerFaccia = 4;     % Ogni faccia è definita da 4 nodi
    
    % Inizializzazione della matrice che conterrà i nodi per ogni faccia
    arrayNodesFaces = zeros(numElementi * numFaccePerElemento, numNodiPerFaccia);
    
    % Iterazione sugli elementi
    for e = 1:numElementi
        % Nodi dell'elemento corrente
        nodi = arrayNodesElements(e, :);
        
        % Definizione delle 6 facce per l'elemento secondo la notazione corretta
        facce = [
            nodi([1, 2, 3, 4]); % Faccia inferiore  (N1, N2, N3, N4)
            nodi([5, 6, 7, 8]); % Faccia superiore  (N5, N6, N7, N8)
            nodi([1, 2, 5, 6]); % Faccia frontale   (N1, N2, N5, N6)
            nodi([3, 4, 7, 8]); % Faccia posteriore (N3, N4, N7, N8)
            nodi([1, 3, 5, 7]); % Faccia sinistra   (N1, N3, N5, N7)
            nodi([2, 4, 6, 8]); % Faccia destra     (N2, N4, N6, N8)
        ];
        
        % Inserimento delle facce nella matrice NodiFacce
        startIdx = (e - 1) * numFaccePerElemento + 1;
        endIdx = e * numFaccePerElemento;
        arrayNodesFaces(startIdx:endIdx, :) = facce;
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
    [uniqueFaces, ia, ic] = unique(arrayNodesFacesSorted, 'rows');
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