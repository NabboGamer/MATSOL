addpath('./cli');
addpath('./incidence_matrices/polyhedra_types/polyhedra_with_all_faces_equal');
addpath('./incidence_matrices/polyhedra_types/polyhedra_with_different_faces');
addpath('./utility');

evalin('base', 'clear'), close all; clc;

%% Splash Screen CLI
printSplashScreen()

%% Check connessione
cprintf('Text', 'Please wait while the connection to the Comsol Server is checked... \n');
isConnected = checkConnection();
if isConnected
    cprintf('Text', 'Connection successfully established! \n');
    cprintf('Text', '======================================================================= \n');
else
    cprintf('Errors', 'Unable to connect to COMSOL Server, application will terminate! \n');
    cprintf('Text', '======================================================================= \n');
    return;
end

evalin('base', 'clear')
import com.comsol.model.*
import com.comsol.model.util.*
ModelUtil.clear();

%% Caricamento del modello
cprintf('Text', 'Please select a COMSOL model to load... \n');
model = modelPicker();
if model == -1
    return;
else
    cprintf('Text', 'Model loading completed successfully! \n');
    cprintf('Text', '======================================================================= \n');
end

%% Estrazione del componente di interesse
selectedComponent = componentPicker(model);
cprintf('Text', '\n');
cprintf('Text', 'Component successfully selected! \n');
cprintf('Text', '======================================================================= \n');

%% Estrazione della mesh e della geometria di interesse
[selectedMesh, selectedMeshTag] = meshPicker(model, selectedComponent);
cprintf('Text', '\n');
cprintf('Text', 'Mesh successfully selected! \n');
cprintf('Text', '======================================================================= \n');
selectedComponentGeometry = selectedComponent.geom;
selectedComponentGeometryTag = string(selectedComponentGeometry.tags());

%% Estrazione del numero di ordine degli elementi
cprintf('Text', 'Please wait while the mesh element order number is evaluated... \n');
elementsOrder = evaluateOrderNumber(model);
cprintf('Text', 'Evaluation completed! \n');

modelSolutionTags = string(model.sol.tags());
if elementsOrder > 1 && isempty(modelSolutionTags)
    cprintf('Text', '\n');
    cprintf('Errors', 'Non-existent solutions, compute a solution of the model (even with mock data) \n');
    cprintf('Text', '======================================================================= \n');
    return;
else
    cprintf('Text', '======================================================================= \n');
end

if elementsOrder == 2
    geometryTagList = string(model.geom.tags());
    geometryTagPos = find(strcmp(geometryTagList, selectedComponentGeometryTag));
end

%% Selezione del tipo di dato da estrarre/generare
cprintf('Text', 'Please select the data you want to extract/generate from the model: \n');
cprintf('Text', '\n');
cprintf('Text', '\t 1) Incidence Matrices \n');
cprintf('Text', '\n');

choice = validateInput(1);
cprintf('Text', '======================================================================= \n');

if choice == 1
    %% Creazione delle matrici di incidenza
    fields = {'arrayNodesFaces', 'arrayNodesBoundaryFaces', ...
             'arrayNodesSides', 'arrayFacesElements', 'arraySidesElements', ...
             'arraySidesFaces', 'arraySidesBoundaryFaces', 'arrayDomainsElements', ...
             'arrayBoundaryFacesDomainBoundaryFacesElement', 'arrayAll'};
    
    flagsStruct = struct();
    
    for i = 1:length(fields)
        internalStruct = struct('calculate', false, 'save', false);
        flagsStruct.(fields{i}) = internalStruct;
    end

    cprintf('Text', 'Please select which matrix you want to extract/generate: \n');
    cprintf('Text', '\n');
    cprintf('Text', '\t  1) NODES-FACES \n');
    cprintf('Text', '\t  2) NODES-BOUNDARY_FACES \n');
    cprintf('Text', '\t  3) NODES-SIDES \n');
    cprintf('Text', '\t  4) FACES-ELEMENTS \n');
    cprintf('Text', '\t  5) SIDES-ELEMENTS \n');
    cprintf('Text', '\t  6) SIDES-FACES \n');
    cprintf('Text', '\t  7) SIDES-BOUNDARY_FACES \n');
    cprintf('Text', '\t  8) DOMAINS-ELEMENTS \n');
    cprintf('Text', '\t  9) BOUNDARY_FACES_DOMAINS-BOUNDARY_FACES_ELEMENTS \n');
    cprintf('Text', '\t 10) ALL \n');
    cprintf('Text', '\n');
    whichCalculate = validateInput(10);
    cprintf('Text', '======================================================================= \n');

    cprintf('Text', 'Wants the matrix to be saved on disk too: \n');
    cprintf('Text', '\n');
    cprintf('Text', '\t  1) YES \n');
    cprintf('Text', '\t  2) NO \n');
    cprintf('Text', '\n');

    save = validateInput(2);
    cprintf('Text', '======================================================================= \n');
    
    switch whichCalculate
        case 1
            flagsStruct.arrayNodesFaces.calculate = true;
            if save == 1, flagsStruct.arrayNodesFaces.save = true; end
        case 2
            flagsStruct.arrayNodesBoundaryFaces.calculate = true;
            if save == 1, flagsStruct.arrayNodesBoundaryFaces.save = true; end
        case 3
            flagsStruct.arrayNodesSides.calculate = true;
            if save == 1, flagsStruct.arrayNodesSides.save = true; end
        case 4
            flagsStruct.arrayFacesElements.calculate = true;
            if save == 1, flagsStruct.arrayFacesElements.save = true; end
        case 5
            flagsStruct.arraySidesElements.calculate = true;
            if save == 1, flagsStruct.arraySidesElements.save = true; end
        case 6
            flagsStruct.arraySidesFaces.calculate = true;
            if save == 1, flagsStruct.arraySidesFaces.save = true; end
        case 7
            flagsStruct.arraySidesBoundaryFaces.calculate = true;
            if save == 1, flagsStruct.arraySidesBoundaryFaces.save = true; end
        case 8
            flagsStruct.arrayDomainsElements.calculate = true;
            if save == 1, flagsStruct.arrayDomainsElements.save = true; end
        case 9
            flagsStruct.arrayBoundaryFacesDomainBoundaryFacesElement.calculate = true;
            if save == 1, flagsStruct.arrayBoundaryFacesDomainBoundaryFacesElement.save = true; end
        otherwise
            flagsStruct.arrayAll.calculate = true;
            if save == 1, flagsStruct.arrayAll.save = true; end
    end

    if elementsOrder == 2
        meshdata = mphxmeshinfo(model);
        meshdataTypeList = string(meshdata.meshtypes);
        assignin('base', 'meshdataTypeList', meshdataTypeList);
    else
        [~,meshdata] = mphmeshstats(model, selectedMeshTag);
        meshdataTypeList = string(meshdata.types);
        assignin('base', 'meshdataTypeList', meshdataTypeList);
    end
    
    possibleMeshElementTypes = ["tet"; "pyr"; "prism"; "hex"];
    containedElementTypes = meshdataTypeList(ismember(meshdataTypeList, possibleMeshElementTypes));
    variablesToPreserve = ["meshdataTypeList", "model"];
    for i = 1 : size(containedElementTypes,1)
        searchedString = containedElementTypes(i,1);
        if strcmp(searchedString, "tet")
            incidenceMatricesTet = createIncidenceMatricesForCLI(model,...
                                                                 selectedComponentGeometryTag,...
                                                                 geometryTagPos,...
                                                                 meshdata,...
                                                                 meshdataTypeList,...
                                                                 searchedString,...
                                                                 elementsOrder,...
                                                                 flagsStruct,...
                                                                 '../saved_matrices/incidenceMatricesTet.json');
            variablesToPreserve = [variablesToPreserve, "incidenceMatricesTet"]; %#ok<AGROW>
        elseif strcmp(searchedString, "pyr")
            incidenceMatricesPyr = createIncidenceMatricesForCLI(model,...
                                                                 selectedComponentGeometryTag,...
                                                                 geometryTagPos,...
                                                                 meshdata,...
                                                                 meshdataTypeList,...
                                                                 searchedString,...
                                                                 elementsOrder,...
                                                                 flagsStruct,...
                                                                 '../saved_matrices/incidenceMatricesPyr.json');
            variablesToPreserve = [variablesToPreserve, "incidenceMatricesPyr"]; %#ok<AGROW>
        elseif strcmp(searchedString, "prism")
            incidenceMatricesPrism = createIncidenceMatricesForCLI(model,...
                                                                   selectedComponentGeometryTag,...
                                                                   geometryTagPos,...
                                                                   meshdata,...
                                                                   meshdataTypeList,...
                                                                   searchedString,...
                                                                   elementsOrder,...
                                                                   flagsStruct,...
                                                                   '../saved_matrices/incidenceMatricesPrism.json');
            variablesToPreserve = [variablesToPreserve, "incidenceMatricesPrism"]; %#ok<AGROW>
        elseif strcmp(searchedString, "hex")
            incidenceMatricesHex = createIncidenceMatricesForCLI(model,...
                                                                 selectedComponentGeometryTag,...
                                                                 geometryTagPos,...
                                                                 meshdata,...
                                                                 meshdataTypeList,...
                                                                 searchedString,...
                                                                 elementsOrder,...
                                                                 flagsStruct,...
                                                                 '../saved_matrices/incidenceMatricesHex.json');
            variablesToPreserve = [variablesToPreserve, "incidenceMatricesHex"]; %#ok<AGROW>
        end
    end
    
    cprintf('Text', '======================================================================= \n');
end

% Pulisco il workspace dalle variabili inutili
command = ['clearvars -except', sprintf(' %s', variablesToPreserve(:))];
eval(command);