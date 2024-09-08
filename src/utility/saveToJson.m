function saveToJson(incidenceMatrices, fileName)
    % Converto la struct in formato JSON
    jsonString = jsonencode(incidenceMatrices);
    
    % Specifico il nome(con percorso) del file in cui salvare la struttura
    % fileName = '../saved_matrices/incidenceMatrices.json';
    
    % Verifico se il file esiste già
    if exist(fileName, 'file')
        cprintf('SystemCommands', '***WARNING: File %s \n', fileName);
        cprintf('SystemCommands', '            already exists, a new file will be created \n');
        [~, name, ext] = fileparts(fileName);
        timestamp = datetime('now', 'Format', 'dd-MM-yyyy_HH-mm');
        fileName = ["../saved_matrices/", string(name), "_", string(timestamp), string(ext)];
        fileName = string(strjoin(fileName, ""));
    end
    
    % Creo e apro il file in modalità scrittura
    fileID = fopen(fileName, 'w'); % 'w' crea il file se non esiste
    
    if fileID == -1
        cprintf('Errors','The file could not be opened to proceed with writing \n');
        return;
    end
    
    % Scrivi la stringa JSON nel file
    fprintf(fileID, '%s', jsonString);
    fclose(fileID);
    cprintf('Text','The incidence matrices have been successfully saved to disk! \n');
end

