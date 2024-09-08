function loadFromJson()
    evalin('base', 'clear'), close all; clc;
    fileName = '../saved_matrices/incidenceMatricesHex.json';
    
    % Verifica se il file esiste
    if ~isfile(fileName)
        error(['Il file ', fileName, ' non esiste.']);
    end
    
    % Leggi il contenuto del file JSON
    jsonString = fileread(fileName);
    
    % Decodifica la stringa JSON in una struct
    incidenceMatrices = jsondecode(jsonString);

    assignin('base', 'incidenceMatrices', incidenceMatrices);
    
    % Assegna la struct al workspace (variabile di output della funzione)
    disp(['Struct caricata da ', fileName]);
end

