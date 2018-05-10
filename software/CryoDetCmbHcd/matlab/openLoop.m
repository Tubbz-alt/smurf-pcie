% NEED TO ADD SINGLE CHANNEL HANDLING; right now takes data on all
% SHOULD MAKE A MORE CONVENIENT WAY OF GETTING A SHORT SEGMENT OF DATA
% sets the specified channels in open loop.
function openLoop(chans)
    rootPath=[getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:FpgaTopLevel:AppTop:AppCore:SysgenCryo:Base[0]:'];
    
    % show plots and stuff
    debug=true;
    
    % make sure we're taking data on all channels
    lcaPut([rootPath,'singleChannelReadoutOpt2'], 0);
    
    [f,df,frs]=getData(rootPath,2^22);
    
    % loop over channels
    for chan=chans
        fchan=f(:,chan+1);
        dfchan=df(:,chan+1);
        
        % find frequency in the middle of the flux ramp swing
        % right now stupidly assumes max and min are on the SQUID curve;
        % no special handling for flux ramp transient or glitches.
        fchan_span=max(fchan)-min(fchan);
        fchan_min=min(fchan);   
        
        % frequency offset in MHz from center of subband that we want to
        % drop into open loop at; right now it's the midpoint between the
        % max and min of the SQUID V-phi.
        Foff=(fchan_min+fchan_span/2);
        % centered frequency
        Foff=(fchan_min+fchan_span/2);
        fc=fchan-(fchan_min+fchan_span/2);
        
        if debug
            figure;
            plot(fc); hold on;
            % plot midline
            plot([0,length(fc)],[0,0]);
            title(sprintf('Determining open loop frequency for chan%d',chan));
            ylabel('F (MHz)');
            xlabel('Sample number');
            legend('(closed loop f) - fc','fc to drop to in open loop');
            hold off;
        end
        disp(sprintf('-> fixing chan%d to Foff = %0.3f MHz',chan, (fchan_min+fchan_span/2)));
        
        % get how channel is currently configured
        [~, ampl, ~, etaPhaseDegree, etaMagScaled]=getCryoChannelConfig(rootPath,chan)
        % set channel to desired open loop offset frequency and turn fb off
        configCryoChannel(rootPath, chan, Foff, ampl, 0, etaPhaseDegree, etaMagScaled);
        
        % verify we are now in open loop
        [f2,df2,frs2]=getData(rootPath,2^22);
        figure;
        
        fchan2=f2(:,chan+1);
        dfchan2=df2(:,chan+1);

        if debug
            figure;
            plot(fchan2); hold on;
            plot(dfchan2+Foff);
            plot(fchan);
            title(sprintf('chan%d, Foff=%0.3f MHz',chan,Foff));
            ylabel('F (MHz)');
            xlabel('Sample number');
            legend('open loop f','open loop df','closed loop f (need to synch using fr)');
            hold off;     
        end
    end
end

%% Old, only works on a single channel
%function Foff=openLoop(rootPath,chan)
%    lcaPut([rootPath,'readoutChannelSelect'], chan(1));
%    lcaPut([rootPath,'singleChannelReadoutOpt2'], 1);
%        
%    quickData();
%    offset=mean(df);
%    disp(['offset=',num2str(offset)]);
%
%    pvRoot = [rootPath, 'CryoChannels:CryoChannel[', num2str(chan(1)), ']:'];
%
%    ampl=lcaGet([pvRoot,'amplitudeScale']);
%
%    etaPhase=lcaGet([pvRoot,'etaPhase']);
%    etaPhaseDeg=(etaPhase/2^15)*180;
%
%    etaMag=lcaGet([pvRoot,'etaMag']);
%    etaScaled=etaMag/2^10;
%
%    configCryoChannel(rootPath, chan(1), offset(1), ampl, 0, etaPhaseDeg(1), etaScaled(1));
%
%    % return the frequency offset of the tone in open loop
%    Foff=offset(1);
%end