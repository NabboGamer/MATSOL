function incidenceMatrices = createIncidenceMatricesForCLI(model, selectedComponentGeometryTag, geometryTagPos, meshdata, meshdataTypeList, searchedString, elementsOrder, flagsStruct, fileName, flagFacesEqual)
    %CREATEINCIDENCEMATRICESFORCLI si occupa di calcolare le matrice di incidenza selezionata per la mesh specificata del modello scelto 
    
    %% Creazione della struct che contiene le matrici di incidenza
    incidenceMatrices = struct();

    cprintf('Text', 'INCIDENCE MATRICES GENERATION FOR MESH ELEMENT TYPE %s \n', upper(searchedString));
    cprintf('Text', '\n');
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
    % Creazione delle etichette per righe e colonne della tabella
    nodeLabels = strcat('n_', string(1:size(transposedMatrixNodes, 1)))';
    coordinateLabels = ["x", "y", "z"];
    % Creazione della tabella degli elementi
    tableNodalCoordinates = array2table(transposedMatrixNodes, 'RowNames', nodeLabels, 'VariableNames', coordinateLabels);
    incidenceMatrices.arrayNodalCoordinates = transposedMatrixNodes;
    tempo_esecuzione = toc;
    fprintf("Generation completed in %f sec!\n", tempo_esecuzione);

    % MATRICE NODI-ELEMENTI
    fprintf('\n');
    fprintf("Start generation of NODES-ELEMENTS incidence matrix...\n");
    tic;
    meshdataTypePos = strcmp(meshdataTypeList, searchedString);
    %N.B.: Come da documentazione gli elementi sono indicizzati da 0 quindi
    %      bisogna aggiungere 1
    if elementsOrder == 2
        try
            if strcmp(searchedString, 'tet')
                elements = double(meshdata.elements(geometryTagPos).tet.nodes+1);
            elseif strcmp(searchedString, 'pyr') 
                elements = double(meshdata.elements(geometryTagPos).pyr.nodes+1);
            elseif strcmp(searchedString, 'prism')
                elements = double(meshdata.elements(geometryTagPos).prism.nodes+1);
            elseif strcmp(searchedString, 'hex')
                elements = double(meshdata.elements(geometryTagPos).hex.nodes+1);
            end
        catch
            incidenceMatrices = struct();
            return;
        end
    else
        elements = double(meshdata.elem{meshdataTypePos}+1);
    end
    transposedMatrixElements = elements';
    elementLabels = strcat('e_', string(1:size(transposedMatrixElements, 1)))';
    nodeLabels = strcat('n_', string(1:size(transposedMatrixElements, 2)));
    tableNodesElements = array2table(transposedMatrixElements, 'RowNames', elementLabels, 'VariableNames', nodeLabels);
    incidenceMatrices.arrayNodesElements = transposedMatrixElements;
    tempo_esecuzione = toc;
    fprintf("Generation completed in %f sec!\n", tempo_esecuzione);

    if (flagsStruct.arrayNodesFaces.calculate ||...
       flagsStruct.arrayNodesBoundaryFaces.calculate ||...
       flagsStruct.arrayNodesSides.calculate ||...
       flagsStruct.arrayFacesElements.calculate ||...
       flagsStruct.arraySidesElements.calculate ||...
       flagsStruct.arraySidesFaces.calculate ||...
       flagsStruct.arrayAll.calculate)

        % MATRICE NODI-FACCE(totali)
        fprintf('\n');
        fprintf("Start generation of NODES-FACES incidence matrix...\n");
        tic;
        if flagFacesEqual
            [arrayNodesFaces, ~] = createArrayNodesFacesPolyhedraWithAllFacesEqual(tableNodesElements, searchedString, elementsOrder);
        else
            [arrayNodesFaces, ~] = createArrayNodesFacesPolyhedraWithDifferentFaces(tableNodesElements, searchedString, elementsOrder);
        end
        faceLabels = strcat('f_', string(1:size(arrayNodesFaces, 1)))';
        nodeLabels = strcat('n_', string(1:size(arrayNodesFaces, 2)));
        tableNodesFaces = array2table(arrayNodesFaces, 'RowNames', faceLabels, 'VariableNames', nodeLabels);
        incidenceMatrices.arrayNodesFaces = arrayNodesFaces;
        tempo_esecuzione = toc;
        fprintf("Generation completed in %f sec!\n", tempo_esecuzione);
    end

    if (flagsStruct.arrayNodesBoundaryFaces.calculate ||...
        flagsStruct.arraySidesBoundaryFaces.calculate ||...
        flagsStruct.arrayBoundaryFacesDomainBoundaryFacesElement.calculate ||...
        flagsStruct.arrayAll.calculate)

        % MATRICE NODI-FACCE(frontiera)
        fprintf('\n');
        fprintf("Start generation of NODES-BOUNDARY_FACES incidence matrix...\n");
        tic;
        if flagFacesEqual
            [~, arrayNodesBoundaryFaces] = createArrayNodesFacesPolyhedraWithAllFacesEqual(tableNodesElements, searchedString, elementsOrder);
        else
            [~, arrayNodesBoundaryFaces] = createArrayNodesFacesPolyhedraWithDifferentFaces(tableNodesElements, searchedString, elementsOrder);
        end
        boundaryFaceLabels = strcat('bf_', string(1:size(arrayNodesBoundaryFaces, 1)))';
        nodeLabels = strcat('n_', string(1:size(arrayNodesBoundaryFaces, 2)));
        tableNodesBoundaryFaces = array2table(arrayNodesBoundaryFaces, 'RowNames', boundaryFaceLabels, 'VariableNames', nodeLabels);
        incidenceMatrices.arrayNodesBoundaryFaces = arrayNodesBoundaryFaces;
        tempo_esecuzione = toc;
        fprintf("Generation completed in %f sec!\n", tempo_esecuzione);
    end

    if (flagsStruct.arrayNodesSides.calculate ||...
        flagsStruct.arraySidesElements.calculate ||...
        flagsStruct.arraySidesFaces.calculate ||...
        flagsStruct.arraySidesBoundaryFaces.calculate ||...
        flagsStruct.arrayAll.calculate)

        % MATRICE NODI-LATI
        fprintf('\n');
        fprintf("Start generation of NODES-SIDES incidence matrix...\n");
        tic;
        if flagFacesEqual
            arrayNodesSides = createArrayNodesSidesPolyhedraWithAllFacesEqual(tableNodesFaces, searchedString, elementsOrder);
        else
            arrayNodesSides = createArrayNodesSidesPolyhedraWithDifferentFaces(tableNodesFaces, elementsOrder);
        end
        sideLabels = strcat('s_', string(1:size(arrayNodesSides, 1)))';
        nodeLabels = strcat('n_', string(1:size(arrayNodesSides, 2)));
        tableNodesSides = array2table(arrayNodesSides, 'RowNames', sideLabels, 'VariableNames', nodeLabels);
        incidenceMatrices.arrayNodesSides = arrayNodesSides;
        tempo_esecuzione = toc;
        fprintf("Generation completed in %f sec!\n", tempo_esecuzione);
    end

    if (flagsStruct.arrayFacesElements.calculate ||...
        flagsStruct.arrayAll.calculate)

        % MATRICE FACCE-ELEMENTI
        fprintf('\n');
        fprintf("Start generation of FACES-ELEMENTS incidence matrix...\n");
        tic;
        if flagFacesEqual
            arrayFacesElements = createArrayFacesElementsPolyhedraWithAllFacesEqual(tableNodesElements, tableNodesFaces, searchedString);
        else
            arrayFacesElements = createArrayFacesElementsPolyhedraWithDifferentFaces(tableNodesElements, tableNodesFaces, elementsOrder);
        end
        elementLabels = strcat('e_', string(1:size(arrayFacesElements, 1)))';
        faceLabels = strcat('f_', string(1:size(arrayFacesElements, 2)));
        tableFacesElements = array2table(arrayFacesElements, 'RowNames', elementLabels, 'VariableNames', faceLabels);
        incidenceMatrices.arrayFacesElements = arrayFacesElements;
        tempo_esecuzione = toc;
        fprintf("Generation completed in %f sec!\n", tempo_esecuzione);
    end

    if (flagsStruct.arraySidesElements.calculate ||...
       flagsStruct.arrayAll.calculate)

        % MATRICE LATI-ELEMENTI
        fprintf('\n');
        fprintf("Start generation of SIDES-ELEMENTS incidence matrix...\n");
        tic;
        if flagFacesEqual
            arraySidesElements = createArraySidesElementsPolyhedraWithAllFacesEqual(tableNodesElements, tableNodesSides, searchedString, elementsOrder);
        else
            arraySidesElements = createArraySidesElementsPolyhedraWithDifferentFaces(tableNodesElements, tableNodesSides, searchedString, elementsOrder);
        end
        elementLabels = strcat('e_', string(1:size(arraySidesElements, 1)))';
        sideLabels = strcat('s_', string(1:size(arraySidesElements, 2)));
        tableSidesElements = array2table(arraySidesElements, 'RowNames', elementLabels, 'VariableNames', sideLabels);
        incidenceMatrices.arraySidesElements = arraySidesElements;
        tempo_esecuzione = toc;
        fprintf("Generation completed in %f sec!\n", tempo_esecuzione);
    end
    
    if (flagsStruct.arraySidesFaces.calculate ||...
        flagsStruct.arrayAll.calculate)

        % MATRICE LATI-FACCE(totali)
        fprintf('\n');
        fprintf("Start generation of SIDES-FACES incidence matrix...\n");
        tic;
        if flagFacesEqual
            arraySidesFaces = createArraySidesFacesPolyhedraWithAllFacesEqual(tableNodesFaces, tableNodesSides, searchedString, elementsOrder);
        else
            arraySidesFaces = createArraySidesFacesPolyhedraWithDifferentFaces(tableNodesFaces, tableNodesSides, elementsOrder);
        end
        faceLabels = strcat('f_', string(1:size(arraySidesFaces, 1)))';
        sideLabels = strcat('s_', string(1:size(arraySidesFaces, 2)));
        tableSidesFaces = array2table(arraySidesFaces, 'RowNames', faceLabels, 'VariableNames', sideLabels);
        incidenceMatrices.arraySidesFaces = arraySidesFaces;
        tempo_esecuzione = toc;
        fprintf("Generation completed in %f sec!\n", tempo_esecuzione);
    end

    if (flagsStruct.arraySidesBoundaryFaces.calculate ||...
        flagsStruct.arrayAll.calculate)
        
        % MATRICE LATI-FACCE(di frontiera)
        fprintf('\n');
        fprintf("Start generation of SIDES-BOUNDARY_FACES incidence matrix...\n");
        tic;
        if flagFacesEqual
            arraySidesBoundaryFaces = createArraySidesFacesPolyhedraWithAllFacesEqual(tableNodesBoundaryFaces, tableNodesSides, searchedString, elementsOrder);
        else
            arraySidesBoundaryFaces = createArraySidesFacesPolyhedraWithDifferentFaces(tableNodesBoundaryFaces, tableNodesSides, elementsOrder);
        end
        boundaryFaceLabels = strcat('bf_', string(1:size(arraySidesBoundaryFaces, 1)))';
        sideLabels = strcat('s_', string(1:size(arraySidesBoundaryFaces, 2)));
        tableSidesBoundaryFaces = array2table(arraySidesBoundaryFaces, 'RowNames', boundaryFaceLabels, 'VariableNames', sideLabels);
        incidenceMatrices.arraySidesBoundaryFaces = arraySidesBoundaryFaces;
        tempo_esecuzione = toc;
        fprintf("Generation completed in %f sec!\n", tempo_esecuzione);
    end
    
    if (flagsStruct.arrayDomainsElements.calculate ||...
        flagsStruct.arrayAll.calculate)

        % MATRICE DOMINI-ELEMENTI
        fprintf('\n');
        fprintf("Start generation of DOMAINS-ELEMENTS incidence matrix...\n");
        tic;
        if elementsOrder == 2
            cprintf('Keywords', 'Unfortunately, the livelink does not \n');
            cprintf('Keywords', 'currently provide information about the \n');
            cprintf('Keywords', 'domain of membership for second-order elements, \n');
            cprintf('Keywords', 'so this matrix cannot be generated. \n');
            tempo_esecuzione = toc;
            fprintf("Generation interrupted after %f sec!\n", tempo_esecuzione);
        else
            arrayDomainsElements = meshdata.elementity{meshdataTypePos};
            faceLabels = strcat('e_', string(1:size(arrayDomainsElements, 1)))';
            domainLabels = "domain";
            tableDomainsElements = array2table(arrayDomainsElements, 'RowNames', faceLabels, 'VariableNames', domainLabels);
            incidenceMatrices.arrayDomainsElements = arrayDomainsElements;
            tempo_esecuzione = toc;
            fprintf("Generation completed in %f sec!\n", tempo_esecuzione);
        end
    end

    if (flagsStruct.arrayBoundaryFacesDomainBoundaryFacesElement.calculate ||...
        flagsStruct.arrayAll.calculate)

         % MATRICE FACCE_FRONTIERA_DOMINIO-FACCE_FRONTIERA_ELEMENTO
        fprintf('\n');
        fprintf("Start generation of BF_DOMAIN-BF_ELEMENT incidence matrix...\n");
        tic;
        numberOfBoundary = model.geom(selectedComponentGeometryTag).getNBoundaries();
        if flagFacesEqual
            arrayBoundaryFacesDomainBoundaryFacesElement = createArrayBfdBfePolyhedraWithAllFacesEqual(model, tableNodesBoundaryFaces, tableNodalCoordinates, selectedComponentGeometryTag, numberOfBoundary, searchedString, elementsOrder);
        else
            arrayBoundaryFacesDomainBoundaryFacesElement = createArrayBfdBfePolyhedraWithDifferentFaces(model, tableNodesBoundaryFaces, tableNodalCoordinates, selectedComponentGeometryTag, numberOfBoundary, elementsOrder);
        end
        boundaryFacesElementLabels = strcat('bf_element_', string(1:size(arrayBoundaryFacesDomainBoundaryFacesElement, 1)))';
        BoundaryFacesDomainLabels = "bf_domain";
        tableBoundaryFacesDomainBoundaryFacesElement = array2table(arrayBoundaryFacesDomainBoundaryFacesElement, 'RowNames', boundaryFacesElementLabels, 'VariableNames', BoundaryFacesDomainLabels);
        incidenceMatrices.arrayBoundaryFacesDomainBoundaryFacesElement = arrayBoundaryFacesDomainBoundaryFacesElement;
        tempo_esecuzione = toc;
        fprintf("Generation completed in %f sec!\n", tempo_esecuzione);
    end

    if (flagsStruct.arrayNodesFaces.save ||...
        flagsStruct.arrayNodesBoundaryFaces.save ||...
        flagsStruct.arrayNodesSides.save ||...
        flagsStruct.arrayFacesElements.save ||...
        flagsStruct.arraySidesElements.save ||...
        flagsStruct.arraySidesFaces.save ||...
        flagsStruct.arraySidesBoundaryFaces.save ||...
        flagsStruct.arrayDomainsElements.save ||...
        flagsStruct.arrayBoundaryFacesDomainBoundaryFacesElement.save ||...
        flagsStruct.arrayAll.save)
        
        cprintf('Text', '\n');
        saveToJson(incidenceMatrices, fileName);
    end
    cprintf('Text', '======================================================================= \n');
    
end