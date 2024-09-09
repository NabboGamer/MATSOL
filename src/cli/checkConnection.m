function isConnected = checkConnection()
    try
        oldWarnState = warning('query', 'all');
        warning('off', 'all');
        lastwarn('');
        model = mphload('../model/component_library_RF.mph');
        [msg, ~] = lastwarn;
        if ~isempty(msg)
            cprintf('SystemCommands', 'The file is read-only \n');
            lastwarn('');
        end
        warning(oldWarnState);
        isConnected = true;
    catch
        isConnected = false;
    end
end

