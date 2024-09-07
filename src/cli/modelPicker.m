function [model] = modelPicker()
    % Specifico i formati di file desiderati
    desiredFormats = {'*.mph'};
    
    % Apro il file picker
    currentPath = pwd;
    defaultPath = strcat(currentPath, '\..\model\');
    [fileName, filePath] = uigetfile(desiredFormats, ...
                                     'Select a COMSOL model to load', ...
                                     defaultPath);
    
    % Controllo se l'utente ha premuto "Annulla" o ha chiuso la finestra
    if isequal(fileName, 0)
        cprintf('Errors', 'No file selected, application will terminate! \n');
        cprintf('Text', '======================================================================= \n');
        return;
    end
    
    % Rimuovo gli asterischi dalla stringa del formato del file
    formatsDesiredWithoutAsterixes = cellfun(@(x) strrep(x, '*', ''), ...
                                             desiredFormats, ...
                                             'UniformOutput', false);

    % Verifico se il file ha uno dei formati desiderati
    validFormat = false;
    for i = 1:length(formatsDesiredWithoutAsterixes)
        if endsWith(lower(fileName), lower(formatsDesiredWithoutAsterixes{i}))
            validFormat = true;
            break;
        end
    end
    
    if ~validFormat
        cprintf('Errors', 'Invalid file format, application will terminate! \n');
        cprintf('Text', '======================================================================= \n');
        return;
    end
        
    cprintf('Text', 'Model selected correctly! \n');
    cprintf('Text', '\n');
    
    completePath = fullfile(filePath, fileName);

    cprintf('Text', 'Please wait while the model is loading... \n');
    oldWarnState = warning('query', 'all');
    warning('off', 'all');
    lastwarn('');
    try
        model = mphload(completePath);
        [msg, ~] = lastwarn;
        if ~isempty(msg)
            cprintf('SystemCommands', '***WARNING: %s\n', msg);
            lastwarn('');
        end
        warning(oldWarnState);
    catch
        model = -1;
    end

end