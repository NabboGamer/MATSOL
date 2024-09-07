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
    
    while true
        inputString = input('Selection-> ', 's');
        try
            choice = str2double(inputString);
        catch
            cprintf('Text','Invalid choice. Try again... \n');
            continue;
        end
        if isfinite(choice) && choice > 0 && choice < size(labelNameArray, 1) && choice == round(choice)
            choice = round(choice);
            break;
        else
            cprintf('Text','Invalid choice. Try again... \n');
        end
    end
    
    searchedString = labelNameArray(choice,1);
    modelComponentTagPos = strcmp(labelNameArray(:, 1), searchedString);
    selectedComponentTag = modelComponentTagList(modelComponentTagPos);
    selectedComponent = model.component(selectedComponentTag);
end

