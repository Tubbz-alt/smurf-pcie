function resetJesd()
    lcaPut([getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdRx:LINK_DISABLE'], 1);
    pause(0.5);
    lcaPut([getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdRx:LINK_DISABLE'], 0);
end