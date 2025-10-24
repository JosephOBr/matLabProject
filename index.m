format longG
function[seriesData] = getSeries(seriesNames)

    %wb = waitbar(0,sprintf('Getting %s data', strjoin(string(seriesNames), ', ')));
    fprintf('Reading %s from file \n',strjoin(string(seriesNames), ', '))
    % Open the file and store the fileID into file1
    IDfile1 = fopen("S2run45markers.txt",'r');
    % get the number of series requested
    targetCount = numel(seriesNames);
    % series data will accumilate the requested series in an array
    seriesData = cell(1, targetCount);
    % seriesNums contains the index of each requested series
    seriesNums = zeros(1,targetCount);
    % store the row containing headers
    headers = strsplit(fgetl(IDfile1),',');
    % find the index of each series of interest and store it in seriesNums
    for i = 1:targetCount
        seriesNums(i) = find(headers == seriesNames(i));
    end
    % Read the file data line-by-line, store the requested values from each
    % row in tempData, and then distribute it to each relevent series in
    % seriesData
    nextDatam = "";

    i = 1;
    while ~feof(IDfile1)
        % Read the row and split it by commas
        nextRow = strsplit(fgetl(IDfile1),',');

        for n = 1:targetCount
            % Get the column(s) we're interested in into nextDatam(n1,
            % n2,...)
            nextDatam = str2double(nextRow(seriesNums(n)));
            % This line adds the nextdatam to the relevant series in the 'seriesData' array. 
            % This line of code took way too long to figure out so please dont ask about it. 
            seriesData(1,n) = {[seriesData{1,n} , nextDatam]};
            
            % only update UI every 1000 lines since it slows down the
            % program dramatically
            if mod(i,1000) == 0
                % Chat-GPT 5 was used for this following line (since it is only
                % for aesthetics I decided to not work it out myself)
                %waitbar(i/(4500*targetCount), wb, ...
                    %sprintf('Reading %s from file \n%d/%d lines read', strjoin(string(seriesNames), ', '), i, 4500*targetCount));
                fprintf('%d/%d lines read \n', i, 4500*targetCount);
            end
            i=i+1;
        end
    end
    disp("Done");
    % Close the file
    fclose(IDfile1);
    %close(wb);
end

function[strideDurations] = getStrideDurations(yData,timeData)
    % mins are the INDEXES of each MINIMUM VALUE
    [~,mins] = findpeaks(-yData);
    times0 = [timeData(mins),0];
    times1 = [0,timeData(mins)];

    strideDurations = times0 - times1;
    strideDurations = strideDurations(1:end-1);
end

function[strideLength] = getStrideLength()

end

function makePlots(timeData,nStrides,strideDurations, lPelvisY, rPelvisY, ...
    rightHeelX, rightHeelY, leftHeelX, leftHeelY)
    disp("Making plots")
    figure
    subplot(2,3,1)
    plot(nStrides,strideDurations);
    title("Duration for each stride")
    xlabel("# number stride")
    ylabel("Time (s)")
    
    subplot(2,3,2)
    plot(nStrides,nStrides);
    title("Length of each stride")
    xlabel("# number stride")
    ylabel("Length (m)")
    
    subplot(2,3,3)
    plot(nStrides,nStrides);
    title("Stride speed")
    xlabel("# number stride")
    ylabel("v (m/s)")
    
    subplot(2,3,4)
    plot(timeData, (lPelvisY+rPelvisY)/2); 
    hold off;
    title("Average pelvis vertical position")
    xlabel("Time (s)")
    ylabel("distance (m)")
    
    subplot(2,3,5)
    plot(leftHeelX,leftHeelY);
    title("Left foot position")
    xlabel("X data (mm)")
    ylabel("Y data (mm)")
    
    subplot(2,3,6)
    plot(rightHeelX,rightHeelY);
    title("Right foot position")
    xlabel("X data (mm)")
    ylabel("Y data (mm)")
end

disp("START")

% READ DATA FROM FILE
data = getSeries(["Time","R.Heel.BottomX","R.Heel.BottomY","R.Heel.BottomZ", ...
   "L.ASISY","R.ASISY","L.Heel.BottomX","L.Heel.BottomY"]);
% Save data to variables
[timeData, rightHeelX, rightHeelY, rightHeelZ, lPelvisY, rPelvisY,leftHeelX,...
    leftHeelY] = data{:};

% GET STRIDE DURATIONS
strideDurations = getStrideDurations(rightHeelY,timeData);
nStrides = 1:length(strideDurations);

% PLOT THE STUFF
makePlots(timeData,nStrides,strideDurations, lPelvisY, rPelvisY,rightHeelX, ...
    rightHeelY, leftHeelX, leftHeelY);


disp("END")
disp("*_____________________*")