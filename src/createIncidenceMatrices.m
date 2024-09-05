function createIncidenceMatrices
    %CREATEINCIDENCEMATRICES si occupa di calcolare le matrici di incidenza per la mesh specificata del modello specificato
    
    import com.comsol.model.*
    import com.comsol.model.util.*

    addpath('./mesh_element_type/polyhedra_with_all_faces_equal');
    addpath('./mesh_element_type/polyhedra_with_different_faces');
    addpath('./utility');
    
    evalin('base', 'clear'), close all; clc;
    ModelUtil.clear();
    
    %% Connessione a COMSOL, caricamento del modello e assegnazione a una variabile nel workspace base
    disp("Inizio il caricamento del modello...");

    oldWarnState = warning('query', 'all');
    warning('off', 'all');
    lastwarn('');
    model = mphload('C:\Users\stolf\dev\Progetto Modelli Numerici per Campi e Circuiti\MATSOL\model\component_library_RF.mph');
    [msg, ~] = lastwarn;
    if ~isempty(msg)
        cprintf('SystemCommands', '***WARNING: %s\n', msg);
        lastwarn('');
    end
    warning(oldWarnState);
    
    assignin('base', 'model', model);
    disp("Caricamento del modello terminato!");
    disp(newline)
    
    %% Estrazione del componente di interesse e assegnazione a una variabile nel workspace base
    modelComponentList = model.component();

    modelComponentTagList = string(modelComponentList.tags);
    labelNameArray = strings(size(modelComponentTagList, 1), 2);
    for i = 1:size(modelComponentTagList, 1)
        labelNameArray(i,1) = model.component(modelComponentTagList(i)).label();
    end
    labelNameArray(:,2) = modelComponentTagList(:);   
    searchedString = 'componentCube2';
    modelComponentTagPos = strcmp(labelNameArray(:, 1), searchedString);
    if ~any(modelComponentTagPos)
        cprintf('Errors','***ERROR: non esiste nessun componente con questa LABEL, assicurati che la label coincida e che tu non abbia inserito per errore il NAME del componente \n');
        return;
    end

    selectedComponentTag = modelComponentTagList(modelComponentTagPos);
    selectedComponent = model.component(selectedComponentTag);
    % assignin('base', 'selectedComponent', selectedComponent);

    %% Estrazione della mesh e della geometria di interesse, assegnazione a una variabile nel workspace base e plotting
    selectedComponentMeshList = selectedComponent.mesh();

    selectedComponentMeshTagList = string(selectedComponentMeshList.tags);
    labelTagArray = strings(size(selectedComponentMeshTagList, 1), 2);
    for i = 1:size(selectedComponentMeshTagList, 1)
        labelTagArray(i,1) = model.mesh(selectedComponentMeshTagList(i)).label();
    end
    labelTagArray(:,2) = selectedComponentMeshTagList(:);
    searchedString = 'meshPyr';
    selectedMeshTagPos = strcmp(labelTagArray(:, 1), searchedString);
    if ~any(selectedMeshTagPos)
        cprintf('Errors', '***ERROR: non esiste nessuna mesh con questa LABEL, assicurati che la label coincida e che tu non abbia inserito per errore il TAG della mesh \n');
        return;
    end

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

    selectedComponentGeometry = selectedComponent.geom;
    selectedComponentGeometryTag = string(selectedComponentGeometry.tags());

    figure('Name', 'Plot della Geometry', 'NumberTitle', 'off');
    mphgeom(model, selectedComponentGeometryTag);
    title_string = [string(selectedComponentGeometryTag), 'di', string(selectedComponentTag)];
    title_string = string(strjoin(title_string));
    title(title_string);
    xlabel('X', 'FontWeight', 'bold');
    ylabel('Y', 'FontWeight', 'bold');
    zlabel('Z', 'FontWeight', 'bold');

    %% Estrazione del numero di ordine degli elementi
    modelShapeFunctionsTags = string(model.shape.tags());
    if isempty(modelShapeFunctionsTags)
        cprintf('Errors', '***ERROR: funzioni di forma inesistenti, assegna una fisica al componente \n');
        return;
    end
    modelShapeFunctionsFirstTag = modelShapeFunctionsTags(1);
    shapeFeatureList = model.shape(modelShapeFunctionsFirstTag).feature();
    firstFeatureString = string(shapeFeatureList(1).toString());
    firstFeatureTag = extractAfter(firstFeatureString, 'Child nodes: ');
    firstFeature = model.shape(modelShapeFunctionsFirstTag).feature(firstFeatureTag);

    elementsOrder = firstFeature.getInt('order');

    modelSolutionTags = string(model.sol.tags());
    if elementsOrder > 1 && isempty(modelSolutionTags)
        cprintf('Errors', '***ERROR: soluzioni inesistenti, calcola una soluzione del modello(anche con dati mock) \n');
        return;
    end

    if elementsOrder == 2
        % La posizione del tag della geometria di interesse serve perchè
        % coincide con la posizione nella quale trovare le informazioni estese
        % della mesh nel caso in cui il modello abbia più componenti e quindi
        % più geometrie.
        geometryTagList = string(model.geom.tags());
        geometryTagPos = find(strcmp(geometryTagList, selectedComponentGeometryTag));
    end

    %% Creazione delle matrici di incidenza
    if elementsOrder == 2
        % Le informazioni estese sulla mesh servono nel caso in cui si
        % abbiano elementi di ordine superiore al primo, poichè è l'unico
        % modo con cui è possibile ottenere anche i nodi intermedi che
        % compongono la mesh.
        cprintf('Comments', '***DEBUG: Mesh con elementi del SECONDO ordine \n');
        extendedMeshInfo = mphxmeshinfo(model);
        assignin('base', 'extendedMeshInfo', extendedMeshInfo);
        meshdataTypeList = string(extendedMeshInfo.meshtypes);
        assignin('base', 'meshdataTypesList', meshdataTypeList);
    else
        cprintf('Comments', '***DEBUG: Mesh con elementi del PRIMO ordine \n');
        [meshstats,meshdata] = mphmeshstats(model, selectedMeshTag);
        assignin('base', 'meshstats', meshstats);
        assignin('base', 'meshdata', meshdata);
        meshdataTypeList = string(meshdata.types);
        assignin('base', 'meshdataTypesList', meshdataTypeList);
    end


    % MATRICE COORDINATE NODALI
    fprintf("Inizio generazione matrice delle COORDINATE NODALI...\n");
    tic;
    if elementsOrder == 2
        nodes = double(extendedMeshInfo.nodes(geometryTagPos).coords);
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
    assignin('base', 'tableNodalCoordinates', tableNodalCoordinates);
    tempo_esecuzione = toc;
    fprintf("Generazione completata in %f sec!\n", tempo_esecuzione);
    fprintf('\n');

    % MATRICE NODI-ELEMENTI
    fprintf("Inizio generazione matrice di incidenza NODI-ELEMENTI...\n");
    tic;
    searchedString = 'pyr';
    meshdataTypePos = strcmp(meshdataTypeList, searchedString);
    %N.B.: Come da documentazione gli elementi sono indicizzati da 0 quindi
    %      bisogna aggiungere 1
    if elementsOrder == 2
        if strcmp(searchedString, 'tet')
            elements = double(extendedMeshInfo.elements(geometryTagPos).tet.nodes+1);
        elseif strcmp(searchedString, 'pyr') 
            elements = double(extendedMeshInfo.elements(geometryTagPos).pyr.nodes+1);
        elseif strcmp(searchedString, 'prism')
            elements = double(extendedMeshInfo.elements(geometryTagPos).prism.nodes+1);
        elseif strcmp(searchedString, 'hex')
            elements = double(extendedMeshInfo.elements(geometryTagPos).hex.nodes+1);
        end
    else
        elements = double(meshdata.elem{meshdataTypePos}+1);
    end
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
    [arrayNodesFaces, arrayNodesBoundaryFaces] = createArrayNodesFacesPolyhedraWithDifferentFaces(tableNodesElements, searchedString, elementsOrder);
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
    arrayNodesSides = createArrayNodesSidesPolyhedraWithDifferentFaces(tableNodesFaces, elementsOrder);
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
    arrayFacesElements = createArrayFacesElementsPolyhedraWithDifferentFaces(tableNodesElements, tableNodesFaces, elementsOrder);
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
    arraySidesElements = createArraySidesElementsPolyhedraWithDifferentFaces(tableNodesElements, tableNodesSides, searchedString, elementsOrder);
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
    arraySidesFaces = createArraySidesFacesPolyhedraWithDifferentFaces(tableNodesFaces, tableNodesSides, elementsOrder);
    faceLabels = strcat('f_', string(1:size(arraySidesFaces, 1)))';
    sideLabels = strcat('s_', string(1:size(arraySidesFaces, 2)));
    tableSidesFaces = array2table(arraySidesFaces, 'RowNames', faceLabels, 'VariableNames', sideLabels);
    assignin('base', 'tableSidesFaces', tableSidesFaces);

    arraySidesBoundaryFaces = createArraySidesFacesPolyhedraWithDifferentFaces(tableNodesBoundaryFaces, tableNodesSides, elementsOrder);
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
    if elementsOrder == 2
        cprintf('Keywords', '***INFO: Purtroppo al momento il livelink non fornisce informazioni relative al dominio di appartenenza per elementi del secondo ordine, quindi questa matrice non può essere generata \n');
        tempo_esecuzione = toc;
        fprintf("Generazione interrotta dopo %f sec!\n", tempo_esecuzione);
        fprintf('\n');
    else
        arrayDomainsElements = meshdata.elementity{meshdataTypePos};
        faceLabels = strcat('e_', string(1:size(arrayDomainsElements, 1)))';
        domainLabels = "domain";
        tableDomainsElements = array2table(arrayDomainsElements, 'RowNames', faceLabels, 'VariableNames', domainLabels);
        assignin('base', 'tableDomainsElements', tableDomainsElements);
        tempo_esecuzione = toc;
        fprintf("Generazione completata in %f sec!\n", tempo_esecuzione);
        fprintf('\n');
    end

    % MATRICE FACCE_FRONTIERA_DOMINIO-FACCE_FRONTIERA_ELEMENTO
    fprintf("Inizio generazione matrice di incidenza FACCE_FRONTIERA_DOMINIO-FACCE_FRONTIERA_ELEMENTO...\n");
    tic;
    numberOfBoundary = model.geom(selectedComponentGeometryTag).getNBoundaries();
    arrayBoundaryFacesDomainBoundaryFacesElement = createArrayBfdBfePolyhedraWithDifferentFaces(model, tableNodesBoundaryFaces, tableNodalCoordinates, selectedComponentGeometryTag, numberOfBoundary, elementsOrder);
    boundaryFacesElementLabels = strcat('bf_element_', string(1:size(arrayBoundaryFacesDomainBoundaryFacesElement, 1)))';
    BoundaryFacesDomainLabels = "bf_domain";
    tableBoundaryFacesDomainBoundaryFacesElement = array2table(arrayBoundaryFacesDomainBoundaryFacesElement, 'RowNames', boundaryFacesElementLabels, 'VariableNames', BoundaryFacesDomainLabels);
    assignin('base', 'tableBoundaryFacesDomainBoundaryFacesElement', tableBoundaryFacesDomainBoundaryFacesElement);
    tempo_esecuzione = toc;
    fprintf("Generazione completata in %f sec!\n", tempo_esecuzione);
    fprintf('\n');

end