addpath('./cli');
addpath('./polyhedra_types/polyhedra_with_all_faces_equal');
addpath('./polyhedra_types/polyhedra_with_different_faces');
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
    cprintf('Errors', 'Sorry, something went wrong, application will terminate! \n');
    cprintf('Text', '======================================================================= \n');
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

while true
    inputString = input('Selection-> ', 's');
    try
        choice = str2double(inputString);
    catch
        cprintf('Text','Invalid choice. Try again... \n');
        continue;
    end
    if isfinite(choice) && choice > 0 && choice < 4 && choice == round(choice)
        choice = round(choice);
        break;
    else
        cprintf('Text','Invalid choice. Try again... \n');
    end
end
cprintf('Text', '======================================================================= \n');

%% Creazione delle matrici di incidenza
if choice == 1
    fields = {'arrayNodesFaces', 'arrayNodesBoundaryFaces', ...
             'arrayNodesSides', 'arrayFacesElements', 'arraySidesElements', ...
             'arraySidesFaces', 'arraySidesBoundaryFaces', 'arrayDomainsElements', ...
             'arrayBoundaryFacesDomainBoundaryFacesElement', 'arrayAll'};
    
    bool1 = 'calculate';
    bool2 = 'save';
    
    flagsStruct = struct();
    
    for i = 1:length(fields)
        internalStruct = struct(bool1, false, bool2, false);
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
    
    while true
        inputString = input('Selection-> ', 's');
        try
            whichCalculate = str2double(inputString);
        catch
            cprintf('Text','Invalid choice. Try again... \n');
            continue;
        end
        if isfinite(whichCalculate) && whichCalculate > 0 && whichCalculate < 11 && whichCalculate == round(whichCalculate)
            whichCalculate = round(whichCalculate);
            break;
        else
            cprintf('Text','Invalid choice. Try again... \n');
        end
    end
    cprintf('Text', '======================================================================= \n');

    cprintf('Text', 'Wants the matrix to be saved on disk too: \n');
    cprintf('Text', '\n');
    cprintf('Text', '\t  1) YES \n');
    cprintf('Text', '\t  2) NO \n');
    cprintf('Text', '\n');

    while true
        inputString = input('Selection-> ', 's');
        try
            save = str2double(inputString);
        catch
            cprintf('Text','Invalid choice. Try again... \n');
            continue;
        end
        if isfinite(save) && save > 0 && save < 3 && save == round(save)
            save = round(save);
            break;
        else
            cprintf('Text','Invalid choice. Try again... \n');
        end
    end
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

end