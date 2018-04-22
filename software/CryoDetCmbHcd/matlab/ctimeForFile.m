function ctime=ctimeForFile(createFileDateDir)

    if nargin < 1
        createFileDateDir=true;
    end

    now=datetime('now')
    
    if createFileDateDir
        % keep data organized by date
        
        %datapath=getenv('SMURF_DATA');
        
        datapath = '/home/common/data/cpu-b000-hp01/cryo_data/data2/';
        
        if isempty(datapath)
            error(['ERROR! environmental variable SMURF_DATA not defined!']);
        end
 
        dirdate=datestr(now,'yyyymmdd');
        datadir=fullfile(datapath,dirdate);
    
        % if today's date directory doesn't exist yet, make it
        if not(exist(datadir))
            disp(['-> creating ' datadir]);
            mkdir(datadir);
        end
    end
    
    ctime=round(posixtime(now));
    
end