format longG
function[seriesData] = getSeries(fileName,seriesNames)

    %wb = waitbar(0,sprintf('Getting %s data', strjoin(string(seriesNames), ', ')));
    fprintf('Reading %s from file \n',strjoin(string(seriesNames), ', '))
    % Open the file and store the fileID into file1
    IDfile1 = fopen(fileName,'r');
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
                % ^ DECIDED NOT TO USE SINCE IT SLOWED DOWN THE PROGRAM
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

function[strideDurations,strideLength] = getStrideDurations(yData,timeData, xData,speed)
    % mins are the INDEXES of each MINIMUM VALUE
    [~,mins] = findpeaks(-yData);

    strideDurations = diff(timeData(mins));
    xDiev = diff(xData(mins))./1000; % Get the deviation for every step

    % t = 1:4500;
    % plot(t,xData)
    % hold on
    % plot(mins,(xData(mins)),'o')

    strideLength = (strideDurations * speed/10) + xDiev;
end

function[strideDurations,nStrides,strideLengths,strideSpeeds] = calculateMetrics(rHeelY,timeData,rHeelX,speed)
    speed = str2double(speed);
    [strideDurations,strideLengths] = getStrideDurations(rHeelY,timeData,rHeelX,speed);
    nStrides = 1:length(strideDurations);
    strideSpeeds = strideLengths./strideDurations;
end

function[stridePercent, yNorm] = getNormalisedData(plots,colors,currentSpeed,timeData,lAPelvisY,rAPpelvisSY,lPPelvisy,rPPelvisY, rHeelY)
    
    [~, rMin] = findpeaks(-rHeelY);
    
    % average pelvis height
    % the pelvis is tracked using 4 markers (left/right ASIS and PSIS)
    % take the average of all 4 vertical (Y) positions to get a clean line
    pelvisY = (lAPelvisY+rAPpelvisSY+lPPelvisy+rPPelvisY) / 4 / 1000;
    % set up the stride time scale from 0% to 100%
    % this makes each stride line up to the same length on the graph
    stridePercent = linspace(0,100,101);
    % loop through each stride (between two heel strikes)
    for s = 1:length(rMin)-1
        a = rMin(s);
        b = rMin(s+1);
        % pull out time and pelvis data for this single stride
        tStride = timeData(a:b);
        yStride = pelvisY(a:b);

        % skip short or bad strides
        if length(tStride) < 5
            continue
        end

        % normalise the stride so they can all be compared easily
        % we sample 101 evenly spaced points from start to end (0–100%)
        strideLen = length(yStride);
        step = floor(strideLen / 101);
        yNorm = yStride(1:step:end);
        
        % if the last stride happens to have more than 101 points, trim it
        if length(yNorm) > 101
            yNorm = yNorm(1:101);
        end
        axes(plots(2,1))
        hold on;
        plot(stridePercent,yNorm,'Color',colors{currentSpeed});
        title("Pelvis vertical position")
        xlabel('Normalised Stride Time (%)')
        ylabel("distance (m)")
    end
    
end

function makePlots(plots,colors,s,plotSpeed,strideDurations, strideLengths, nStrides,strideSpeeds,stridePercent, ...
        yNorm, lHeelY,lHeelX,lToeY,lToeX,rHeelY,rHeelX,rToeY,rToeX)
    disp("Making plots")
    
    axes(plots(1,1))
    hold on;
    plot(nStrides,strideDurations);
    title("Duration for each stride")
    xlabel("# number stride")
    ylabel("Time (s)")
    legend(plotSpeed);
    
    axes(plots(1,2))
    hold on;
    plot([1:length(strideLengths)],strideLengths);
    title("Length of each stride")
    xlabel("# number stride")
    ylabel("Length (m)")
    legend(plotSpeed);
    
    axes(plots(1,3))
    hold on;
    plot(nStrides,strideSpeeds)
    title("Stride speed")
    xlabel("# number stride")
    ylabel("v (m/s)")
    legend(plotSpeed);

    axes(plots(2,1));
    hold on
    pVp = zeros(1,3);
    for f = 1:3
        pVp(f) = plot(nan, nan, colors{f}, 'LineWidth', 1.2);
    end
    legend(pVp, plotSpeed, 'Location', 'best')


    axes(plots(2,2))
    hold on;
    plot((lHeelX+lToeX)*0.5*0.001,(lHeelY+lToeY)*0.5*0.001);
    xlim([1.4 2.8])
    ylim([0 0.8])
    title("Left foot position")
    ylabel("Foot lift (m)")
    xlabel("Stride length (m)")
    legend(plotSpeed);

    axes(plots(2,3))
    hold on;
    plot((rHeelX+rToeX)*0.5*0.001,(rHeelY+rToeY)*0.5*0.001);
    xlim([1.4 2.8])
    ylim([0 0.8])
    title("Right foot position")
    ylabel("Foot lift (m)")
    xlabel("Stride length (m)")
    legend(plotSpeed);

end

function[plots] = createSubplots()
    i = 1;
    for rows = 1:2
        for cols = 1:3
            plots(rows,cols) = subplot(2,3,i);
            i = i + 1;
        end
    end
end

function[dataSetNumber] = getDataSetNames()
    disp("Note, please place the dataset as a folder of the name convention" + ...
        "SN, where N is the number of the dataset. For example 'S1'")

    disp("The appropriate folder structure is:" + newline + ...
         "├── index.m" + newline + ...
         "├── SN/" + newline + ...
         "    ├── SNrun25markers.txt" + newline + ...
         "    ├── SNrun35markers.txt" + newline + ...
         "    ├── SNrun45markers.txt");

    dataSetNumber = input("Please enter N. A number: ");  
end

disp("START")

% Program variables
speeds = ["25","35","45"];
labels = ["2.5 m/s","3.5 m/s","4.5 m/s"];
colors   = {'b','r','g'}; %blue, red and green
data = cell(1,3);

% Creates a 3x2 matrix of plots to plot on
plots = createSubplots();

dataSetNumber = getDataSetNames(); %Get the datasetnumber from the user

for s=1:length(speeds)
    % Statement 2 : Read data from file
    thisData = getSeries("S"+dataSetNumber+"/S"+dataSetNumber+"run"+speeds{s}+"markers.txt",["Time","R.Heel.BottomX",...
       "R.Heel.BottomY", "L.ASISY","R.ASISY","L.PSISY","R.PSISY",...
       "L.Heel.BottomX","L.Heel.BottomY","L.MT1X","L.MT1Y","R.MT1X",...
       "R.MT1Y","L.PSISX","R.PSISX"]);
    data(1,s) = {thisData};

    % Statement 3: Assign variables to the data
    [timeData, rHeelX, rHeelY, lAPelvisY, rAPelvisY,lPPelvisY, ...
        rPPelvisY, lHeelX,lHeelY,lToeX,lToeY,rToeX,rToeY,lPPelvisX,rPPelvisX] = data{1,s}{:};

    % Statement 4: Calculate the metrics for the graph
    [strideDurations, nStrides, strideLengths, strideSpeeds] = calculateMetrics(rHeelY, timeData, rHeelX,speeds{s});    
    
    % Statement 5: Plot the graphs
    [stridePercent, yNorm] = getNormalisedData(plots,colors,s,timeData,lAPelvisY,rAPelvisY,lPPelvisY,rPPelvisY, rHeelY);
    makePlots(plots,colors,s,labels,strideDurations,strideLengths,nStrides, strideSpeeds, stridePercent,yNorm,lHeelY,lHeelX,lToeY,lToeX,rHeelY,rHeelX,rToeY,rToeX);
    

end
disp("END")
disp("*_____________________*")