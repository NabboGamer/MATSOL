function out = incidence_matrices
    
    import com.comsol.model.*
    import com.comsol.model.util.*
    
    clc;evalin('base', 'clear');
    ModelUtil.clear();
    
    % Connessione a COMSOL e caricamento del modello
    
    disp("Inizio il caricamento del modello...");
    model = mphload('C:\Users\stolf\dev\Progetto Modelli Numerici per Campi e Circuiti\MATSOL\model\component_library.mph');
    assignin('base', 'model', model);
    disp("Caricamento terminato!");
    disp(newline)
    
    modelComponentList = model.component;
    modelComponentTagList = modelComponentList.tags();
    selectedComponentTag = modelComponentTagList(1);
    selectedComponent = model.component(selectedComponentTag);
    assignin('base', 'selectedComponent', selectedComponent);

    selectedComponentMeshList = selectedComponent.mesh;
    selectedComponentMeshTagList = selectedComponentMeshList.tags;
    selectedMeshTag = selectedComponentMeshTagList(1);
    selectedMesh = model.mesh(selectedMeshTag);
    assignin('base', 'selectedMesh', selectedMesh);

out = model;