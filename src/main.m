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

%% Creazione delle matrici di incidenza
