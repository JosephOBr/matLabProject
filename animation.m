function [seriesData] = getSeries(seriesNames, filename)
    fprintf('Reading %s from file \n', strjoin(string(seriesNames), ', '))
    IDfile1 = fopen(filename, 'r');
    targetCount = numel(seriesNames);
    seriesData = cell(1, targetCount);
    seriesNums = zeros(1, targetCount);
    headers = strsplit(fgetl(IDfile1), ',');

    for i = 1:targetCount
        seriesNums(i) = find(headers == seriesNames(i));
    end

    nextDatam = "";
    i = 1;
    while ~feof(IDfile1)
        nextRow = strsplit(fgetl(IDfile1), ',');
        for n = 1:targetCount
            nextDatam = str2double(nextRow(seriesNums(n)));
            seriesData{1, n} = [seriesData{1, n}, nextDatam];

            if mod(i, 1000) == 0
                fprintf('%d lines read\n', i);
            end
            i = i + 1;
        end
    end
    fclose(IDfile1);
    disp("Done");
end

% Marker names
seriesNames = [
    "R.ASISX","R.ASISY","L.ASISX","L.ASISY","R.PSISX","R.PSISY","L.PSISX","L.PSISY", ...
    "R.Iliac.CrestX","R.Iliac.CrestY","L.Iliac.CrestX","L.Iliac.CrestY", ...
    "R.Thigh.Top.LateralX","R.Thigh.Top.LateralY","L.Thigh.Top.LateralX","L.Thigh.Top.LateralY", ...
    "R.Thigh.Bottom.LateralX","R.Thigh.Bottom.LateralY","L.Thigh.Bottom.LateralX","L.Thigh.Bottom.LateralY", ...
    "R.Thigh.Top.MedialX","R.Thigh.Top.MedialY","L.Thigh.Top.MedialX","L.Thigh.Top.MedialY", ...
    "R.Thigh.Bottom.MedialX","R.Thigh.Bottom.MedialY","L.Thigh.Bottom.MedialX","L.Thigh.Bottom.MedialY", ...
    "R.Shank.Top.LateralX","R.Shank.Top.LateralY","L.Shank.Top.LateralX","L.Shank.Top.LateralY", ...
    "R.Shank.Bottom.LateralX","R.Shank.Bottom.LateralY","L.Shank.Bottom.LateralX","L.Shank.Bottom.LateralY", ...
    "R.Shank.Top.MedialX","R.Shank.Top.MedialY","L.Shank.Top.MedialX","L.Shank.Top.MedialY", ...
    "R.Shank.Bottom.MedialX","R.Shank.Bottom.MedialY","L.Shank.Bottom.MedialX","L.Shank.Bottom.MedialY", ...
    "R.Heel.TopX","R.Heel.TopY","L.Heel.TopX","L.Heel.TopY","R.Heel.BottomX","R.Heel.BottomY", ...
    "L.Heel.BottomX","L.Heel.BottomY","R.Heel.LateralX","R.Heel.LateralY","L.Heel.LateralX","L.Heel.LateralY", ...
    "R.MT1X","R.MT1Y","L.MT1X","L.MT1Y","R.MT5X","R.MT5Y","L.MT5X","L.MT5Y"
];

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
dataSetNumber = getDataSetNames(); %Get the datasetnumber from the user


% Load data from each file
data1 = getSeries(seriesNames, "S"+dataSetNumber+"/S"+dataSetNumber+"run25markers.txt");
data2 = getSeries(seriesNames, "S"+dataSetNumber+"/S"+dataSetNumber+"run35markers.txt"); 
data3 = getSeries(seriesNames, "S"+dataSetNumber+"/S"+dataSetNumber+"run45markers.txt");

datasets = {data1,data2,data3};
flightFrames = cell(1,3);
startframes = [0,0,0];

% Compute flight frames for each dataset
for i = 1:3
    % This was initially going to be used to measure the distance of the
    % stride and I put it in the animation to run a visual test if it
    % worked

    currentData = datasets{i};
    lPPelvisY = currentData{6};  % L.PSISY
    rPPelvisY = currentData{4};  % R.PSISY
    avgPelvis = (lPPelvisY + rPPelvisY) / 2;
    pelvis_vel = gradient(avgPelvis);
    pelvis_acc = gradient(pelvis_vel);
    pelvis_jerk = gradient(pelvis_acc);

    [~, flight_start] = findpeaks(-pelvis_jerk);
    [~, flight_end] = findpeaks(pelvis_jerk);

    if flight_end(1) < flight_start(1)
        flight_end(1) = [];
    end
    startFrames(i) = flight_start(1);
    isFlightFrame = false(1, length(avgPelvis));
    for k = 1:min(length(flight_start), length(flight_end))
        isFlightFrame(flight_start(k):flight_end(k)) = true;
    end
    flightFrames{i} = isFlightFrame;
end

% Create figure and subplots
fig = figure;
axesArray = gobjects(1,3);
plotsArray = cell(1,3);

for i = 1:3
    % Create the plots that need to be animated
    axesArray(i) = subplot(1,3,i);
    hold(axesArray(i), 'on');
    axis(axesArray(i), [1500 3000 0 1500]);
    axis equal
    axesArray(i).XLimMode = 'manual';
    axesArray(i).YLimMode = 'manual';

    currentData = datasets{i};
    plots = [];
    for j = 1:2:length(currentData)
        plots = [plots, plot(axesArray(i), currentData{j}(1), currentData{j+1}(1), 'rx', 'LineWidth', 3)];
    end
    plotsArray{i} = plots;
end

% Animate each plot
pauseTime = 0.0016;
for frame = 0:4500
    pause(pauseTime);
    for i = 1:3
        currentData = datasets{i};
        plots = plotsArray{i};
        isFlightFrame = flightFrames{i};

        % Update background and title
        if isFlightFrame(startFrames(i) + frame)
            title(axesArray(i), sprintf('Frame %d — Run %d — Flight Phase', startFrames(i) + frame, i));
            set(axesArray(i), 'Color', [255/255 255/255 224/255]);  % light yellow
        else
            title(axesArray(i), sprintf('Frame %d — Run %d — Ground Phase', startFrames(i) + frame, i));
            set(axesArray(i), 'Color', [114/255 213/255 225/255]);  % light blue
        end

        % Update marker positions
        for n = 1:length(plots)
            xData = currentData{2*n-1}(startFrames(i) + frame);
            yData = currentData{2*n}(startFrames(i) + frame);
            if mod(n,2) == 1
                color = 'red';
            else
                color = 'blue';
            end
            set(plots(n), 'XData', xData, 'YData', yData, 'Color', color);
        end
    end
    drawnow;
end

disp("END");
disp("*_____________________*")
