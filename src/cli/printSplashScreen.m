function printSplashScreen()
    % Nome del file .txt
    filename = './resources/banner.txt';
    
    % Apri il file in modalità lettura ('r')
    fileID = fopen(filename, 'r');
    
    % Controlla se il file è stato aperto correttamente
    if fileID == -1
        cprintf('Errors','The banner.txt file could not be opened to proceed with reading \n');
        return;
    end
    
    % Leggi il file riga per riga
    while ~feof(fileID)
        % Leggi una riga dal file
        riga = fgetl(fileID);
        
        % Stampa la riga sulla console con fprintf
        cprintf('Text', '%s\n', riga);
    end
    
    % Chiudi il file
    fclose(fileID);
end

