function decimal = convertCharToDec( c )
    s = cellstr(c(:, 3:end)); % trim leadin 0x
    decimal = zeros(size(s));
    for i = 1:length(s)
       decimal(i) = hex2dec(s{i}); 
    end
end