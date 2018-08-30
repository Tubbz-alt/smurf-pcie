% ntries=1;
% ctime=ctimeForFile();
% while true
    % turn off board
    disp('-> Turning off board')
    cmdStr=sprintf('ssh root@10.0.1.4 "clia deactivate board 5"',0);
    system(cmdStr);
    
    disp('-> Pausing 15 sec after turning off board')
    pause(15);

    disp('-> Turning on board')
    cmdStr=sprintf('ssh root@10.0.1.4 "clia activate board 5"',0);
    system(cmdStr);

    disp('-> Pausing 45 sec after turning on board')
%     pause(45);
%     
% 
%     band=3;
%     subband=63;
% 
%     disp(sprintf('-> Running setup(%d)',band))
%     setup(band);
% 
%     %disp(sprintf('-> Running findFreqs(%d,[%d])',band,subband))
%     %findFreqs(band,[subband]);
% 
%     disp(sprintf('-> Running setupNotches_umux16(%d)',band))
%     setupNotches_umux16(band);
% 
%     disp('-> Running trackingSetup on lowest available channel')
%     ch=whichOn(band)
%     [~,f]=trackingSetup(band,ch(1));
%     disp(sprintf('Press enter to keep trying, ctr-c to stop trying (ntries=%d)',ntries))
%     saveas(gcf,sprintf('%d_trackingSetup_try%d.png',ctime,ntries));
%     ntries=ntries+1;
%     pause;
% end