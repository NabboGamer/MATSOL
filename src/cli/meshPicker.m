function [selectedMesh, selectedMeshTag] = meshPicker(model, selectedComponent)
    selectedComponentMeshList = selectedComponent.mesh();
    selectedComponentMeshTagList = string(selectedComponentMeshList.tags);
    if isempty(selectedComponentMeshTagList)
            cprintf('Errors', 'The component does not yet have any mesh, application will terminate! \n');
            cprintf('Text', '======================================================================= \n');
            return;
    end
    
    labelTagArray = strings(size(selectedComponentMeshTagList, 1), 2);
    for i = 1:size(selectedComponentMeshTagList, 1)
        labelTagArray(i,1) = model.mesh(selectedComponentMeshTagList(i)).label();
    end
    labelTagArray(:,2) = selectedComponentMeshTagList(:);
    
    cprintf('Text', 'Please select the mesh of interest from those available: \n');
    cprintf('Text', '\n');
    for i = 1 : size(labelTagArray, 1)
        cprintf('Text', '\t %s) %s \n', string(i), labelTagArray(i,1));
    end
    cprintf('Text', '\n');

    choice = validateInput(size(labelTagArray, 1));
    
    searchedString = labelTagArray(choice,1);
    selectedMeshTagPos = strcmp(labelTagArray(:, 1), searchedString);
    selectedMeshTag = labelTagArray(selectedMeshTagPos, 2);
    selectedMesh = model.mesh(selectedMeshTag);
end

