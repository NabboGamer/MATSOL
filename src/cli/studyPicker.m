function [selectedStudy, selectedStudyTag] = studyPicker(model)
    
    modelStudyTagList = string(model.study.tags);
    if isempty(modelStudyTagList)
        selectedStudy = -1;
        selectedStudyTag = -1;
        return;
    end

    cprintf('Text', 'Please select the study of interest from those available: \n');
    cprintf('Text', '\n');
    for i = 1 : size(modelStudyTagList, 1)
        cprintf('Text', '\t %s) %s \n', string(i), modelStudyTagList(i,1));
    end
    cprintf('Text', '\n');

    choice = validateInput(size(modelStudyTagList, 1));
    selectedStudyTag = modelStudyTagList(choice,1);
    selectedStudy = model.study(selectedStudyTag);
end

