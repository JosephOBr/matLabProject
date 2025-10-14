function[headers,dataMatrix] = getData()
    % Open the file and store the fileID into file1
    IDfile1 = fopen("TEST_DATA.txt",'r');
    
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
    seriesNum = find(headers == headername);
    series = data(:,seriesNum); 
end

[headers,data] = getData();

x = getSeries("R.Heel.BottomY",headers,data);
[~,peaks] = findpeaks(x);
[~,mins] = findpeaks(-x);

t = [1:4500];
plot(t,x); hold on; plot(peaks,x(peaks),'or'); plot(mins,x(mins),'or')

