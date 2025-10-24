%% extract_XY.m
% Reads Time + all X and Y columns from S2run45markers.txt
% Outputs:
%   - marker struct (fields like R_ASISX, R_ASISY, ...)
%   - tblXY table
%   - MAT and CSV files

%% ------------------ CONFIG ------------------
fileName = "S2run45markers.txt";   % input file
outMat   = "S2run45markers_XY.mat";
outCsv   = "S2run45markers_XY.csv";

%% ------------------ STEP 1: Read header ------------------
fid = fopen(fileName, 'r');
if fid == -1
    error('Cannot open file: %s', fileName);
end
headerLine = fgetl(fid);
fclose(fid);

headers = strsplit(strtrim(headerLine), ','); % cell array of header names

%% ------------------ STEP 2: Select Time + X/Y columns ------------------
keepCols = find(contains(headers, 'X') | contains(headers, 'Y') | strcmp(headers, 'Time'));
selectedHeaders = headers(keepCols);

fprintf('Found %d columns (Time + X/Y only)\n', numel(selectedHeaders));

%% ------------------ STEP 3: Read data ------------------
opts = delimitedTextImportOptions('Delimiter', ',', 'VariableNamesLine', 1);
opts.SelectedVariableNames = selectedHeaders;
opts.VariableNamingRule = 'preserve'; % keep original names
T = readtable(fileName, opts);

%% ------------------ STEP 4: Build struct ------------------
marker = struct();
for i = 1:numel(selectedHeaders)
    fld = matlab.lang.makeValidName(selectedHeaders{i}); % replace dots with underscores
    marker.(fld) = T.(selectedHeaders{i});
end

timeData = T.Time;

%% ------------------ STEP 5: Save outputs ------------------
tblXY = T; % table with Time + X/Y only
save(outMat, 'marker', 'tblXY', 'selectedHeaders', 'timeData');
writetable(tblXY, outCsv);

fprintf('Saved MAT: %s\n', outMat);
fprintf('Saved CSV: %s\n', outCsv);

%% ------------------ STEP 6: Quick plot ------------------
figure('Name','Heel XY Diagnostics','Color','w');
subplot(2,1,1);
plot(timeData, marker.R_Heel_BottomX, 'b'); hold on;
plot(timeData, marker.L_Heel_BottomX, 'r');
xlabel('Time'); ylabel('Heel X'); legend('Right','Left'); grid on;

subplot(2,1,2);
plot(timeData, marker.R_Heel_BottomY, 'b'); hold on;
plot(timeData, marker.L_Heel_BottomY, 'r');
xlabel('Time'); ylabel('Heel Y'); legend('Right','Left'); grid on;

disp('Done.');