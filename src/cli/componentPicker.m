function selectedComponent = componentPicker(model)
    modelComponentList = model.component();
    modelComponentTagList = string(modelComponentList.tags);
    if isempty(modelComponentTagList)
        cprintf('Errors', 'The model does not yet have any components, application will terminate! \n');
        cprintf('Text', '======================================================================= \n');
        return;
    end
    
    labelNameArray = strings(size(modelComponentTagList, 1), 2);
    for i = 1:size(modelComponentTagList, 1)
        labelNameArray(i,1) = model.component(modelComponentTagList(i)).label();
    end
    labelNameArray(:,2) = modelComponentTagList(:);
    
    cprintf('Text', 'Please select the component of interest from those available: \n');
    cprintf('Text', '\n');
    for i = 1 : size(labelNameArray, 1)
        cprintf('Text', '\t %s) %s \n', string(i), labelNameArray(i,1));
    end
    cprintf('Text', '\n');

    choice = validateInput(size(labelNameArray, 1));
    
    searchedString = labelNameArray(choice,1);
    modelComponentTagPos = strcmp(labelNameArray(:, 1), searchedString);
    selectedComponentTag = modelComponentTagList(modelComponentTagPos);
    selectedComponent = model.component(selectedComponentTag);
end

