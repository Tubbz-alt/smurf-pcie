function [y_hat, a1, a2, a3, a4, a5, a6, a7] = fluxRampDemod( frequency, frameSize, normalizedDemodFrequency, gain )
%#codegen

    modelOrder = 3;
    
    H = zeros(frameSize, modelOrder*2 + 1);
    for i = 1:modelOrder
      cs = cos(i*2*pi*normalizedDemodFrequency.*(0:frameSize-1));
      sn = sin(i*2*pi*normalizedDemodFrequency.*(0:frameSize-1));
      H(:,2*i-1) = cs;
      H(:,2*i)   = sn;
    end

    H(:,end) = ones(frameSize,1);


    alpha    = 0.1*ones(2*modelOrder+1,1);
    y_hat    = zeros(numel(frequency),1);
    alphaMat = zeros(7, numel(frequency));


    for i = 1:numel(frequency)
       % observation i.e. DDS LUT
       h = H(mod(i+frameSize-1,frameSize)+1,:);
       % prediction
       y_hat(i) = h*alpha;
       % error
       err = frequency(i) - y_hat(i);
    
       % feedback 
       alpha = alpha + gain*err*h';
       
       alphaMat(:,i) = alpha;
    end

    a1 = alphaMat(1,:);
    a2 = alphaMat(2,:);
    a3 = alphaMat(3,:);
    a4 = alphaMat(4,:);
    a5 = alphaMat(5,:);
    a6 = alphaMat(6,:);
    a7 = alphaMat(7,:);

end
