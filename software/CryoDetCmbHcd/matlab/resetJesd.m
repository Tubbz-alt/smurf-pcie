function resetJesd()
    PVprefix=[getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdRx:'];
    lcaPut([PVprefix,'ResetGTs'],1);
    pause(0.1);
    lcaPut([PVprefix,'ResetGTs'],0);
end