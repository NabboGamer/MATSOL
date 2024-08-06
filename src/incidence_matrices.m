function out = incidence_matrices
    % Questa function si occupa di calcolare le matrici di incidenza della
    % mesh specificata del modello specificato
    
    import com.comsol.model.*
    import com.comsol.model.util.*
    
    evalin('base', 'clear'), close all; clc;
    ModelUtil.clear();
    
    %% Connessione a COMSOL, caricamento del modello e assegnazione a una variabile nel workspace base
    disp("Inizio il caricamento del modello...");
    model = mphload('C:\Users\stolf\dev\Progetto Modelli Numerici per Campi e Circuiti\MATSOL\model\component_library.mph');
    assignin('base', 'model', model);
    disp("Caricamento del modello terminato!");
    disp(newline)
    
    %% Estrazione del componente di interesse e assegnazione a una variabile nel workspace base
    modelComponentList = model.component();

    modelComponentTagList = string(modelComponentList.tags);
    searchedString = 'componentCube';
    modelComponentTagPos = find(strcmp(modelComponentTagList, searchedString));

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
    searchedString = 'mesh4elemPerFaceStructuredQuadrilateral';
    selectedMeshTagPos = find(strcmp(labelTagArray(:, 1), searchedString));

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
    nodes = meshdata.vertex;
    % Trasposizione della matrice degli elementi
    transposedMatrixNodes = nodes';
    % Creazione delle etichette per righe e colonne della tabella
    nodeLabels = strcat('n_', string(1:size(transposedMatrixNodes, 1)))';
    coordinateLabels = ["x", "y", "z"];
    % Creazione della tabella degli elementi
    tableNodalCoordinates = array2table(transposedMatrixNodes, 'RowNames', nodeLabels, 'VariableNames', coordinateLabels);
    assignin('base', 'tableNodalCoordinates', tableNodalCoordinates);
    
    % MATRICE NODI-ELEMENTI
    searchedString = 'hex';
    meshdataTypeHexPos = find(strcmp(meshdataTypeList, searchedString));
    %N.B.: Come da documentazione gli elementi sono indicizzati da 0 quindi
    %      bisogna aggiungere 1
    elementsHex = double(meshdata.elem{meshdataTypeHexPos}+1);
    transposedMatrixElements = elementsHex';
    elementLabels = strcat('e_', string(1:size(transposedMatrixElements, 1)))';
    nodeLabels = strcat('n_', string(1:size(transposedMatrixElements, 2)));
    tableNodesElements = array2table(transposedMatrixElements, 'RowNames', elementLabels, 'VariableNames', nodeLabels);
    assignin('base', 'tableNodesElements', tableNodesElements);

    % MATRICE NODI-FACCE
    arrayNodesFaces = createArrayNodesFaces(tableNodesElements);

    faceLabels = strcat('f_', string(1:size(arrayNodesFaces, 1)))';
    nodeLabels = strcat('n_', string(1:size(arrayNodesFaces, 2)));
    tableNodesFaces = array2table(arrayNodesFaces, 'RowNames', faceLabels, 'VariableNames', nodeLabels);
    assignin('base', 'tableNodesFaces', tableNodesFaces);
    
    % MATRICE NODI-LATI
    arrayNodesSides = createArrayNodesSides(tableNodesFaces);

    sideLabels = strcat('s_', string(1:size(arrayNodesSides, 1)))';
    nodeLabels = strcat('n_', string(1:size(arrayNodesSides, 2)));
    tableNodesSides = array2table(arrayNodesSides, 'RowNames', sideLabels, 'VariableNames', nodeLabels);
    assignin('base', 'tableNodesSides', tableNodesSides);

    % MATRICE FACCE-ELEMENTI
    arrayFacesElements = createArrayFacesElements(tableNodesElements, tableNodesFaces);

    elementLabels = strcat('e_', string(1:size(arrayFacesElements, 1)))';
    faceLabels = strcat('f_', string(1:size(arrayFacesElements, 2)));
    tableFacesElements = array2table(arrayFacesElements, 'RowNames', elementLabels, 'VariableNames', faceLabels);
    assignin('base', 'tableFacesElements', tableFacesElements);

out = model;