function incidenceMatrices = createIncidenceMatricesForCLI(model, selectedComponentGeometryTag, geometryTagPos, meshdata, meshdataTypeList, searchedString, elementsOrder)
    %CREATEINCIDENCEMATRICESFORCLI si occupa di calcolare le matrice di incidenza selezionata per la mesh specificata del modello scelto 
    
    %% Creazione della struct che contiene le matrici di incidenza
    incidenceMatrices = struct();
    % incidenceMatrices.arrayNodesFaces = arrayNodesFaces;
    % incidenceMatrices.arrayNodesBoundaryFaces = arrayNodesBoundaryFaces;
    % incidenceMatrices.arrayNodesSides = arrayNodesSides;
    % incidenceMatrices.arrayFacesElements = arrayFacesElements;
    % incidenceMatrices.arraySidesElements = arraySidesElements;
    % incidenceMatrices.arraySidesFaces = arraySidesFaces;
    % incidenceMatrices.arraySidesBoundaryFaces = arraySidesBoundaryFaces;
    % if elementsOrder < 2   
    %     incidenceMatrices.arrayDomainsElements = arrayDomainsElements;
    % end
    % incidenceMatrices.arrayBoundaryFacesDomainBoundaryFacesElement = arrayBoundaryFacesDomainBoundaryFacesElement;


    % MATRICE COORDINATE NODALI
    fprintf("Start generation of NODAL COORDINATES matrix...\n");
    tic;
    if elementsOrder == 2
        nodes = double(meshdata.nodes(geometryTagPos).coords);
    else
        nodes = meshdata.vertex;
    end
    % Trasposizione della matrice degli elementi
    transposedMatrixNodes = nodes';

    incidenceMatrices.arrayNodalCoordinates = transposedMatrixNodes;

    tempo_esecuzione = toc;
    fprintf("Generation completed in %f sec!\n", tempo_esecuzione);
    fprintf('\n');

    % MATRICE NODI-ELEMENTI
    fprintf("Start NODES-ELEMENTS incidence matrix generation...\n");
    tic;
    meshdataTypePos = strcmp(meshdataTypeList, searchedString);
    %N.B.: Come da documentazione gli elementi sono indicizzati da 0 quindi
    %      bisogna aggiungere 1
    if elementsOrder == 2
        if strcmp(searchedString, 'tet')
            elements = double(meshdata.elements(geometryTagPos).tet.nodes+1);
        elseif strcmp(searchedString, 'pyr') 
            elements = double(meshdata.elements(geometryTagPos).pyr.nodes+1);
        elseif strcmp(searchedString, 'prism')
            elements = double(meshdata.elements(geometryTagPos).prism.nodes+1);
        elseif strcmp(searchedString, 'hex')
            elements = double(meshdata.elements(geometryTagPos).hex.nodes+1);
        end
    else
        elements = double(meshdata.elem{meshdataTypePos}+1);
    end
    transposedMatrixElements = elements';
    incidenceMatrices.arrayNodesElements = transposedMatrixElements;
    tempo_esecuzione = toc;
    fprintf("Generation completed in %f sec!\n", tempo_esecuzione);
    fprintf('\n');

    % % MATRICE NODI-FACCE(totali e di frontiera)
    % fprintf("Inizio generazione matrice di incidenza NODI-FACCE(tot e fro)...\n");
    % tic;
    % [arrayNodesFaces, arrayNodesBoundaryFaces] = createArrayNodesFacesPolyhedraWithAllFacesEqual(tableNodesElements, searchedString, elementsOrder);
    % faceLabels = strcat('f_', string(1:size(arrayNodesFaces, 1)))';
    % nodeLabels = strcat('n_', string(1:size(arrayNodesFaces, 2)));
    % tableNodesFaces = array2table(arrayNodesFaces, 'RowNames', faceLabels, 'VariableNames', nodeLabels);
    % % assignin('base', 'tableNodesFaces', tableNodesFaces);
    % boundaryFaceLabels = strcat('bf_', string(1:size(arrayNodesBoundaryFaces, 1)))';
    % nodeLabels = strcat('n_', string(1:size(arrayNodesBoundaryFaces, 2)));
    % tableNodesBoundaryFaces = array2table(arrayNodesBoundaryFaces, 'RowNames', boundaryFaceLabels, 'VariableNames', nodeLabels);
    % % assignin('base', 'tableNodesBoundaryFaces', tableNodesBoundaryFaces);
    % tempo_esecuzione = toc;
    % fprintf("Generazione completata in %f sec!\n", tempo_esecuzione);
    % fprintf('\n');
    % 
    % % MATRICE NODI-LATI
    % fprintf("Inizio generazione matrice di incidenza NODI-LATI...\n");
    % tic;
    % arrayNodesSides = createArrayNodesSidesPolyhedraWithAllFacesEqual(tableNodesFaces, searchedString, elementsOrder);
    % sideLabels = strcat('s_', string(1:size(arrayNodesSides, 1)))';
    % nodeLabels = strcat('n_', string(1:size(arrayNodesSides, 2)));
    % tableNodesSides = array2table(arrayNodesSides, 'RowNames', sideLabels, 'VariableNames', nodeLabels);
    % % assignin('base', 'tableNodesSides', tableNodesSides);
    % tempo_esecuzione = toc;
    % fprintf("Generazione completata in %f sec!\n", tempo_esecuzione);
    % fprintf('\n');
    % 
    % % MATRICE FACCE-ELEMENTI
    % fprintf("Inizio generazione matrice di incidenza FACCE-ELEMENTI...\n");
    % tic;
    % arrayFacesElements = createArrayFacesElementsPolyhedraWithAllFacesEqual(tableNodesElements, tableNodesFaces, searchedString);
    % elementLabels = strcat('e_', string(1:size(arrayFacesElements, 1)))';
    % faceLabels = strcat('f_', string(1:size(arrayFacesElements, 2)));
    % tableFacesElements = array2table(arrayFacesElements, 'RowNames', elementLabels, 'VariableNames', faceLabels);
    % % assignin('base', 'tableFacesElements', tableFacesElements);
    % tempo_esecuzione = toc;
    % fprintf("Generazione completata in %f sec!\n", tempo_esecuzione);
    % fprintf('\n');
    % 
    % % MATRICE LATI-ELEMENTI
    % fprintf("Inizio generazione matrice di incidenza LATI-ELEMENTI...\n");
    % tic;
    % arraySidesElements = createArraySidesElementsPolyhedraWithAllFacesEqual(tableNodesElements, tableNodesSides, searchedString, elementsOrder);
    % elementLabels = strcat('e_', string(1:size(arraySidesElements, 1)))';
    % sideLabels = strcat('s_', string(1:size(arraySidesElements, 2)));
    % tableSidesElements = array2table(arraySidesElements, 'RowNames', elementLabels, 'VariableNames', sideLabels);
    % % assignin('base', 'tableSidesElements', tableSidesElements);
    % tempo_esecuzione = toc;
    % fprintf("Generazione completata in %f sec!\n", tempo_esecuzione);
    % fprintf('\n');
    % 
    % % MATRICE LATI-FACCE(totali e di frontiera)
    % fprintf("Inizio generazione matrice di incidenza LATI-FACCE(tot e fro)...\n");
    % tic;
    % arraySidesFaces = createArraySidesFacesPolyhedraWithAllFacesEqual(tableNodesFaces, tableNodesSides, searchedString, elementsOrder);
    % faceLabels = strcat('f_', string(1:size(arraySidesFaces, 1)))';
    % sideLabels = strcat('s_', string(1:size(arraySidesFaces, 2)));
    % tableSidesFaces = array2table(arraySidesFaces, 'RowNames', faceLabels, 'VariableNames', sideLabels);
    % % assignin('base', 'tableSidesFaces', tableSidesFaces);
    % 
    % arraySidesBoundaryFaces = createArraySidesFacesPolyhedraWithAllFacesEqual(tableNodesBoundaryFaces, tableNodesSides, searchedString, elementsOrder);
    % boundaryFaceLabels = strcat('bf_', string(1:size(arraySidesBoundaryFaces, 1)))';
    % sideLabels = strcat('s_', string(1:size(arraySidesBoundaryFaces, 2)));
    % tableSidesBoundaryFaces = array2table(arraySidesBoundaryFaces, 'RowNames', boundaryFaceLabels, 'VariableNames', sideLabels);
    % % assignin('base', 'tableSidesBoundaryFaces', tableSidesBoundaryFaces);
    % tempo_esecuzione = toc;
    % fprintf("Generazione completata in %f sec!\n", tempo_esecuzione);
    % fprintf('\n');
    % 
    % % MATRICE DOMINI-ELEMENTI
    % fprintf("Inizio generazione matrice di incidenza DOMINI-ELEMENTI...\n");
    % tic;
    % if elementsOrder == 2
    %     cprintf('Keywords', '***INFO: Purtroppo al momento il livelink non fornisce informazioni relative al dominio di appartenenza per elementi del secondo ordine, quindi questa matrice non può essere generata \n');
    %     tempo_esecuzione = toc;
    %     fprintf("Generazione interrotta dopo %f sec!\n", tempo_esecuzione);
    %     fprintf('\n');
    % else
    %     arrayDomainsElements = meshdata.elementity{meshdataTypePos};
    %     faceLabels = strcat('e_', string(1:size(arrayDomainsElements, 1)))';
    %     domainLabels = "domain";
    %     tableDomainsElements = array2table(arrayDomainsElements, 'RowNames', faceLabels, 'VariableNames', domainLabels);
    %     assignin('base', 'tableDomainsElements', tableDomainsElements);
    %     tempo_esecuzione = toc;
    %     fprintf("Generazione completata in %f sec!\n", tempo_esecuzione);
    %     fprintf('\n');
    % end
    % 
    % % MATRICE FACCE_FRONTIERA_DOMINIO-FACCE_FRONTIERA_ELEMENTO
    % fprintf("Inizio generazione matrice di incidenza FACCE_FRONTIERA_DOMINIO-FACCE_FRONTIERA_ELEMENTO...\n");
    % tic;
    % numberOfBoundary = model.geom(selectedComponentGeometryTag).getNBoundaries();
    % arrayBoundaryFacesDomainBoundaryFacesElement = createArrayBfdBfePolyhedraWithAllFacesEqual(model, tableNodesBoundaryFaces, tableNodalCoordinates, selectedComponentGeometryTag, numberOfBoundary, searchedString, elementsOrder);
    % boundaryFacesElementLabels = strcat('bf_element_', string(1:size(arrayBoundaryFacesDomainBoundaryFacesElement, 1)))';
    % BoundaryFacesDomainLabels = "bf_domain";
    % tableBoundaryFacesDomainBoundaryFacesElement = array2table(arrayBoundaryFacesDomainBoundaryFacesElement, 'RowNames', boundaryFacesElementLabels, 'VariableNames', BoundaryFacesDomainLabels);
    % % assignin('base', 'tableBoundaryFacesDomainBoundaryFacesElement', tableBoundaryFacesDomainBoundaryFacesElement);
    % tempo_esecuzione = toc;
    % fprintf("Generazione completata in %f sec!\n", tempo_esecuzione);
    % fprintf('\n');
    
end