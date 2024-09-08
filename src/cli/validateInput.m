function choice = validateInput(maxNumberOfChoice)
    while true
        inputString = input('Selection-> ', 's');
        try
            choice = str2double(inputString);
        catch
            cprintf('Text','Invalid choice. Try again... \n');
            continue;
        end
        if isfinite(choice) && choice > 0 && choice < (maxNumberOfChoice+1) && choice == round(choice)
            choice = round(choice);
            break;
        else
            cprintf('Text','Invalid choice. Try again... \n');
        end
    end
end

