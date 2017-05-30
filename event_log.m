function event_log( logName, message )

    if nargin < 2
        delete(logName);
    else  
        fileID = fopen(logName,'a');
        fprintf(fileID,'%s\r\n',message);
        fclose(fileID);
    end
end

