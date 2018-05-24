function filename=fileNameFromPath(filepath)
    [~,name,ext] = fileparts(filepath);
    filename=[name ext];