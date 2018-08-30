Off
freq = [-2 -0.5 0.5  2.1];
fftLen        = 64;
fftOversample = 2;
b             = bitrevorder(0:fftLen/fftOversample - 1);
subChan       = 4;
remap128      = reshape([b, b+32, b+64, b+96], fftLen/fftOversample, subChan)';
remap  = [remap128(:);...
          remap128(:)+128;...
          remap128(:)+256;...
          remap128(:)+384];


F(512) = struct('cdata',[], 'colormap',[])
for i = 0:512
    configCryoChannel( root, remap(i+1), freq(mod(i,4)+1), 10, 0, 0, 1);
    pause(0.01)
    dac = readDacData(root, 2, 2^16); figure(1); pwelch(dac,[],[],[],614.4,'centered'); title(['Channel = ', num2str(remap(i+1))])
    F(i+1) = getframe(gcf)
end
%%
fig = figure;
movie(fig,F,2)

