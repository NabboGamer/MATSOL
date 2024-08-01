function out = incidence_matrices
    
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
    
    % Per le Mesh dalla GUI di COMSOL il tag non è personalizzabile come per
    % i Component, quindi label e tag non corrispondono.
    selectedComponentMeshTagList = string(selectedComponentMeshList.tags);
    labelTagArray = strings(size(selectedComponentMeshTagList, 1), 2);
    for i = 1:size(selectedComponentMeshTagList, 1)
        labelTagArray(i,1) = model.mesh(selectedComponentMeshTagList(i)).label();
    end
    labelTagArray(:,2) = selectedComponentMeshTagList(:);
    searchedString = 'mesh9elemPerFaceStructuredQuadrilateral';
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

    %% Estrazione della matrice dei nodi e della matrice degli elementi dalla mesh, e assegnazione di quest'ultime a due diverse strutture dati nel workspace base
    [meshstats,meshdata] = mphmeshstats(model, selectedMeshTag);
    assignin('base', 'meshstats', meshstats);
    assignin('base', 'meshdata', meshdata);

    meshdataTypeList = string(meshdata.types);
    searchedString = 'hex';
    meshdataTypeHexPos = find(strcmp(meshdataTypeList, searchedString));

    nodes = meshdata.vertex;
    %N.B.: Come da documentazione gli elementi sono indicizzati da 0 quindi
    %      bisogna aggiungere 1
    elements = double(meshdata.elem{meshdataTypeHexPos}+1);
    assignin('base', 'nodes', nodes);
    assignin('base', 'elements', elements);

    %% Creazione della matrice di incidenza

out = model;