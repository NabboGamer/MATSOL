addpath('./cli');
addpath('./incidence_matrices/polyhedra_types/polyhedra_with_all_faces_equal');
addpath('./incidence_matrices/polyhedra_types/polyhedra_with_different_faces');
addpath('./jacobian');
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
    evalin('base', 'clear');
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
    evalin('base', 'clear');
    return;
else
    cprintf('Text', 'Model loading completed successfully! \n');
    cprintf('Text', '======================================================================= \n');
end

%% Estrazione del componente di interesse
selectedComponent = componentPicker(model);
if selectedComponent == -1
    cprintf('Text', '\n');
    cprintf('Errors', 'The model does not yet have any components, application will terminate! \n');
    cprintf('Text', '======================================================================= \n');
    evalin('base', 'clear');
    return;
else
    cprintf('Text', '\n');
    cprintf('Text', 'Component successfully selected! \n');
    cprintf('Text', '======================================================================= \n');
end

%% Estrazione della mesh e della geometria di interesse
[selectedMesh, selectedMeshTag] = meshPicker(model, selectedComponent);
if selectedMesh == -1
    cprintf('Text', '\n');
    cprintf('Errors', 'The component does not yet have any mesh, application will terminate! \n');
    cprintf('Text', '======================================================================= \n');
    evalin('base', 'clear');
    return;
else
    cprintf('Text', '\n');
    cprintf('Text', 'Mesh successfully selected! \n');
    cprintf('Text', '======================================================================= \n');
end
selectedComponentGeometry = selectedComponent.geom;
selectedComponentGeometryTag = string(selectedComponentGeometry.tags());

%% Estrazione dello studio di interesse
[selectedStudy, selectedStudyTag] = studyPicker(model);
if selectedStudy == -1
    cprintf('Errors', 'Non-existent studies, assign a study to the model! \n');
    cprintf('Text', '======================================================================= \n');
    evalin('base', 'clear');
    return;
else
    cprintf('Text', '\n');
    cprintf('Text', 'Study successfully selected! \n');
    cprintf('Text', '======================================================================= \n');
end

%% Estrazione dello step di interesse
[selectedStep, selectedStepTag] = stepPicker(selectedStudy);
if selectedStep == -1
    cprintf('Errors', 'Non-existent step, assign a step to the study! \n');
    cprintf('Text', '======================================================================= \n');
    evalin('base', 'clear');
    return;
else
    cprintf('Text', '\n');
    cprintf('Text', 'Step successfully selected! \n');
    cprintf('Text', '======================================================================= \n');
end

meshCalculatedSolution = string(selectedStep.getStringArray('mesh'));
positionSelectedMeshTag = find(strcmp(meshCalculatedSolution, selectedComponentGeometryTag));
nextPosition = positionSelectedMeshTag + 1;
result1 = strcmp(meshCalculatedSolution(nextPosition), "nomesh");
if result1
    cprintf('Errors', 'For the selected component, in the selected step you \n');
    cprintf('Errors', 'have not inserted any mesh! \n');
    cprintf('Text', '======================================================================= \n');
    evalin('base', 'clear');
    return;
end
result2 = strcmp(meshCalculatedSolution(nextPosition), selectedMeshTag);
if ~result2
    cprintf('Errors', 'For the selected component, in the selected step you have assigned \n');
    cprintf('Errors', 'a different mesh from the one inserted previously \n');
    cprintf('Text', '======================================================================= \n');
    evalin('base', 'clear');
    return;
end

%% Estrazione del numero di ordine degli elementi
cprintf('Text', 'Please wait while the mesh element order number is evaluated... \n');
elementsOrder = evaluateOrderNumber(model);
if elementsOrder == -1
    cprintf('Errors', 'Non-existent shape functions, assign a physics to the component! \n');
    cprintf('Text', '======================================================================= \n');
    evalin('base', 'clear');
    return;
end

modelSolutionTags = string(model.sol.tags());
if elementsOrder > 1 && isempty(modelSolutionTags)
    cprintf('Text', '\n');
    cprintf('Errors', 'Non-existent solutions, compute a solution of the model (even with mock data) \n');
    cprintf('Text', '======================================================================= \n');
    evalin('base', 'clear');
    return;
end

for i = 1 : size(modelSolutionTags, 1)
    solutionTag = modelSolutionTags(i, 1);
    if (model.sol(solutionTag).isActive() &&...
       ~strcmp(string(model.sol(solutionTag).study()), selectedStudyTag))
        cprintf('Text', '\n');
        cprintf('Errors', 'The current active solution is attached to a different \n');
        cprintf('Errors', 'study than the one selected \n');
        cprintf('Text', '======================================================================= \n');
        evalin('base', 'clear');
        return;
    end
end

cprintf('Text', 'Evaluation completed! \n');
cprintf('Text', '======================================================================= \n');

if elementsOrder == 2
    geometryTagList = string(model.geom.tags());
    geometryTagPos = find(strcmp(geometryTagList, selectedComponentGeometryTag));
end

%% Selezione del tipo di dato da estrarre/generare
cprintf('Text', 'Please select the data you want to extract/generate from the model: \n');
cprintf('Text', '\n');
cprintf('Text', '\t 1) Incidence Matrices \n');
cprintf('Text', '\t 2) Shape Functions \n');
cprintf('Text', '\t 3) Jacobian Matrices \n');
cprintf('Text', '\t 4) Transformation Matrices \n');
cprintf('Text', '\n');

choice = validateInput(4);
cprintf('Text', '======================================================================= \n');

fields = {'arrayNodesFaces', 'arrayNodesBoundaryFaces', ...
          'arrayNodesSides', 'arrayFacesElements', 'arraySidesElements', ...
          'arraySidesFaces', 'arraySidesBoundaryFaces', 'arrayDomainsElements', ...
          'arrayBoundaryFacesDomainBoundaryFacesElement', 'arrayAll'};

flagsStruct = struct();
for i = 1:length(fields)
    internalStruct = struct('calculate', false, 'save', false);
    flagsStruct.(fields{i}) = internalStruct;
end

if choice == 1
    %% Creazione delle matrici di incidenza

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
                                                                 '../saved_matrices/incidenceMatricesTet.json',...
                                                                 true);
            if isempty(fieldnames(incidenceMatricesTet))
                cprintf('Errors', 'Sorry something went wrong, application will terminate! Are you sure \n');
                cprintf('Errors', 'you calculated the solution for the previously selected mesh as well? \n');
                cprintf('Text', '======================================================================= \n');
                evalin('base', 'clear');
                return;
            end
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
                                                                 '../saved_matrices/incidenceMatricesPyr.json',...
                                                                 false);
            if isempty(fieldnames(incidenceMatricesPyr))
                cprintf('Errors', 'Sorry something went wrong, application will terminate! Are you sure \n');
                cprintf('Errors', 'you calculated the solution for the previously selected mesh as well? \n');
                cprintf('Text', '======================================================================= \n');
                evalin('base', 'clear');
                return;
            end
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
                                                                   '../saved_matrices/incidenceMatricesPrism.json',...
                                                                   false);
            if isempty(fieldnames(incidenceMatricesPrism))
                cprintf('Errors', 'Sorry something went wrong, application will terminate! Are you sure \n');
                cprintf('Errors', 'you calculated the solution for the previously selected mesh as well? \n');
                cprintf('Text', '======================================================================= \n');
                evalin('base', 'clear');
                return;
            end
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
                                                                 '../saved_matrices/incidenceMatricesHex.json',...
                                                                 true);
            if isempty(fieldnames(incidenceMatricesHex))
                cprintf('Errors', 'Sorry something went wrong, application will terminate! Are you sure \n');
                cprintf('Errors', 'you calculated the solution for the previously selected mesh as well? \n');
                cprintf('Text', '======================================================================= \n');
                evalin('base', 'clear');
                return;
            end
            variablesToPreserve = [variablesToPreserve, "incidenceMatricesHex"]; %#ok<AGROW>
        end
    end
    
elseif choice == 2
    %% Generazione Shape Functions
    cprintf('Text', 'Please wait while the Shape Functions are generated...  \n');
    cprintf('Text', '\n');
    cprintf('Keywords', 'Note, to generate the Shape Functions is necessary \n');
    cprintf('Keywords', 'to generate some incidence matrices... \n');
    cprintf('Text', '======================================================================= \n');
    flagsStruct.arrayNodesFaces.calculate = true;
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
                                                                 '../saved_matrices/incidenceMatricesTet.json',...
                                                                 true);
            if isempty(fieldnames(incidenceMatricesTet))
                cprintf('Errors', 'Sorry something went wrong, application will terminate! Are you sure \n');
                cprintf('Errors', 'you calculated the solution for the previously selected mesh as well? \n');
                cprintf('Text', '======================================================================= \n');
                evalin('base', 'clear');
                return;
            end
            tableShapeFunctionsTet = createShapeFunctions(incidenceMatricesTet, searchedString, elementsOrder);
            variablesToPreserve = [variablesToPreserve, "tableShapeFunctionsTet"]; %#ok<AGROW>
        elseif strcmp(searchedString, "pyr")
            incidenceMatricesPyr = createIncidenceMatricesForCLI(model,...
                                                                 selectedComponentGeometryTag,...
                                                                 geometryTagPos,...
                                                                 meshdata,...
                                                                 meshdataTypeList,...
                                                                 searchedString,...
                                                                 elementsOrder,...
                                                                 flagsStruct,...
                                                                 '../saved_matrices/incidenceMatricesPyr.json',...
                                                                 false);
            if isempty(fieldnames(incidenceMatricesPyr))
                cprintf('Errors', 'Sorry something went wrong, application will terminate! Are you sure \n');
                cprintf('Errors', 'you calculated the solution for the previously selected mesh as well? \n');
                cprintf('Text', '======================================================================= \n');
                evalin('base', 'clear');
                return;
            end
            tableShapeFunctionsPyr = createShapeFunctions(incidenceMatricesPyr, searchedString, elementsOrder);
            variablesToPreserve = [variablesToPreserve, "tableShapeFunctionsPyr"]; %#ok<AGROW>
        elseif strcmp(searchedString, "prism")
            incidenceMatricesPrism = createIncidenceMatricesForCLI(model,...
                                                                   selectedComponentGeometryTag,...
                                                                   geometryTagPos,...
                                                                   meshdata,...
                                                                   meshdataTypeList,...
                                                                   searchedString,...
                                                                   elementsOrder,...
                                                                   flagsStruct,...
                                                                   '../saved_matrices/incidenceMatricesPrism.json',...
                                                                   false);
            if isempty(fieldnames(incidenceMatricesPrism))
                cprintf('Errors', 'Sorry something went wrong, application will terminate! Are you sure \n');
                cprintf('Errors', 'you calculated the solution for the previously selected mesh as well? \n');
                cprintf('Text', '======================================================================= \n');
                evalin('base', 'clear');
                return;
            end
            tableShapeFunctionsPrism = createShapeFunctions(incidenceMatricesPrism, searchedString, elementsOrder);
            variablesToPreserve = [variablesToPreserve, "tableShapeFunctionsPrism"]; %#ok<AGROW>
        elseif strcmp(searchedString, "hex")
            incidenceMatricesHex = createIncidenceMatricesForCLI(model,...
                                                                 selectedComponentGeometryTag,...
                                                                 geometryTagPos,...
                                                                 meshdata,...
                                                                 meshdataTypeList,...
                                                                 searchedString,...
                                                                 elementsOrder,...
                                                                 flagsStruct,...
                                                                 '../saved_matrices/incidenceMatricesHex.json',...
                                                                 true);
            if isempty(fieldnames(incidenceMatricesHex))
                cprintf('Errors', 'Sorry something went wrong, application will terminate! Are you sure \n');
                cprintf('Errors', 'you calculated the solution for the previously selected mesh as well? \n');
                cprintf('Text', '======================================================================= \n');
                evalin('base', 'clear');
                return;
            end
            tableShapeFunctionsHex = createShapeFunctions(incidenceMatricesHex, searchedString, elementsOrder);
            variablesToPreserve = [variablesToPreserve, "tableShapeFunctionsHex"]; %#ok<AGROW>
        end
    end
    cprintf('Text', '\n');
    cprintf('Text', 'Generation completed!  \n');
    cprintf('Text', '======================================================================= \n');
    
elseif choice == 3
    %% Generazione Matrici Jacobiane
    cprintf('Text', 'Please wait while the Jacobian Matrices are generated...  \n');
    cprintf('Text', '\n');
    cprintf('Keywords', 'Note, to generate the Jacobian Matrices is\n');
    cprintf('Keywords', 'necessary to generate some incidence matrices... \n');
    cprintf('Text', '======================================================================= \n');
    flagsStruct.arrayNodesFaces.calculate = true;
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
                                                                 '../saved_matrices/incidenceMatricesTet.json',...
                                                                 true);
            if isempty(fieldnames(incidenceMatricesTet))
                cprintf('Errors', 'Sorry something went wrong, application will terminate! Are you sure \n');
                cprintf('Errors', 'you calculated the solution for the previously selected mesh as well? \n');
                cprintf('Text', '======================================================================= \n');
                evalin('base', 'clear');
                return;
            end
            tableShapeFunctionsTet = createShapeFunctions(incidenceMatricesTet, searchedString, elementsOrder);
            tableJacobianMatricesTet = createJacobianMatrices(incidenceMatricesTet, tableShapeFunctionsTet);
            variablesToPreserve = [variablesToPreserve, "tableJacobianMatricesTet"]; %#ok<AGROW>
        elseif strcmp(searchedString, "pyr")
            incidenceMatricesPyr = createIncidenceMatricesForCLI(model,...
                                                                 selectedComponentGeometryTag,...
                                                                 geometryTagPos,...
                                                                 meshdata,...
                                                                 meshdataTypeList,...
                                                                 searchedString,...
                                                                 elementsOrder,...
                                                                 flagsStruct,...
                                                                 '../saved_matrices/incidenceMatricesPyr.json',...
                                                                 false);
            if isempty(fieldnames(incidenceMatricesPyr))
                cprintf('Errors', 'Sorry something went wrong, application will terminate! Are you sure \n');
                cprintf('Errors', 'you calculated the solution for the previously selected mesh as well? \n');
                cprintf('Text', '======================================================================= \n');
                evalin('base', 'clear');
                return;
            end
            tableShapeFunctionsPyr = createShapeFunctions(incidenceMatricesPyr, searchedString, elementsOrder);
            tableJacobianMatricesPyr = createJacobianMatrices(incidenceMatricesPyr, tableShapeFunctionsPyr);
            variablesToPreserve = [variablesToPreserve, "tableJacobianMatricesPyr"]; %#ok<AGROW>
        elseif strcmp(searchedString, "prism")
            incidenceMatricesPrism = createIncidenceMatricesForCLI(model,...
                                                                   selectedComponentGeometryTag,...
                                                                   geometryTagPos,...
                                                                   meshdata,...
                                                                   meshdataTypeList,...
                                                                   searchedString,...
                                                                   elementsOrder,...
                                                                   flagsStruct,...
                                                                   '../saved_matrices/incidenceMatricesPrism.json',...
                                                                   false);
            if isempty(fieldnames(incidenceMatricesPrism))
                cprintf('Errors', 'Sorry something went wrong, application will terminate! Are you sure \n');
                cprintf('Errors', 'you calculated the solution for the previously selected mesh as well? \n');
                cprintf('Text', '======================================================================= \n');
                evalin('base', 'clear');
                return;
            end
            tableShapeFunctionsPrism = createShapeFunctions(incidenceMatricesPrism, searchedString, elementsOrder);
            tableJacobianMatricesPrism = createJacobianMatrices(incidenceMatricesPrism, tableShapeFunctionsPrism);
            variablesToPreserve = [variablesToPreserve, "tableJacobianMatricesPrism"]; %#ok<AGROW>
        elseif strcmp(searchedString, "hex")
            incidenceMatricesHex = createIncidenceMatricesForCLI(model,...
                                                                 selectedComponentGeometryTag,...
                                                                 geometryTagPos,...
                                                                 meshdata,...
                                                                 meshdataTypeList,...
                                                                 searchedString,...
                                                                 elementsOrder,...
                                                                 flagsStruct,...
                                                                 '../saved_matrices/incidenceMatricesHex.json',...
                                                                 true);
            if isempty(fieldnames(incidenceMatricesHex))
                cprintf('Errors', 'Sorry something went wrong, application will terminate! Are you sure \n');
                cprintf('Errors', 'you calculated the solution for the previously selected mesh as well? \n');
                cprintf('Text', '======================================================================= \n');
                evalin('base', 'clear');
                return;
            end
            tableShapeFunctionsHex = createShapeFunctions(incidenceMatricesHex, searchedString, elementsOrder);
            tableJacobianMatricesHex = createJacobianMatrices(incidenceMatricesHex, tableShapeFunctionsHex);
            variablesToPreserve = [variablesToPreserve, "tableJacobianMatricesHex"]; %#ok<AGROW>
        end
    end
    cprintf('Text', '\n');
    cprintf('Text', 'Generation completed!  \n');
    cprintf('Text', '======================================================================= \n');
    
elseif choice == 4
    %% Generazione Matrici di Trasformazione
    cprintf('Text', 'Please wait while the Transformation Matrices are generated...  \n');
    cprintf('Text', '\n');
    cprintf('Keywords', 'Note, to generate the Transformation Matrices is\n');
    cprintf('Keywords', 'necessary to generate some incidence matrices... \n');
    cprintf('Text', '======================================================================= \n');
    flagsStruct.arrayNodesFaces.calculate = true;
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
                                                                 '../saved_matrices/incidenceMatricesTet.json',...
                                                                 true);
            if isempty(fieldnames(incidenceMatricesTet))
                cprintf('Errors', 'Sorry something went wrong, application will terminate! Are you sure \n');
                cprintf('Errors', 'you calculated the solution for the previously selected mesh as well? \n');
                cprintf('Text', '======================================================================= \n');
                evalin('base', 'clear');
                return;
            end
            tableShapeFunctionsTet = createShapeFunctions(incidenceMatricesTet, searchedString, elementsOrder);
            tableJacobianMatricesTet = createJacobianMatrices(incidenceMatricesTet, tableShapeFunctionsTet);
            tableTransformationMatricesTet = createTransformationMatrices(incidenceMatricesTet, tableJacobianMatricesTet);
            variablesToPreserve = [variablesToPreserve, "tableTransformationMatricesTet"]; %#ok<AGROW>
        elseif strcmp(searchedString, "pyr")
            incidenceMatricesPyr = createIncidenceMatricesForCLI(model,...
                                                                 selectedComponentGeometryTag,...
                                                                 geometryTagPos,...
                                                                 meshdata,...
                                                                 meshdataTypeList,...
                                                                 searchedString,...
                                                                 elementsOrder,...
                                                                 flagsStruct,...
                                                                 '../saved_matrices/incidenceMatricesPyr.json',...
                                                                 false);
            if isempty(fieldnames(incidenceMatricesPyr))
                cprintf('Errors', 'Sorry something went wrong, application will terminate! Are you sure \n');
                cprintf('Errors', 'you calculated the solution for the previously selected mesh as well? \n');
                cprintf('Text', '======================================================================= \n');
                evalin('base', 'clear');
                return;
            end
            tableShapeFunctionsPyr = createShapeFunctions(incidenceMatricesPyr, searchedString, elementsOrder);
            tableJacobianMatricesPyr = createJacobianMatrices(incidenceMatricesPyr, tableShapeFunctionsPyr);
            tableTransformationMatricesPyr = createTransformationMatrices(incidenceMatricesPyr, tableJacobianMatricesPyr);
            variablesToPreserve = [variablesToPreserve, "tableTransformationMatricesPyr"]; %#ok<AGROW>
        elseif strcmp(searchedString, "prism")
            incidenceMatricesPrism = createIncidenceMatricesForCLI(model,...
                                                                   selectedComponentGeometryTag,...
                                                                   geometryTagPos,...
                                                                   meshdata,...
                                                                   meshdataTypeList,...
                                                                   searchedString,...
                                                                   elementsOrder,...
                                                                   flagsStruct,...
                                                                   '../saved_matrices/incidenceMatricesPrism.json',...
                                                                   false);
            if isempty(fieldnames(incidenceMatricesPrism))
                cprintf('Errors', 'Sorry something went wrong, application will terminate! Are you sure \n');
                cprintf('Errors', 'you calculated the solution for the previously selected mesh as well? \n');
                cprintf('Text', '======================================================================= \n');
                evalin('base', 'clear');
                return;
            end
            tableShapeFunctionsPrism = createShapeFunctions(incidenceMatricesPrism, searchedString, elementsOrder);
            tableJacobianMatricesPrism = createJacobianMatrices(incidenceMatricesPrism, tableShapeFunctionsPrism);
            tableTransformationMatricesPrism = createTransformationMatrices(incidenceMatricesPrism, tableJacobianMatricesPrism);
            variablesToPreserve = [variablesToPreserve, "tableTransformationMatricesPrism"]; %#ok<AGROW>
        elseif strcmp(searchedString, "hex")
            incidenceMatricesHex = createIncidenceMatricesForCLI(model,...
                                                                 selectedComponentGeometryTag,...
                                                                 geometryTagPos,...
                                                                 meshdata,...
                                                                 meshdataTypeList,...
                                                                 searchedString,...
                                                                 elementsOrder,...
                                                                 flagsStruct,...
                                                                 '../saved_matrices/incidenceMatricesHex.json',...
                                                                 true);
            if isempty(fieldnames(incidenceMatricesHex))
                cprintf('Errors', 'Sorry something went wrong, application will terminate! Are you sure \n');
                cprintf('Errors', 'you calculated the solution for the previously selected mesh as well? \n');
                cprintf('Text', '======================================================================= \n');
                evalin('base', 'clear');
                return;
            end
            tableShapeFunctionsHex = createShapeFunctions(incidenceMatricesHex, searchedString, elementsOrder);
            tableJacobianMatricesHex = createJacobianMatrices(incidenceMatricesHex, tableShapeFunctionsHex);
            tableTransformationMatricesHex = createTransformationMatrices(incidenceMatricesHex, tableJacobianMatricesHex);
            variablesToPreserve = [variablesToPreserve, "tableTransformationMatricesHex"]; %#ok<AGROW>
        end
    end
    cprintf('Text', '\n');
    cprintf('Text', 'Generation completed!  \n');
    cprintf('Text', '======================================================================= \n');
    
end

% Pulisco il workspace dalle variabili inutili
command = ['clearvars -except', sprintf(' %s', variablesToPreserve(:))];
eval(command);