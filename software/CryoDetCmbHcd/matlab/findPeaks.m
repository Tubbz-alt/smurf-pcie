function fp = findPeaks(sweep,bandnum,plotsaveprefix)
    if nargin < 3
        % prefix for plots, including path
        plotsaveprefix='';
    end

    debug=false;
    doplot=false;
    plotph=true;
    
    % whether or not to normalize data before peak finding
    normalize=true;
    % if data is normalized, this many samples on either side
    % of the band aren't included in the normalization
    nsamp_ignore_on_edges=10;
    
    % peak finding threshold; doesn't take into account 
    % whether or not data is normalized before peak finding
    threshold=0.5;
            
    %% gaussian filter for smoothing; not used right now
    %% whether or not to apply smoothing
    %smooth=false;
    %sigma = 1.
    %sz = 2*sigma;
    %x = linspace(-sz / 2, sz / 2, sz);
    %gaussFilter = exp(-x .^ 2 / (2 * sigma ^ 2));
    %gaussFilter = gaussFilter / sum (gaussFilter);
    
    for band=bandnum:bandnum    
        %% sometimes this data has multiple measurements at the same
        %% frequency.  Need to reduce.
        freqs=sweep.f(band+1,:);
        resp=sweep.resp(band+1,:);
        [freqs,resp]=reduce_fresp(freqs,resp);
        
        %% Extract I & Q for this band, compute the raw phase,
        %% and unwrap it
        df=(freqs(2)-freqs(1));
        Idat=real(resp);
        Qdat=imag(resp);
        phase=unwrap(atan2(Qdat,Idat)); 
        
        % take point-to-point gradient of raw phase
        d2u=diff([phase(:)]);
        % we lose a frequency point differencing
        diff_freqs=freqs(1:end-1)+df/2;
        
        if normalize
            % when normalizing phase for peak finding against unit-referred 
            % threshold, ignore edges where things can go wrong
            normfactormin=min(d2u(nsamp_ignore_on_edges:end-nsamp_ignore_on_edges));
            normfactormax=max(d2u(nsamp_ignore_on_edges:end-nsamp_ignore_on_edges));
            d2u=(d2u-normfactormin)/(normfactormax-normfactormin);
        end
    
        if doplot
            % phase diff and peaks
            if get(gcf,'Number')==1
                figure(1);
            else
                figure(get(gcf,'Number')+1);
            end
            plot(diff_freqs,d2u,'.','markers',12,'color','black'); hold on;
            plot(diff_freqs,d2u,'color','black');
        end
    
        %% first peak finding; thresholding on gradient of raw phase
        fp=peakFinder(diff_freqs,d2u,threshold);
        
        % plot threshold
        if doplot
            grid on;
            plot([diff_freqs(1),diff_freqs(end)],[threshold,threshold],'--','color','red');
            hold off;
            xlabel('Frequency (MHz)');
            ylabel('diff(Phase) (rad)');
        end
    
        %% now try to remove gradient.  Compute slope and offset from
        %% interval with largest separation between peaks.
        pkfreqs=[fp.pkfreq];
        diffpkfreqs=diff(pkfreqs);
        if doplot
            figure(get(gcf,'Number')+1);
            plot(freqs,phase); hold on;
        end
        %% Zoom in on each resonance, in phase to try to 
        %% get a better frequency estimate, and to sanity check if
        %% total phase throw and bandwidth are reasonable.
        %% First need to correct for baseline drift.  Use largest chunk
        %% of phase between two peaks for now.
        bestm=eps;
        bestb=eps;
        bestN=0;
        for jj=1:length(diffpkfreqs)
            if debug
                disp(['pk' int2str(jj)]);
                disp(pkfreqs(jj));
            end
            fmargin=df*5;
            kk=find((freqs>pkfreqs(jj)+fmargin)&(freqs<pkfreqs(jj+1)-fmargin));
            freqs_kk=freqs(kk);
            phase_kk=phase(kk);
            
            % estimate line slopes and intercepts
            [mts,bts]=tslineparams(freqs_kk,phase_kk);
            % plot
            if doplot
                rcolor=rand(1,3);
                plot(freqs_kk,phase_kk, '.', 'color', rcolor);
                plot(freqs_kk,mts*freqs_kk+bts,'--','color',rcolor);
            end
            if length(freqs_kk)>bestN
                bestm=mts;
                bestb=bts;
                bestN=length(freqs_kk);
            end
        end
        if doplot
            hold off;
        end
        
        %% For some reason this attempt to subtract phase drift is not very successful
        phase_bcorr=phase - (freqs*bestm+bestb);
        if plotph
            figure();
            title('Subtracting off phase drift');
            plot(freqs,phase_bcorr,'-','color','black'); hold on;
            ylim([-5,5]);
            phtitle=sprintf('band %d',bandnum);
            title(phtitle);
            xlabel('Frequency (MHz)');
            ylabel('Corr. Phase (rad)');
        end
        %% on top of this, plot windows on resonators
        % window in phase over which to call something a resonator
        fwindow=df*8/2;
        for jj=1:length(pkfreqs)
            % don't even try for now if resonance is within the window of
            % the edges of the band
            fp(jj).good=0;
            fp(jj).phres=eps; % better estimate of frequency for resonance identified as good
            if ~(pkfreqs(jj)+fwindow>max(freqs)) && ~(pkfreqs(jj)-fwindow<min(freqs))
                kk=find((freqs>pkfreqs(jj)-fwindow)&(freqs<pkfreqs(jj)+fwindow));
                % find maximum and minimum in window
                freqskk=freqs(kk);
                [minPh,minPhIdx] = min(phase_bcorr(kk));
                minPhFreq=freqskk(minPhIdx);
                [maxPh,maxPhIdx] = max(phase_bcorr(kk));
                maxPhFreq=freqskk(maxPhIdx);
                % draw line that goes through min and max phase
                mm=find((freqs>pkfreqs(jj)-1.125*fwindow)&(freqs<pkfreqs(jj)+1.125*fwindow));
                phm=(maxPh-minPh)/(maxPhFreq-minPhFreq);
                phb=maxPh-phm*maxPhFreq;
                
                dFr=abs(maxPhFreq-minPhFreq);
                dPhr=abs(maxPh-minPh);
                if debug
                    disp('-----------------------------------------');
                    disp('* This resonance phase statistics:');
                    disp(['dFr=' num2str(dFr)]);
                    disp(['dPhr=' num2str(dPhr)]);
                end
                
                % make sure phase discontinuity is physical.
                if dPhr>pi/4 && dPhr<pi
                    if plotph
                        rcolor=rand(1,3);
                        plot(freqs(kk),phase_bcorr(kk),'-','color',rcolor,'LineWidth',2);
                        plot(freqs(kk),phase_bcorr(kk),'.','color',rcolor,'markers',12);
                        plot(freqs(mm),phm*freqs(mm)+phb,'--','color',rcolor);
                    end
                    fp(jj).good=1;
                    
                    % estimate resonance frequency from phase 
                    fres_phest=((maxPh-maxPh/2.)-phb)/phm; % right in middle of resonance
                    fp(jj).phres=fres_phest;
                end
            end
        end
        hold off;
        
        if doplot
            %
            % unwrapped phase and smoothed phase (with peak positions drawn on)
            figure(get(gcf,'Number')+1);
            plot(freqs,phase,'.','markers',12,'color','black'); hold on;
            plot(freqs,phase,'color','black'); 
    
            %phase_end=mean(phase(end-2:end));
            %phase_start=mean(phase(1:2));
            %phase_slope=(phase_end-phase_start)/(freqs(end)-freqs(1));
            %phase_offset=phase_start-phase_slope*freqs(1);
            %disp([phase_slope phase_offset]);
            %plot(freqs,freqs*phase_slope+phase_offset);  
            %xlabel('Frequency (MHz)');
            %ylabel('Normalized, unwrapped phase (rad)');
            %hold off;
        
            %
            % transmission (with peak positions drawn on)
            figure(get(gcf,'Number')+1);
            amplitudes=abs(resp);
            plot(freqs,dBv(amplitudes),'.','markers',12,'color','black'); hold on;
            plot(freqs,dBv(amplitudes),'color','black');
            % smoothed
            %amplitudes_filt = filter (gaussFilter,1,amplitudes);
            %plot(freqs,dBv(amplitudes_filt),'color','green');
            ylabel('sqrt(I*I + Q*Q) (dBFS)');
            xlabel('Frequency (MHz)');
            hold off; 
        end
    end
    hold off;
    % save plot if provided with prefix
    if ~isempty(plotsaveprefix)
        saveas(gcf,[plotsaveprefix,'_band',num2str(band),'.png']);
    end
end

function [freqsr,respr]=reduce_fresp(freqs,resp)
    Nperpt=sum(freqs==freqs(1));
    resp_uniq = zeros(1, Nperpt);
    freqs_uniq=unique(freqs);
    for ii = 1:length(freqs_uniq)
        kk=find(freqs==freqs_uniq(ii));
        resp_uniq(ii)=mean(resp(kk));
    end
    respr=resp_uniq;
    freqsr=freqs_uniq;
end

% convert to dB assuming input is voltage
function dBv_vec = dBv(vec)
    dBv_vec=20*log10(vec);
end

function pkStruct = peakFinder(x,y,threshold)
    %% find peaks
    % threshold
    in_peak=0;
    idx=1;
    pkStruct=[];
    npeaks=0;
    pkmax=0; pkfreq=0; pknabove=0;
    for jj=1:length(y)
        f=x(jj);
        amp=y(jj);
        if in_peak==0
            pkmax=0;
            pkfreq=0;
            pknabove=0;
        end
        if amp>threshold
            if in_peak==0
                npeaks=npeaks+1;
            end
            in_peak=1;
            pknabove=pknabove+1;
            if amp>pkmax
                pkmax=amp;
                pkfreq=f;
            end
            if idx==length(y) || y(idx+1)<threshold
                pkStruct(npeaks).pkmax=pkmax; 
                pkStruct(npeaks).pknabove=pknabove; 
                pkStruct(npeaks).pkfreq=pkfreq; 
                %disp([pkfreq pkmax pknabove])
                %scatter([pkfreq],[pkmax],'facecolor','red');
                in_peak=0;
            end
        end
        idx=idx+1;
    end
    %disp(pkStruct);   
    %% done finding peaks
end

% 
function [m,b] = tslineparams(x,y)
    Npt = length(y);
    slopes = zeros(1, Npt*(Npt-1)/2);
    idx=1;
    for ii=1:Npt
        for jj=(ii+1):Npt
                xi=x(ii);
                yi=y(ii);
                xj=x(jj);
                yj=y(jj);
                slopes(idx)=(y(jj)-y(ii))/(x(jj)-x(ii));
                if x(jj)<x(ii)
                    slopes(idx)=-1.*slopes(idx);
                end
                idx=idx+1;
        end
    end
    m=median(slopes);
    b=median(y-m*x);
    %disp(['m=' num2str(m)]);
    %disp(['b=' num2str(b)]);
end