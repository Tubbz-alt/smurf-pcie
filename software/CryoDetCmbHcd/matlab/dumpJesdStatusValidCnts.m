function dumpJesdStatusValidCnts()
    PVprefix=[getSMuRFenv('SMURF_EPICS_ROOT'),':AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdRx:'];
    Jesds={'JesdRx','JesdTx'};
    for j=size(Jesds)
        for cnt =0:9
            val=lcaGet(sprintf('%s:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:%s:StatusValidCnt[%d]',getSMuRFenv('SMURF_EPICS_ROOT'),Jesds{j},cnt));
            disp(sprintf('%s:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:%s:StatusValidCnt[%d] = %d',getSMuRFenv('SMURF_EPICS_ROOT'),Jesds{j},cnt,val));
            continue
        end
    end
end