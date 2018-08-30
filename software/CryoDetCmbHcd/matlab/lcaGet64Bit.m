function decimal = lcaGet64Bit( PV )
    val = char( lcaGet(PV) );
    decimal = convertCharToDec( val );
end