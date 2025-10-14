function[headers,dataMatrix] = getData(wantedHeader)
    % Open the file and store the fileID into file1
    IDfile1 = fopen("S2run25markers.txt",'r');
    
    mat = [];

    % Read the file data line-by-line
    while ~feof(IDfile1)
    
        nextRow = strsplit(fgetl(IDfile1),',');
        mat = [mat; nextRow];
            
    end
    
    % get the heading values (strings)
    headers = mat(1, :);               

    % Convert the other values to doubles and add them to a new matrix
    dataMatrix = str2double(mat(2:end, :)); 

    % Close the file
    fclose(IDfile1);
end

function[series] = getSeries(headername,headers,data)
    % get a particular series from the data
    series = find(headers == headername);
end
[headers,data] = getData();
getSeries(headers)