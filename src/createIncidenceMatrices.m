function createIncidenceMatrices
    %CREATEINCIDENCEMATRICES si occupa di calcolare le matrici di incidenza per la mesh specificata del modello specificato
    
    import com.comsol.model.*
    import com.comsol.model.util.*
    addpath('./utility');
    addpath('./mesh_element_type/polyhedra_with_all_faces_equal');
    addpath('./mesh_element_type/prisms');
    addpath('./mesh_element_type/pyramids');
    
    evalin('base', 'clear'), close all; clc;
    ModelUtil.clear();
    
    %% Connessione a COMSOL, caricamento del modello e assegnazione a una variabile nel workspace base
    disp("Inizio il caricamento del modello...");
    model = mphload('C:\Users\stolf\dev\Progetto Modelli Numerici per Campi e Circuiti\MATSOL\model\component_library_RF.mph');
    assignin('base', 'model', model);
    disp("Caricamento del modello terminato!");
    disp(newline)
    
    %% Estrazione del componente di interesse e assegnazione a una variabile nel workspace base
    modelComponentList = model.component();

    modelComponentTagList = string(modelComponentList.tags);
    searchedString = 'componentCube3';
    modelComponentTagPos = strcmp(modelComponentTagList, searchedString);

    selectedComponentTag = modelComponentTagList(modelComponentTagPos);
    selectedComponent = model.component(selectedComponentTag);
    % assignin('base', 'selectedComponent', selectedComponent);

    %% Estrazione della mesh di interesse, assegnazione a una variabile nel workspace base e plotting
    selectedComponentMeshList = selectedComponent.mesh();
    
    % N.B.: Per le Mesh dalla GUI di COMSOL il tag non è personalizzabile come per
    %       i Component, quindi label e tag non corrispondono.
    selectedComponentMeshTagList = string(selectedComponentMeshList.tags);
    labelTagArray = strings(size(selectedComponentMeshTagList, 1), 2);
    for i = 1:size(selectedComponentMeshTagList, 1)
        labelTagArray(i,1) = model.mesh(selectedComponentMeshTagList(i)).label();
    end
    labelTagArray(:,2) = selectedComponentMeshTagList(:);
    searchedString = 'mesh4elemPerFace';
    selectedMeshTagPos = strcmp(labelTagArray(:, 1), searchedString);

    selectedMeshTag = labelTagArray(selectedMeshTagPos, 2);
    selectedMesh = model.mesh(selectedMeshTag);
    % assignin('base', 'selectedMesh', selectedMesh);

    figure('Name', 'Plot della Mesh', 'NumberTitle', 'off');
    mphmesh(model, selectedMeshTag);
    title_string = [string(selectedMeshTag), 'di', string(selectedComponentTag)];
    title_string = string(strjoin(title_string));
    title(title_string);
    xlabel('X', 'FontWeight', 'bold');
    ylabel('Y', 'FontWeight', 'bold');
    zlabel('Z', 'FontWeight', 'bold');

    %% Creazione delle matrici di incidenza
    [meshstats,meshdata] = mphmeshstats(model, selectedMeshTag);
    assignin('base', 'meshstats', meshstats);
    assignin('base', 'meshdata', meshdata);

    meshdataTypeList = string(meshdata.types);
    assignin('base', 'meshdataTypesList', meshdataTypeList);

    % MATRICE COORDINATE NODALI
    fprintf("Inizio generazione matrice delle COORDINATE NODALI...\n");
    tic;
    nodes = meshdata.vertex;
    % Trasposizione della matrice degli elementi
    transposedMatrixNodes = nodes';
    % Creazione delle etichette per righe e colonne della tabella
    nodeLabels = strcat('n_', string(1:size(transposedMatrixNodes, 1)))';
    coordinateLabels = ["x", "y", "z"];
    % Creazione della tabella degli elementi
    tableNodalCoordinates = array2table(transposedMatrixNodes, 'RowNames', nodeLabels, 'VariableNames', coordinateLabels);
    assignin('base', 'tableNodalCoordinates', tableNodalCoordinates);
    tempo_esecuzione = toc;
    fprintf("Generazione completata in %f sec!\n", tempo_esecuzione);
    fprintf('\n');

    % MATRICE NODI-ELEMENTI
    fprintf("Inizio generazione matrice di incidenza NODI-ELEMENTI...\n");
    tic;
    searchedString = 'hex';
    meshdataTypePos = strcmp(meshdataTypeList, searchedString);
    %N.B.: Come da documentazione gli elementi sono indicizzati da 0 quindi
    %      bisogna aggiungere 1
    elements = double(meshdata.elem{meshdataTypePos}+1);
    transposedMatrixElements = elements';
    elementLabels = strcat('e_', string(1:size(transposedMatrixElements, 1)))';
    nodeLabels = strcat('n_', string(1:size(transposedMatrixElements, 2)));
    tableNodesElements = array2table(transposedMatrixElements, 'RowNames', elementLabels, 'VariableNames', nodeLabels);
    assignin('base', 'tableNodesElements', tableNodesElements);
    tempo_esecuzione = toc;
    fprintf("Generazione completata in %f sec!\n", tempo_esecuzione);
    fprintf('\n');

    % MATRICE NODI-FACCE(totali e di frontiera)
    fprintf("Inizio generazione matrice di incidenza NODI-FACCE(tot e fro)...\n");
    tic;
    [arrayNodesFaces, arrayNodesBoundaryFaces] = createArrayNodesFacesPolyhedraWithAllFacesEqual(tableNodesElements, searchedString);
    faceLabels = strcat('f_', string(1:size(arrayNodesFaces, 1)))';
    nodeLabels = strcat('n_', string(1:size(arrayNodesFaces, 2)));
    tableNodesFaces = array2table(arrayNodesFaces, 'RowNames', faceLabels, 'VariableNames', nodeLabels);
    assignin('base', 'tableNodesFaces', tableNodesFaces);
    boundaryFaceLabels = strcat('bf_', string(1:size(arrayNodesBoundaryFaces, 1)))';
    nodeLabels = strcat('n_', string(1:size(arrayNodesBoundaryFaces, 2)));
    tableNodesBoundaryFaces = array2table(arrayNodesBoundaryFaces, 'RowNames', boundaryFaceLabels, 'VariableNames', nodeLabels);
    assignin('base', 'tableNodesBoundaryFaces', tableNodesBoundaryFaces);
    tempo_esecuzione = toc;
    fprintf("Generazione completata in %f sec!\n", tempo_esecuzione);
    fprintf('\n');

    % MATRICE NODI-LATI
    fprintf("Inizio generazione matrice di incidenza NODI-LATI...\n");
    tic;
    arrayNodesSides = createArrayNodesSidesPolyhedraWithAllFacesEqual(tableNodesFaces, searchedString);
    sideLabels = strcat('s_', string(1:size(arrayNodesSides, 1)))';
    nodeLabels = strcat('n_', string(1:size(arrayNodesSides, 2)));
    tableNodesSides = array2table(arrayNodesSides, 'RowNames', sideLabels, 'VariableNames', nodeLabels);
    assignin('base', 'tableNodesSides', tableNodesSides);
    tempo_esecuzione = toc;
    fprintf("Generazione completata in %f sec!\n", tempo_esecuzione);
    fprintf('\n');

    % MATRICE FACCE-ELEMENTI
    fprintf("Inizio generazione matrice di incidenza FACCE-ELEMENTI...\n");
    tic;
    arrayFacesElements = createArrayFacesElementsPolyhedraWithAllFacesEqual(tableNodesElements, tableNodesFaces, searchedString);
    elementLabels = strcat('e_', string(1:size(arrayFacesElements, 1)))';
    faceLabels = strcat('f_', string(1:size(arrayFacesElements, 2)));
    tableFacesElements = array2table(arrayFacesElements, 'RowNames', elementLabels, 'VariableNames', faceLabels);
    assignin('base', 'tableFacesElements', tableFacesElements);
    tempo_esecuzione = toc;
    fprintf("Generazione completata in %f sec!\n", tempo_esecuzione);
    fprintf('\n');

    % MATRICE LATI-ELEMENTI
    fprintf("Inizio generazione matrice di incidenza LATI-ELEMENTI...\n");
    tic;
    arraySidesElements = createArraySidesElementsPolyhedraWithAllFacesEqual(tableNodesElements, tableNodesSides, searchedString);
    elementLabels = strcat('e_', string(1:size(arraySidesElements, 1)))';
    sideLabels = strcat('s_', string(1:size(arraySidesElements, 2)));
    tableSidesElements = array2table(arraySidesElements, 'RowNames', elementLabels, 'VariableNames', sideLabels);
    assignin('base', 'tableSidesElements', tableSidesElements);
    tempo_esecuzione = toc;
    fprintf("Generazione completata in %f sec!\n", tempo_esecuzione);
    fprintf('\n');

    % MATRICE LATI-FACCE(totali e di frontiera)
    fprintf("Inizio generazione matrice di incidenza LATI-FACCE(tot e fro)...\n");
    tic;
    arraySidesFaces = createArraySidesFacesPolyhedraWithAllFacesEqual(tableNodesFaces, tableNodesSides, searchedString);
    faceLabels = strcat('f_', string(1:size(arraySidesFaces, 1)))';
    sideLabels = strcat('s_', string(1:size(arraySidesFaces, 2)));
    tableSidesFaces = array2table(arraySidesFaces, 'RowNames', faceLabels, 'VariableNames', sideLabels);
    assignin('base', 'tableSidesFaces', tableSidesFaces);
    arraySidesBoundaryFaces = createArraySidesFacesPyramids(tableNodesBoundaryFaces, tableNodesSides);
    boundaryFaceLabels = strcat('bf_', string(1:size(arraySidesBoundaryFaces, 1)))';
    sideLabels = strcat('s_', string(1:size(arraySidesBoundaryFaces, 2)));
    tableSidesBoundaryFaces = array2table(arraySidesBoundaryFaces, 'RowNames', boundaryFaceLabels, 'VariableNames', sideLabels);
    assignin('base', 'tableSidesBoundaryFaces', tableSidesBoundaryFaces);
    tempo_esecuzione = toc;
    fprintf("Generazione completata in %f sec!\n", tempo_esecuzione);
    fprintf('\n');

    % MATRICE DOMINI-ELEMENTI
    fprintf("Inizio generazione matrice di incidenza DOMINI-ELEMENTI...\n");
    tic;
    selectedComponentGeometry = selectedComponent.geom;
    selectedComponentGeometryTag = string(selectedComponentGeometry.tags());
    arrayDomainsElements = meshdata.elementity{meshdataTypePos};
    faceLabels = strcat('e_', string(1:size(arrayDomainsElements, 1)))';
    domainLabels = "domain";
    tableDomainsElements = array2table(arrayDomainsElements, 'RowNames', faceLabels, 'VariableNames', domainLabels);
    assignin('base', 'tableDomainsElements', tableDomainsElements);
    tempo_esecuzione = toc;
    fprintf("Generazione completata in %f sec!\n", tempo_esecuzione);
    fprintf('\n');

    figure('Name', 'Plot della Geometry', 'NumberTitle', 'off');
    mphgeom(model, selectedComponentGeometryTag);
    title_string = [string(selectedComponentGeometryTag), 'di', string(selectedComponentTag)];
    title_string = string(strjoin(title_string));
    title(title_string);
    xlabel('X', 'FontWeight', 'bold');
    ylabel('Y', 'FontWeight', 'bold');
    zlabel('Z', 'FontWeight', 'bold');

    % MATRICE FACCE_FRONTIERA_DOMINIO-FACCE_FRONTIERA_ELEMENTO
    fprintf("Inizio generazione matrice di incidenza FACCE_FRONTIERA_DOMINIO-FACCE_FRONTIERA_ELEMENTO...\n");
    tic;
    numberOfBoundary = model.geom(selectedComponentGeometryTag).getNBoundaries();
    arrayBoundaryFacesDomainBoundaryFacesElement = createArrayBfdBfePolyhedraWithAllFacesEqual(model, tableNodesBoundaryFaces, tableNodalCoordinates, selectedComponentGeometryTag, numberOfBoundary);
    boundaryFacesElementLabels = strcat('bf_element_', string(1:size(arrayBoundaryFacesDomainBoundaryFacesElement, 1)))';
    BoundaryFacesDomainLabels = "bf_domain";
    tableBoundaryFacesDomainBoundaryFacesElement = array2table(arrayBoundaryFacesDomainBoundaryFacesElement, 'RowNames', boundaryFacesElementLabels, 'VariableNames', BoundaryFacesDomainLabels);
    assignin('base', 'tableBoundaryFacesDomainBoundaryFacesElement', tableBoundaryFacesDomainBoundaryFacesElement);
    tempo_esecuzione = toc;
    fprintf("Generazione completata in %f sec!\n", tempo_esecuzione);
    fprintf('\n');


end