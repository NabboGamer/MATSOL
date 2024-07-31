function out = incidence_matrices
    
    import com.comsol.model.*
    import com.comsol.model.util.*
    
    evalin('base', 'clear'), close all; clc;
    ModelUtil.clear();
    
    %% Connessione a COMSOL, caricamento del modello e assegnazione a una variabile del workspace base
    disp("Inizio il caricamento del modello...");
    model = mphload('C:\Users\stolf\dev\Progetto Modelli Numerici per Campi e Circuiti\MATSOL\model\component_library.mph');
    assignin('base', 'model', model);
    disp("Caricamento del modello terminato!");
    disp(newline)
    
    %% Estrazione del componente di interesse e assegnazione a una variabile del workspace base
    modelComponentList = model.component();
    modelComponentTagList = modelComponentList.tags();
    selectedComponentTag = modelComponentTagList(1);
    selectedComponent = model.component(selectedComponentTag);
    assignin('base', 'selectedComponent', selectedComponent);

    %% Estrazione della mesh di interesse, assegnazione a una variabile del workspace base e plotting
    selectedComponentMeshList = selectedComponent.mesh();
    selectedComponentMeshTagList = selectedComponentMeshList.tags();
    % disp(selectedComponentMeshTagList)
    selectedMeshTag = selectedComponentMeshTagList(2);
    selectedMesh = model.mesh(selectedMeshTag);
    assignin('base', 'selectedMesh', selectedMesh);

    figure('Name', 'Plot della Mesh', 'NumberTitle', 'off');
    mphmesh(model, selectedMeshTag);
    title_string = [string(selectedMeshTag), 'di', string(selectedComponentTag)];
    title_string = string(strjoin(title_string));
    title(title_string);
    xlabel('X', 'FontWeight', 'bold');
    ylabel('Y', 'FontWeight', 'bold');
    zlabel('Z', 'FontWeight', 'bold');

    %%
    [meshstats,meshdata] = mphmeshstats(model, selectedMeshTag);
    assignin('base', 'meshstats', meshstats);
    assignin('base', 'meshdata', meshdata);

out = model;