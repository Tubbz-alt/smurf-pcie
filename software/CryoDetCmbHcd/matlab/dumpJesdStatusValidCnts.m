function dumpJesdStatusValidCnts()
    PVprefix='mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:JesdRx:';
    Jesds={'JesdRx','JesdTx'};
    for j=size(Jesds)
        for cnt =0:9
            val=lcaGet(sprintf('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:%s:StatusValidCnt[%d]',Jesds{j},cnt));
            disp(sprintf('mitch_epics:AMCc:FpgaTopLevel:AppTop:AppTopJesd[0]:%s:StatusValidCnt[%d] = %d',Jesds{j},cnt,val));
            continue
        end
    end
end