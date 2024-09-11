function [selectedStep, selectedStepTag] = stepPicker(selectedStudy)
    
    studyFeatureString = string(selectedStudy.feature());
    stepTagString = extractAfter(studyFeatureString, 'Child nodes: ');
    stepTagList = split(stepTagString, ', ');
    if isempty(stepTagList)
        selectedStep = -1;
        selectedStepTag = -1;
        return;
    end

    cprintf('Text', 'Please select the step of interest from those available: \n');
    cprintf('Text', '\n');
    for i = 1 : size(stepTagList, 1)
        cprintf('Text', '\t %s) %s \n', string(i), stepTagList(i,1));
    end
    cprintf('Text', '\n');

    choice = validateInput(size(stepTagList, 1));
    selectedStepTag = stepTagList(choice,1);
    selectedStep = selectedStudy.feature(selectedStepTag);
end

