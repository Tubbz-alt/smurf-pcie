setTESBias(1,0,1)

x = 1

while x
    
    for i=0:1:10000000
        setTESBias(1, 15000*(sin(i/500)), 0)
        if mod(i,1000)==0
            disp(i)
        end
        pause(0.01)
    end
end