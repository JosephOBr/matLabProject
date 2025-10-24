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

% READ DATA FROM FILE
% data = getSeries([
% "R.ASISX","R.ASISY","L.ASISX","L.ASISY","R.PSISX","R.PSISY","L.PSISX","L.PSISY","R.Iliac.CrestX","R.Iliac.CrestY","L.Iliac.CrestX","L.Iliac.CrestY","R.Thigh.Top.LateralX","R.Thigh.Top.LateralY","L.Thigh.Top.LateralX","L.Thigh.Top.LateralY","R.Thigh.Bottom.LateralX","R.Thigh.Bottom.LateralY","L.Thigh.Bottom.LateralX","L.Thigh.Bottom.LateralY","R.Thigh.Top.MedialX","R.Thigh.Top.MedialY","L.Thigh.Top.MedialX","L.Thigh.Top.MedialY","R.Thigh.Bottom.MedialX","R.Thigh.Bottom.MedialY","L.Thigh.Bottom.MedialX","L.Thigh.Bottom.MedialY","R.Shank.Top.LateralX","R.Shank.Top.LateralY","L.Shank.Top.LateralX","L.Shank.Top.LateralY","R.Shank.Bottom.LateralX","R.Shank.Bottom.LateralY","L.Shank.Bottom.LateralX","L.Shank.Bottom.LateralY","R.Shank.Top.MedialX","R.Shank.Top.MedialY","L.Shank.Top.MedialX","L.Shank.Top.MedialY","R.Shank.Bottom.MedialX","R.Shank.Bottom.MedialY","L.Shank.Bottom.MedialX","L.Shank.Bottom.MedialY","R.Heel.TopX","R.Heel.TopY","L.Heel.TopX","L.Heel.TopY","R.Heel.BottomX","R.Heel.BottomY","L.Heel.BottomX","L.Heel.BottomY","R.Heel.LateralX","R.Heel.LateralY","L.Heel.LateralX","L.Heel.LateralY","R.MT1X","R.MT1Y","L.MT1X","L.MT1Y","R.MT5X","R.MT5Y","L.MT5X","L.MT5Y"
% ]);
% Save data to variables

fig = figure('Color','w');
ax  = axes('Parent', fig);
hold(ax, 'on');          % IMPORTANT: prevents plot() from clearing prior graphics
axis(ax, [1500 3000 0 1500]);
axis equal

ax.XLimMode = 'manual';
ax.YLimMode = 'manual';

plot(0,0)
h = plot(ax, nan, nan, 'b', 'LineWidth', 0.1, 'MarkerSize', 10);
plots = [];

for i = 1:2:length(data)
        plots = [ plots, plot(ax,data{i}(n),data{i+1}(n),'rx','lineWidth',3) ];
end

% rfoot_plot = plot(ax, rHeelX(1), rHeelY(1), 'rx', 'LineWidth', 3);
% lfoot_plot = plot(ax, lHeelX(1), lHeelY(1), 'rx', 'LineWidth', 3);

% pelvis_plot = plot(ax, rPelvisX(1), rPelvisY(1), 'rx', 'MarkerSize', 8, 'LineWidth', 3);

pauseTime = 0.005;    % ~200 FPS (adjust as needed)
disp(length(plots))
for frame = 2:4500
    for n = 1:length(plots)
        xData = data{2*n-1}(frame);
        yData = data{2*n}(frame);
        if mod(n,2)
            color = 'red';
        else
            color = 'blue';
        end
        set(plots(n),'XData', xData, 'YData', yData,'Color',color);
    end
    
    
    % currentX = get(h, 'XData');
    % currentY = get(h, 'YData');
    % 
    % newX = [currentX, rHeelX(frame)];
    % newY = [currentY, rHeelY(frame)];

    %set(h, 'XData', newX, 'YData', newY);

    % set(rfoot_plot,'XData', rHeelX(frame),'YData', rHeelY(frame));
    % set(lfoot_plot,'XData', lHeelX(frame),'YData', lHeelY(frame));
    % 
    % set(pelvis_plot,'XData', rPelvisX(frame),'YData', rPelvisY(frame));

    title(ax, sprintf('Frame %d', frame));

    drawnow;
    %pause(pauseTime);
end

disp("END");

disp("*_____________________*")